import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/game.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'state.dart';

/// Isometric view over the realm's authoritative, chunked map snapshot.
/// Terrain, cities, targets, fog and marches all come from the server.
class WorldMap extends FlameGame {
  final GameState state;
  final ValueChanged<List<int>> onTileSelected;
  double centerX = 64, centerY = 64, zoom = 1;
  static const double tileW = 64, tileH = 36;
  final Images _images = Images(prefix: 'assets/art/');
  static const _artKeys = [
    'grass',
    'forest',
    'hills',
    'water',
    'mountains',
    'city_own',
    'city_enemy',
    'monster',
    'monster_dragon',
    'monster_golem',
    'resource_node',
    'fort',
    'march',
    'building_town_hall',
    'building_farm',
    'building_barracks',
    'building_academy',
    'building_wall',
    'building_market',
    'building_lumber_mill',
    'building_quarry',
    'building_iron_mine',
    'building_warehouse',
    'building_hospital',
    'building_embassy',
    'hero_portrait',
    'hero_aurora',
    'hero_borin',
    'hero_cinder',
    'hero_dalia',
    'hero_eorin',
    'hero_faye',
    'hero_cavalry',
    'hero_archer',
    'unit_cavalry',
    'unit_archer',
  ];
  Offset _last = Offset.zero;
  bool _panning = false;
  List<int>? selected;
  Map<String, dynamic>? _sceneRef;
  List<List<dynamic>> _tiles = [];
  List<Map<String, dynamic>> _entities = [], _cities = [], _marches = [];
  List<List<dynamic>> _fog = [];
  bool get panning => _panning;

