/// Application entry point and global theme.
///
/// The gateway endpoint is injected at build time with
/// `--dart-define=KD_GATEWAY=http://host:port`, so the same binary can target
/// local development, a physical device on the LAN, or a deployment.
library;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth.dart';
import 'game_config.dart';
import 'net.dart';
import 'state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Endpoint comes from --dart-define=KD_GATEWAY=... at build/run time.
  const endpoint = String.fromEnvironment('KD_GATEWAY',
      defaultValue: 'http://localhost:8080');
  runApp(KdApp(api: ApiClient(endpoint)));
}

/// Root widget. Builds the dark game theme and provides the single [GameState]
/// instance shared by every screen.
class KdApp extends StatelessWidget {
  final ApiClient api;
  const KdApp({super.key, required this.api});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => GameState(api),
        child: MaterialApp(
          title: gameName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
                    seedColor: primary, brightness: Brightness.dark)
                .copyWith(
                    primary: primary, secondary: secondary, surface: surface),
            scaffoldBackgroundColor: const Color(0xff091416),
            canvasColor: const Color(0xff0d1b1e),
            cardColor: surface,
            appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xff0b191b),
                foregroundColor: Color(0xfff2f6e9),
                elevation: 0),
            cardTheme: CardThemeData(
                color: surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0x2637d6b0)))),
            inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xff0d1b1e),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff294144))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xff42d6b0), width: 1.5))),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: const Color(0xff08201c),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 13),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800))),
            textTheme: const TextTheme(
                headlineSmall:
                    TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.4),
                titleLarge: TextStyle(fontWeight: FontWeight.w800)),
          ),
          home: const AuthScreen(),
        ),
      );
}
