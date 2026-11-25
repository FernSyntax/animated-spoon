// Golden UI coverage: every feature screen must render and be reachable from
// the navigation shell without a live backend.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kd_game/game_config.dart';
import 'package:kd_game/net.dart';
import 'package:kd_game/proto/kd.pb.dart';
import 'package:kd_game/screens.dart';
import 'package:kd_game/state.dart';
import 'package:provider/provider.dart';

GameState seededState() {
  final st = GameState(ApiClient('http://localhost:8080'))
    ..token = 'test-token'
    ..playerId = 'player-1'
    ..conn = ConnState.online
    ..player = {
      'cities': [
        {
          'id': 'city-1',
          'name': 'Capital',
          'x': 64,
          'y': 64,
          'is_capital': true,
          'resources': {
            'food': 1000,
            'wood': 1000,
            'stone': 1000,
            'iron': 1000,
            'gold': 1000,
          },
          'buildings': {'town_hall': 1, 'farm': 1},
          'busy_until_ms': 0,
          'shield_until_ms': 0,
          'troops': <dynamic>[],
        }
      ],
      'alliance_id': null,
      'alliance_role': null,
    }
    ..map = {
      'tiles': <dynamic>[],
      'entities': <dynamic>[],
      'cities': <dynamic>[],
      'marches': <dynamic>[],
      'fogged_chunks': <dynamic>[],
    };
  return st;
}

Future<void> openFeature(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Open game features'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text(label), 200,
      scrollable: find.byType(Scrollable).last);
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  for (final entry in {
    'Buildings': BuildingsScreen,
    'Shop': ShopScreen,
    'Research': ResearchScreen,
    'Troops': TroopsScreen,
    'Heroes & Items': HeroesItemsScreen,
    'Marches & Rallies': MarchesScreen,
    'Alliances': AllianceScreen,
    'Chat': ChatScreen,
    'Reports': ReportsScreen,
    'Rankings': RankingsScreen,
    'Settings': SettingsScreen,
  }.entries) {
    testWidgets('${entry.key} screen renders', (tester) async {
      final st = seededState();
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: st,
        child: const MaterialApp(home: HomeShell()),
      ));
      await openFeature(tester, entry.key);
      expect(find.byType(entry.value), findsOneWidget,
          reason: '${entry.key} must mount its screen widget');
      st.dispose();
    });
  }

  testWidgets('World screen renders from bottom navigation', (tester) async {
    final st = seededState();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: st,
      child: const MaterialApp(home: HomeShell()),
    ));
    await tester.tap(find.text('World'));
    await tester.pumpAndSettle();
    expect(find.textContaining('THE FRONTIER'), findsWidgets);
    st.dispose();
  });

  testWidgets('city shell shows the capital and status bar', (tester) async {
    final st = seededState();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: st,
      child: const MaterialApp(home: HomeShell()),
    ));
    expect(find.textContaining('Capital'), findsWidgets);
    expect(find.byTooltip('Open game features'), findsOneWidget);
    st.dispose();
  });

  testWidgets('Market screen mounts from the feature menu', (tester) async {
    final st = seededState();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: st,
      child: const MaterialApp(home: HomeShell()),
    ));
    await openFeature(tester, 'Market');
    expect(find.byType(MarketScreen), findsOneWidget);
    expect(find.text('MARKET EXCHANGE'), findsOneWidget);
    expect(find.text('Gold 1000'), findsOneWidget);
    expect(find.text('Buy'), findsWidgets);
    expect(find.text('Sell'), findsWidgets);
    st.dispose();
  });

  testWidgets('Market Buy and Sell buttons submit orders', (tester) async {
    final st = seededState()
      ..conn = ConnState.offline
      ..lastError = '';
    st.player['items'] = {'bundle_small': 3};
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: st,
      child: MaterialApp(home: MarketScreen(st: st)),
    ));
    expect(find.textContaining('Owned  3'), findsOneWidget);
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('Buy').first);
    expect(st.lastError, contains('offline'));
    st.lastError = '';
    await tester.tap(find.text('Sell').first);
    expect(st.lastError, contains('offline'));
    st.dispose();
  });

  testWidgets('building inspector shows Demolish for farm but not town hall',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final st = seededState()
      ..conn = ConnState.offline
      ..lastError = '';
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: st,
      child: const MaterialApp(home: HomeShell()),
    ));

    await tester.tap(find.byIcon(Icons.open_in_full_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Demolish'), findsNothing);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();

    await tester.tap(find
        .ancestor(
            of: find.textContaining(buildingsLabels['farm']!.toUpperCase()),
            matching: find.byType(InkWell))
        .first);
    await tester.pumpAndSettle();
    expect(find.text('Demolish'), findsWidgets);

    await tester.tap(find.text('Demolish').last);
    await tester.pumpAndSettle();
    expect(find.text('Demolish ${buildingsLabels['farm']}?'), findsOneWidget);
    await tester.tap(find.descendant(
        of: find.byType(AlertDialog), matching: find.text('Demolish')));
    await tester.pumpAndSettle();
    expect(st.lastError, contains('offline'));
    st.dispose();
  });

  testWidgets('inventory rows have a working Use button', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final st = seededState()
      ..conn = ConnState.offline
      ..lastError = '';
    st.player['items'] = {'bundle_small': 2, 'speed_5m': 1};
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: st,
      child: MaterialApp(home: HeroesItemsScreen(st: st)),
    ));
    expect(find.text('Use'), findsWidgets);
    expect(find.textContaining('Owned  2'), findsOneWidget);
    await tester.tap(find.text('Use').first);
    expect(st.lastError, contains('offline'));
    st.dispose();
  });

  testWidgets('state rejects commands while offline', (tester) async {
    final st = GameState(ApiClient('http://localhost:8080'));
    await st.submit('test', CommandPayload());
    expect(st.lastError, contains('offline'));
    expect(st.pending, isEmpty);
    st.dispose();
  });
}
