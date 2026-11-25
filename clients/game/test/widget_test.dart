// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kd_game/game_config.dart';
import 'package:kd_game/main.dart';
import 'package:kd_game/net.dart';
import 'package:kd_game/screens.dart';
import 'package:kd_game/state.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('auth screen renders sign-in and register', (tester) async {
    await tester.pumpWidget(KdApp(api: ApiClient('http://localhost:8080')));
    expect(find.text('Enter realm'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Commander name'), findsOneWidget);
    expect(find.text(gameName.toUpperCase()), findsOneWidget);
  });

  testWidgets('branding is driven by the generated game config',
      (tester) async {
    await tester.pumpWidget(KdApp(api: ApiClient('http://localhost:8080')));
    expect(find.text(gameName.toUpperCase()), findsOneWidget);
    expect(find.text(gameTagline), findsOneWidget);
  });

  test('game state defaults are safe', () {
    final st = GameState(ApiClient('http://localhost:8080'));
    expect(st.loggedIn, isFalse);
    expect(st.cities, isEmpty);
    expect(st.conn, ConnState.offline);
  });

  testWidgets('alliance and research screens are reachable from game features',
      (tester) async {
    final st = GameState(ApiClient('http://localhost:8080'))
      ..token = 'test-token'
      ..playerId = 'test-player'
      ..player = {'cities': <dynamic>[]};
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: st,
      child: const MaterialApp(home: HomeShell()),
    ));

    await tester.tap(find.byTooltip('Open game features'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alliances'));
    await tester.pumpAndSettle();
    expect(find.text('Create alliance'), findsOneWidget);

    await tester.tap(find.byTooltip('Open game features'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Research').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Agriculture'), 200,
        scrollable: find.byType(Scrollable).last);
    expect(find.text('Agriculture'), findsOneWidget);

    st.dispose();
  });
}
