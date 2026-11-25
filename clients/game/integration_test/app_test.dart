// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kd_game/main.dart';
import 'package:kd_game/net.dart';

/// Drives sign-in, feature navigation, chat, and world-map controls against the
/// local acceptance backend using the documented development accounts.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const gateway = String.fromEnvironment('KD_GATEWAY',
      defaultValue: 'http://localhost:8080');

  testWidgets('players can reach game features and explore the world',
      (tester) async {
    await tester.pumpWidget(KdApp(api: ApiClient(gateway)));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Commander name'), 'alice');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'password123');
    await tester.tap(find.text('Enter realm').first);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Choose your realm'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Enter realm').first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.byTooltip('Open game features'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buildings'));
    await tester.pumpAndSettle();
    expect(find.text('CITY STEWARD'), findsOneWidget);
    expect(find.text('Farm'), findsOneWidget);

    await tester.tap(find.byTooltip('Open game features'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Message'), 'hello from the tablet');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Send'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byTooltip('Open game features'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log out'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.enterText(
        find.widgetWithText(TextField, 'Commander name'), 'bob');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'password123');
    await tester.tap(find.text('Enter realm').first);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Choose your realm'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Enter realm').first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.text('World').last);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('THE FRONTIER'), findsOneWidget);
    expect(find.text('Explore this sector'), findsOneWidget);
    await tester.tap(find.text('Explore this sector'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
