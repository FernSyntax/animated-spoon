import 'dart:async';
import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'net.dart';
import 'proto/kd.pb.dart';

/// Lifecycle of the authoritative WebSocket connection.
enum ConnState { offline, connecting, online, error }

/// A command sent to the realm worker, tracked until its result frame arrives.
///
/// Results are matched by `id`, so a late or reordered frame cannot mark the
/// wrong command as accepted. The UI renders these in submission order.
class PendingCommand {
  PendingCommand(this.id, this.label, this.status);

  final String id;
  final String label;

  /// One of `pending`, `ok`, or `rejected`.
  String status;
}

/// Single source of truth for client-side game state.
///
/// Holds the authenticated session, the latest authoritative snapshot exposed
/// by `player`/`map`, and the live WebSocket connection. Every mutation that
/// affects the UI calls [notifyListeners]; all network I/O goes through [api].
class GameState extends ChangeNotifier {
  final ApiClient api;
  GameState(this.api);

  String? token;
  String? accountId;
  String? username;
  String realmId = 'realm-a';
  String? playerId;
  String? selectedCityId;
  List<dynamic> realms = [];
  ConnState conn = ConnState.offline;
  String lastError = '';
  Map<String, dynamic> player = {};
  Map<String, dynamic> map = {};
  final List<PendingCommand> pending = [];
  final List<String> eventLog = [];
  List<List<int>> chunks = [
    [0, 0],
    [1, 0],
    [0, 1],
    [1, 1]
  ];
  WebSocketChannel? _ws;
  StreamSubscription<dynamic>? _sub;
  int _seq = 0;
  Timer? _resync;
  Timer? _reconnect;
  int _reconnectAttempts = 0;
  String? _cursor;

  bool get loggedIn => token != null && token!.isNotEmpty;
  bool get hasCity => (player['cities'] as List?)?.isNotEmpty ?? false;
  List<dynamic> get cities => (player['cities'] as List?) ?? [];
  Map<String, dynamic> get firstCity {
    if (!hasCity) return {};
    final selected = cities.where((city) => city['id'] == selectedCityId);
    if (selected.isNotEmpty) {
      return Map<String, dynamic>.from(selected.first as Map);
    }
    // Avoid `firstWhere(orElse:)`: the list's runtime element type can be a
    // concrete map type, which makes the inferred `orElse` signature reject a
    // `dynamic` fallback (e.g. when a test seeds typed map literals).
    final capitals = cities.where((city) => city['is_capital'] == true);
    final city = capitals.isNotEmpty ? capitals.first : cities.first;
    return Map<String, dynamic>.from(city as Map);
  }

  Map<String, dynamic> get resources => hasCity
      ? Map<String, dynamic>.from(firstCity['resources'] as Map? ?? {})
      : {};
  Map<String, dynamic> get alliance => player['alliance_id'] == null
      ? {}
      : {'id': player['alliance_id'], 'role': player['alliance_role']};