  WorldMap(this.state, {required this.onTileSelected}) {
    if (state.cities.isNotEmpty) {
      centerX = (state.cities.first['x'] as num?)?.toDouble() ?? 64;
      centerY = (state.cities.first['y'] as num?)?.toDouble() ?? 64;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    for (final key in _artKeys) {
      try {
        await _images.load('$key.png');
      } catch (_) {/* geometry fallback below */}
    }
    if (state.cities.isNotEmpty) {
      centerX = (state.cities.first['x'] as num?)?.toDouble() ?? 64;
      centerY = (state.cities.first['y'] as num?)?.toDouble() ?? 64;
    }
  }

  double get _w => tileW * zoom;
  double get _h => tileH * zoom;

  Offset worldToScreen(double x, double y) => Offset(
        size.x / 2 + (x - centerX - y + centerY) * _w / 2,
        size.y / 2 + (x - centerX + y - centerY) * _h / 2,
      );

  List<int> screenToWorld(Offset p) {
    final dx = (p.dx - size.x / 2) / (_w / 2);
    final dy = (p.dy - size.y / 2) / (_h / 2);
    return [
      (centerX + (dx + dy) / 2).round(),
      (centerY + (dy - dx) / 2).round()
    ];
  }

  void beginGesture(Offset p) {
    _last = p;
    _panning = false;
  }

  void panBy(Offset delta, Offset p) {
    centerX =
        (centerX - delta.dx / _w - delta.dy / _h).clamp(0, 2048).toDouble();
    centerY =
        (centerY + delta.dx / _w - delta.dy / _h).clamp(0, 2048).toDouble();
    _last = p;
    if (delta.distance > 2) _panning = true;
  }

  void zoomBy(double factor) =>
      zoom = (zoom * factor).clamp(.4, 2.8).toDouble();
  void jumpTo(int x, int y) {
    centerX = x.toDouble();
    centerY = y.toDouble();
  }

  void endGesture() {
    if (!_panning) {
      selected = screenToWorld(_last);
      onTileSelected(selected!);
    }
  }

  bool _art(ui.Canvas canvas, String key, Rect dst, {ColorFilter? filter}) {
    try {
      final image = _images.fromCache('$key.png');
      canvas.drawImageRect(
          image,
          Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
          dst,
          Paint()
            ..filterQuality = FilterQuality.medium
            ..colorFilter = filter);
      return true;
    } catch (_) {
      return false;
    }
  }

  int _terrainIndex(dynamic value) {
    if (value is num) return value.toInt().clamp(0, 4);
    return switch (value.toString().toLowerCase().split('.').last) {
      'forest' => 1,
      'hills' => 2,
      'water' => 3,
      'mountains' => 4,
      _ => 0,
    };
  }

  Path _diamond(Offset p) => Path()
    ..moveTo(p.dx, p.dy - _h / 2)
    ..lineTo(p.dx + _w / 2, p.dy)
    ..lineTo(p.dx, p.dy + _h / 2)
    ..lineTo(p.dx - _w / 2, p.dy)
    ..close();

  int _tileHash(int x, int y) {
    var value = x * 374761393 + y * 668265263 + 1442695041;
    value = ((value ^ (value >> 13)) & 0x7fffffff) * 1274126177;
    return (value ^ (value >> 16)) & 0x7fffffff;
  }

  void _drawTerrain(ui.Canvas canvas, Offset p, int terrain, int x, int y) {
    final colors = [
      const Color(0xff78a95f), // open grassland
      const Color(0xff386c4c), // evergreen forest
      const Color(0xffb18b55), // rolling highland
      const Color(0xff347f9b), // deep water
      const Color(0xff929c99), // bare stone
    ];
    final tile = _diamond(p);
    canvas.drawPath(tile, Paint()..color = colors[terrain]);
    canvas.save();
    canvas.clipPath(tile);
    // A clean color plane makes terrain readable at strategy zoom. Small,
    // coordinate-stable details add texture without repeating the tile art.
    final facet = Path()
      ..moveTo(p.dx, p.dy - _h / 2)
      ..lineTo(p.dx + _w / 2, p.dy)
      ..lineTo(p.dx, p.dy + _h / 2)
      ..close();
    canvas.drawPath(
        facet, Paint()..color = Colors.white.withValues(alpha: .07));
    final detail = _tileHash(x, y);
    if (terrain == 3) {
      for (var i = 0; i < 2; i++) {
        final yy = p.dy + ((detail >> (i * 3) & 7) - 3) * _h * .035;
        canvas.drawLine(
            Offset(p.dx - _w * (.08 + i * .09), yy),
            Offset(p.dx + _w * (.14 + i * .04), yy - _h * .07),
            Paint()
              ..color = const Color(0x7798d8d1)
              ..strokeWidth = .8 * zoom
              ..strokeCap = ui.StrokeCap.round);
      }
    } else if (terrain == 2) {
      final ridge = Path()
        ..moveTo(p.dx - _w * .31, p.dy + _h * .12)
        ..lineTo(p.dx - _w * .06, p.dy - _h * .12)
        ..lineTo(p.dx + _w * .28, p.dy + _h * .08);
      canvas.drawPath(
          ridge,
          Paint()
            ..color = const Color(0x8877664a)
            ..strokeWidth = 1.2 * zoom
            ..style = ui.PaintingStyle.stroke);
    } else if (terrain == 0 && detail % 3 == 0) {
      final blade = Path()
        ..moveTo(p.dx - _w * .10, p.dy + _h * .08)
        ..lineTo(p.dx - _w * .13, p.dy - _h * .03)
        ..moveTo(p.dx - _w * .10, p.dy + _h * .08)
        ..lineTo(p.dx - _w * .04, p.dy - _h * .02);
      canvas.drawPath(
          blade,
          Paint()
            ..color = const Color(0x668fc16e)
            ..strokeWidth = .8 * zoom
            ..style = ui.PaintingStyle.stroke);
    } else if (terrain == 4 && detail % 3 == 0) {
      final rock = Path()
        ..moveTo(p.dx - _w * .18, p.dy + _h * .06)
        ..lineTo(p.dx - _w * .04, p.dy - _h * .11)
        ..lineTo(p.dx + _w * .08, p.dy + _h * .01)
        ..close();
      canvas.drawPath(rock, Paint()..color = const Color(0x556e7c7e));
    }
    canvas.restore();
    canvas.drawPath(
        tile,
        Paint()
          ..color = const Color(0x29313e35)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = .38 * zoom);
  }

  void _drawRelief(
      ui.Canvas canvas, Offset p, int terrain, int tileX, int tileY) {
    if (terrain != 1 && terrain != 4) return;
    final signature = _tileHash(tileX, tileY);
    // Relief belongs to occasional cells only. The old linear coordinate
    // pattern made mountain ranges repeat in diagonal stripes across the map.
    if (terrain == 4 && signature % 13 != 0) return;
    if (terrain == 1 && signature % 4 != 0) return;
    try {
      final key = terrain == 1 ? 'forest' : 'mountains';
      final image = _images.fromCache('$key.png');
      final source = Rect.fromLTWH(
          image.width * .08, 0, image.width * .84, image.height * .70);
      final destination = Rect.fromCenter(
        center: p.translate(0, -_h * .34),
        width: _w * (terrain == 4 ? 1.18 : 1.08),
        height: _h * (terrain == 4 ? 1.8 : 1.55),
      );
      canvas.drawImageRect(image, source, destination,
          Paint()..filterQuality = FilterQuality.medium);
    } catch (_) {/* image fallback: terrain diamonds remain readable */}
  }

  void _syncScene() {
    if (identical(_sceneRef, state.map)) return;
    _sceneRef = state.map;
    _tiles = ((state.map['tiles'] as List?) ?? [])
        .whereType<List<dynamic>>()
        .where((t) => t.length >= 3)
        .toList()
      ..sort((a, b) => ((a[0] as num) + (a[1] as num))
          .compareTo((b[0] as num) + (b[1] as num)));
    _entities = ((state.map['entities'] as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => ((a['x'] as num? ?? 0) + (a['y'] as num? ?? 0))
          .compareTo((b['x'] as num? ?? 0) + (b['y'] as num? ?? 0)));
    _cities = ((state.map['cities'] as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => ((a['x'] as num? ?? 0) + (a['y'] as num? ?? 0))
          .compareTo((b['x'] as num? ?? 0) + (b['y'] as num? ?? 0)));
    _marches = ((state.map['marches'] as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    _fog = ((state.map['fogged_chunks'] as List?) ?? [])
        .whereType<List<dynamic>>()
        .toList();
  }

  Offset _tileCenter(double x, double y) => worldToScreen(x, y).translate(0, 0);

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    _syncScene();
    canvas.drawRect(Offset.zero & Size(size.x, size.y),
        Paint()..color = const Color(0xff1b3337));
    for (final t in _tiles) {
      final x = (t[0] as num).toDouble(), y = (t[1] as num).toDouble();
      final p = _tileCenter(x, y);
      if (p.dx < -_w ||
          p.dy < -_h * 2 ||
          p.dx > size.x + _w ||
          p.dy > size.y + _h * 2) {
        continue;
      }
      final terrain = _terrainIndex(t[2]);
      _drawTerrain(canvas, p, terrain, x.toInt(), y.toInt());
      final border = _diamond(p);
      if (selected != null && selected![0] == x && selected![1] == y) {
        canvas.drawPath(
            border,
            Paint()
              ..color = const Color(0xfff4cf79)
              ..style = ui.PaintingStyle.stroke
              ..strokeWidth = 2.2);
      }
    }

    // Raised forest canopies and snow peaks are drawn after every ground tile,
    // so neighboring terrain can never paint over them.
    for (final t in _tiles) {
      final x = (t[0] as num).toDouble(), y = (t[1] as num).toDouble();
      final p = _tileCenter(x, y);
      if (p.dx < -_w ||
          p.dy < -_h * 3 ||
          p.dx > size.x + _w ||
          p.dy > size.y + _h * 3) {
        continue;
      }
      _drawRelief(canvas, p, _terrainIndex(t[2]), x.toInt(), y.toInt());
    }

    for (final f in _fog) {
      if (f.length < 2) continue;
      final cx = (f[0] as num).toInt(), cy = (f[1] as num).toInt();
      final left = cx * 32.0, top = cy * 32.0;
      final fog = Path()
        ..moveTo(worldToScreen(left, top).dx, worldToScreen(left, top).dy)
        ..lineTo(
            worldToScreen(left + 32, top).dx, worldToScreen(left + 32, top).dy)
        ..lineTo(worldToScreen(left + 32, top + 32).dx,
            worldToScreen(left + 32, top + 32).dy)
        ..lineTo(
            worldToScreen(left, top + 32).dx, worldToScreen(left, top + 32).dy)
        ..close();
      canvas.drawPath(fog, Paint()..color = const Color(0x4513232c));
      canvas.drawPath(
          fog,
          Paint()
            ..color = const Color(0x3c9cb8ad)
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = .8 * zoom);
      final center = worldToScreen(left + 16, top + 16);
      _label(canvas, 'UNSCOUTED', center, const Color(0xffc5d3c8), 8);
    }

    for (final e in _entities) {
      final x = (e['x'] as num?)?.toDouble() ?? 0,
          y = (e['y'] as num?)?.toDouble() ?? 0;
      final p = worldToScreen(x, y);
      if (p.dx < -_w * 2 ||
          p.dy < -_h * 3 ||
          p.dx > size.x + _w * 2 ||
          p.dy > size.y + _h * 3) {
        continue;
      }
      final kind = e['kind']?.toString().toLowerCase() ?? '';
      final level = (e['level'] as num?)?.toInt() ?? 1;
      final subtype = e['subtype']?.toString().toLowerCase() ?? '';
      final key = kind.contains('monster')
          ? ((subtype.contains('golem') || level >= 4)
              ? 'monster_golem'
              : 'monster_dragon')
          : (kind.contains('node') || kind.contains('resource'))
              ? 'resource_node'
              : 'fort';
      canvas.drawOval(
          Rect.fromCenter(
              center: p.translate(0, _h * .12),
              width: _w * .76,
              height: _h * .28),
          Paint()..color = const Color(0x55040b0e));
      _art(
          canvas,
          key,
          Rect.fromCenter(
              center: p.translate(0, -_h * .58),
              width: _w * (kind.contains('monster') ? 1.45 : 1.24),
              height: _h * (kind.contains('monster') ? 2.8 : 2.18)));
      final hp = (e['hp'] as num?)?.toInt() ?? 0;
      if (kind.contains('monster')) {
        _label(canvas, 'LV $level', p.translate(0, _h * .48),
            const Color(0xffffe7b2), 9);
        _hpBar(canvas, p.translate(0, _h * .82), hp, level * 100,
            const Color(0xffef6a5a));
      } else if (kind.contains('fort')) {
        _hpBar(canvas, p.translate(0, _h * .82), hp, level * 500,
            const Color(0xffd9a861));
      } else if (subtype.isNotEmpty) {
        _label(canvas, subtype.toUpperCase(), p.translate(0, _h * .48),
            const Color(0xffcfe8d8), 8);
      }
    }

    for (final c in _cities) {
      final p = worldToScreen(
          (c['x'] as num?)?.toDouble() ?? 0, (c['y'] as num?)?.toDouble() ?? 0);
      if (p.dx < -_w * 2 ||
          p.dy < -_h * 4 ||
          p.dx > size.x + _w * 2 ||
          p.dy > size.y + _h * 4) {
        continue;
      }
      final mine = c['player_id'] == state.playerId;
      canvas.drawOval(
          Rect.fromCenter(
              center: p.translate(0, _h * .14),
              width: _w * 1.0,
              height: _h * .36),
          Paint()..color = const Color(0x66040b0e));
      _art(
          canvas,
          mine ? 'city_own' : 'city_enemy',
          Rect.fromCenter(
              center: p.translate(0, -_h * .48),
              width: _w * 1.85,
              height: _h * 3.35));
      _label(
          canvas,
          (c['name'] ?? 'Settlement').toString(),
          p.translate(0, _h * .55),
          mine ? const Color(0xffc4f4dd) : const Color(0xffe3edec),
          10);
      if ((c['shield_until_ms'] as num? ?? 0) >
          DateTime.now().millisecondsSinceEpoch) {
        _label(canvas, 'SHIELDED', p.translate(0, _h * 1.13),
            const Color(0xff9cd9fb), 8);
      }
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    for (final m in _marches) {
      final a = m['from'] as List? ?? const [0, 0],
          b = m['to'] as List? ?? const [0, 0];
      final start =
          worldToScreen((a[0] as num).toDouble(), (a[1] as num).toDouble());
      final end =
          worldToScreen((b[0] as num).toDouble(), (b[1] as num).toDouble());
      canvas.drawLine(
          start,
          end,
          Paint()
            ..color = const Color(0x99f4d483)
            ..strokeWidth = 1.7);
      final departs = (m['depart_at_ms'] as num?)?.toInt() ?? now - 30000;
      final arrives = (m['arrive_at_ms'] as num?)?.toInt() ?? now + 30000;
      final progress = ((now - departs) / (arrives - departs).clamp(1, 1 << 30))
          .clamp(0.0, 1.0)
          .toDouble();
      final point = Offset(start.dx + (end.dx - start.dx) * progress,
          start.dy + (end.dy - start.dy) * progress);
      _art(
          canvas,
          'march',
          Rect.fromCenter(
              center: point.translate(0, -_h * .45),
              width: _w * .8,
              height: _h * 1.65));
    }
  }

  /// Small status bar so damaged targets and remaining resources are legible
  /// at strategy zoom without opening the tile dialog.
  void _hpBar(
      ui.Canvas canvas, Offset center, int current, int max, Color color) {
    final width = _w * .9, height = 3.2 * zoom;
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(height / 2)),
        Paint()..color = const Color(0x99091418));
    if (max <= 0 || current <= 0) return;
    final ratio = (current / max).clamp(0.0, 1.0);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(rect.left, rect.top, width * ratio, height),
            Radius.circular(height / 2)),
        Paint()..color = color);
  }

  void _label(
      ui.Canvas canvas, String text, Offset center, Color color, double size) {
    final painter = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                color: color,
                fontSize: size,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
                shadows: const [Shadow(color: Colors.black, blurRadius: 4)])),
        textDirection: TextDirection.ltr)
      ..layout();
    painter.paint(
        canvas, center - Offset(painter.width / 2, painter.height / 2));
  }
}
