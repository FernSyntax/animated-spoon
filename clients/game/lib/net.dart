import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Platform-neutral transport. The same HTTP + binary-WebSocket protocol is
/// used on every target; no platform-specific networking code.
class ApiClient {
  final String base;
  ApiClient(this.base);

  /// Posts JSON to an HTTP endpoint and decodes the response.
  ///
  /// Non-2xx responses become exceptions carrying the status and body so the
  /// calling screen can show the server's rejection reason verbatim.
  Future<dynamic> _call(String path, Object body, {String? token}) async {
    final headers = <String, String>{'content-type': 'application/json'};
    if (token != null) headers['authorization'] = 'Bearer $token';
    final resp = await http.post(Uri.parse('$base$path'),
        headers: headers, body: jsonEncode(body));
    if (resp.statusCode >= 400) {
      throw Exception('${resp.statusCode}: ${resp.body}');
    }
    if (resp.body.isEmpty) return {};
    return jsonDecode(resp.body);
  }

  Future<String> register(String username, String password) async {
    final r = await _call('/auth/register',
        {'username': username, 'password': password, 'display_name': username});
    return r['account_id'] as String;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final r = await _call(
        '/auth/login', {'username': username, 'password': password});
    return Map<String, dynamic>.from(r as Map);
  }

  Future<void> logout(String token) async {
    await _call('/auth/logout', {'token': token});
  }

  Future<Map<String, dynamic>> validate(String token) async {
    final r = await _call('/auth/validate', {'token': token});
    return Map<String, dynamic>.from(r as Map);
  }

  Future<List<dynamic>> realms() async {
    final r = await http.get(Uri.parse('$base/realms'));
    if (r.statusCode != 200) throw Exception('${r.statusCode}: ${r.body}');
    return (jsonDecode(r.body)['realms'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> joinRealm(String token, String realmId) async {
    final r = await _call('/realms/$realmId/join', {}, token: token);
    return Map<String, dynamic>.from(r as Map);
  }

  Future<Map<String, dynamic>> bootstrap(
      String token, String realmId, List<List<int>> chunks) async {
    final r = await _call('/bootstrap', {
      'token': token,
      'realm_id': realmId,
      'chunks': chunks,
    });
    return Map<String, dynamic>.from(r as Map);
  }

  Future<Map<String, dynamic>> advanceClock(
      String token, String realmId, int deltaMicros) async {
    final r = await _call('/admin/clock/advance', {
      'token': token,
      'realm_id': realmId,
      'delta_micros': deltaMicros,
    });
    return Map<String, dynamic>.from(r as Map);
  }

  /// Opens the binary WebSocket used for commands and authoritative streams.
  ///
  /// The `http(s)` gateway address is rewritten to `ws(s)`; credentials and the
  /// subscription chunk list travel in the query string.
  WebSocketChannel connectWS(
      String token, String realmId, List<List<int>> chunks) {
    final wsBase = base
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    final chunkStr = chunks.map((c) => '${c[0]},${c[1]}').join(';');
    final uri = Uri.parse('$wsBase/ws?token=${Uri.encodeComponent(token)}'
        '&realm=${Uri.encodeComponent(realmId)}&chunks=${Uri.encodeComponent(chunkStr)}');
    return WebSocketChannel.connect(uri);
  }
}