  Future<void> login(String user, String pass) async {
    lastError = '';
    try {
      final r = await api.login(user, pass);
      token = r['token'] as String;
      accountId = r['account_id'] as String?;
      final v = await api.validate(token!);
      username = v['username'] as String? ?? user;
      realms = await api.realms();
      notifyListeners();
    } catch (e) {
      lastError = e.toString();
      conn = ConnState.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String user, String pass) async {
    lastError = '';
    try {
      await api.register(user, pass);
      await login(user, pass);
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> joinRealm(String realm) async {
    realmId = realm;
    selectedCityId = null;
    final r = await api.joinRealm(token!, realm);
    playerId = r['player_id'] as String;
    await refresh();
    await connect();
    notifyListeners();
  }

  void selectCity(String cityId) {
    if (selectedCityId == cityId) return;
    selectedCityId = cityId;
    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      final r = await api.bootstrap(token!, realmId, chunks);
      player = Map<String, dynamic>.from(r['state'] as Map? ?? {});
      map = Map<String, dynamic>.from(r['map'] as Map? ?? {});
      _cursor = r['cursor'] as String?;
      lastError = '';
      notifyListeners();
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> connect() async {
    unawaited(_ws?.sink.close());
    await _sub?.cancel();
    conn = ConnState.connecting;
    notifyListeners();
    _ws = api.connectWS(token!, realmId, chunks);
    _sub = _ws!.stream.listen((data) {
      if (data is! List<int>) return;
      WsEnvelope env;
      try {
        env = WsEnvelope.fromBuffer(data);
      } catch (e) {
        // A malformed frame must not tear down the whole subscription.
        lastError = 'Malformed server frame: $e';
        return;
      }
      if (env.whichBody() == WsEnvelope_Body.snapshot) {
        final s = env.snapshot;
        _cursor = s.cursor;
        player = _decodeMap(s.stateJson);
        map = _decodeMap(s.mapJson);
        conn = ConnState.online;
        _reconnectAttempts = 0;
        notifyListeners();
      } else if (env.whichBody() == WsEnvelope_Body.commandResult) {
        final r = env.commandResult;
        final p = pending.where((x) => x.id == r.commandId).toList();
        for (final item in p) {
          item.status = r.code == ErrorCode.OK ? 'ok' : 'rejected';
        }
        if (r.code == ErrorCode.OK && r.stateJson.isNotEmpty) {
          final envelope = _decodeMap(r.stateJson);
          final st = envelope['state'];
          if (st is Map) player = Map<String, dynamic>.from(st);
        } else if (r.code != ErrorCode.OK) {
          lastError = r.message;
          eventLog.add('REJECTED ${r.message}');
        }
        notifyListeners();
      } else if (env.whichBody() == WsEnvelope_Body.delta) {
        final d = env.delta;
        var line = '${d.eventType} @ ${d.serverTimeUnixMs}';
        if (d.eventType == 'chat.message' && d.payloadJson.isNotEmpty) {
          final body = _decodeMap(d.payloadJson);
          final payload = body['payload'];
          if (payload is Map) {
            line =
                'CHAT [${payload['scope']}] ${payload['from']}: ${payload['text']}';
          }
        }
        eventLog.add(line);
        if (eventLog.length > 80) {
          eventLog.removeAt(0);
        }
        // Any world change may affect our view: resync from the authoritative snapshot.
        unawaited(refresh());
      } else if (env.whichBody() == WsEnvelope_Body.error) {
        lastError = env.error.message;
        notifyListeners();
      }
    }, onError: (Object e) {
      conn = ConnState.error;
      lastError = e.toString();
      notifyListeners();
    }, onDone: () {
      if (token == null) return;
      _reconnect?.cancel();
      final backoff = Duration(seconds: (1 << _reconnectAttempts.clamp(0, 5)));
      _reconnectAttempts++;
      _reconnect = Timer(backoff, () {
        if (token != null) unawaited(connect());
      });
    });
    _resync?.cancel();
    _resync =
        Timer.periodic(const Duration(seconds: 5), (_) => unawaited(refresh()));
    notifyListeners();
  }

  Map<String, dynamic> _decodeMap(List<int> bytes) {
    if (bytes.isEmpty) return {};
    try {
      final v = jsonDecode(utf8.decode(bytes));
      return v is Map ? Map<String, dynamic>.from(v) : {};
    } catch (_) {
      return {};
    }
  }

  Future<void> submit(String label, CommandPayload payload) async {
    if (conn != ConnState.online) {
      lastError = 'Cannot submit while offline';
      notifyListeners();
      return;
    }
    final id = '${DateTime.now().microsecondsSinceEpoch}-$_seq';
    final item = PendingCommand(id, label, 'pending');
    pending.insert(0, item);
    if (pending.length > 20) pending.removeLast();
    notifyListeners();
    final env = WsEnvelope(
      seq: Int64(_seq++),
      command: SubmitCommandRequest(
        realmId: realmId,
        commandId: id,
        payload: payload,
      ),
    );
    _ws?.sink.add(env.writeToBuffer());
    // Visibly recover stale state even if the result frame is lost.
    Timer(const Duration(seconds: 3), () {
      if (item.status == 'pending') unawaited(refresh());
    });
  }

  Future<void> updateChunks(List<List<int>> next) async {
    chunks = next;
    _ws?.sink.add(WsEnvelope(
      seq: Int64(_seq++),
      subscription: SubscriptionUpdate(
        chunks: next.map((c) => Vec2(x: c[0], y: c[1])).toList(),
        cursor: _cursor ?? '',
      ),
    ).writeToBuffer());
    await refresh();
    notifyListeners();
  }

  Future<void> logout() async {
    if (token != null) {
      try {
        await api.logout(token!);
      } catch (_) {}
    }
    token = null;
    playerId = null;
    await _sub?.cancel();
    _resync?.cancel();
    _reconnect?.cancel();
    unawaited(_ws?.sink.close());
    conn = ConnState.offline;
    notifyListeners();
  }

  Future<void> advanceTestClock(int micros) async {
    await api.advanceClock(token!, realmId, micros);
    await refresh();
  }

  @override
  void dispose() {
    _resync?.cancel();
    _reconnect?.cancel();
    _sub?.cancel();
    unawaited(_ws?.sink.close());
    super.dispose();
  }
}
