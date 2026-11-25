// Verifies the generated branding file cannot drift from game.config.json.
// A reskin only edits the JSON and re-runs `make generate`; if someone hand-edits
// the generated Dart instead, this test fails.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kd_game/game_config.dart';

void main() {
  final source = File('../../game.config.json').readAsStringSync();
  final cfg = jsonDecode(source) as Map<String, dynamic>;

  test('generated identity matches the config', () {
    final game = cfg['game'] as Map<String, dynamic>;
    expect(gameName, game['name']);
    expect(gameTagline, game['tagline']);
    expect(gameHeadline, game['headline']);
    expect(gameVersion, game['version']);
  });

  test('generated colours match the config', () {
    final theme = cfg['theme'] as Map<String, dynamic>;
    for (final entry in {
      'primary': primary,
      'secondary': secondary,
      'surface': surface,
      'background': background,
    }.entries) {
      final hex = (theme[entry.key] as String).replaceFirst('#', '');
      expect(entry.value.toARGB32(), int.parse('ff$hex', radix: 16));
    }
  });

  test('labels and building art come from the config', () {
    final labels = cfg['labels'] as Map<String, dynamic>;
    expect(buildingsLabels['farm'], (labels['buildings'] as Map)['farm']);
    expect(itemsLabels['shield_1d'], (labels['items'] as Map)['shield_1d']);
    final art = (cfg['assets'] as Map)['buildings'] as Map<String, dynamic>;
    expect(buildingArtFiles['farm'], 'building_farm');
    expect(art['farm'], 'building_farm.png');
  });
}
