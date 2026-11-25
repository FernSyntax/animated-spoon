/// Authentication and realm-selection screens.
///
/// These own only the session handshake; all gameplay screens live in
/// `screens.dart` and are reached once a player has joined a realm.
library;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game_config.dart';
import 'screens.dart';
import 'state.dart';

/// Sign-in / registration screen. Routes to realm selection once a session is
/// established, or straight to the game shell when a player is already joined.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

/// Holds the sign-in form controllers and drives the login/register requests.
class _AuthScreenState extends State<AuthScreen> {
  final user = TextEditingController(text: 'alice');
  final pass = TextEditingController(text: 'password123');
  bool busy = false;
  String? error;

  @override
  void dispose() {
    user.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<GameState>();
    if (st.loggedIn && st.playerId != null) return const HomeShell();
    if (st.loggedIn && st.realms.isNotEmpty) return const RealmSelectScreen();
    return Scaffold(
        body: Stack(fit: StackFit.expand, children: [
      Image.asset('$assetPrefix$splashArt',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const ColoredBox(color: Color(0xff102a29))),
      const DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
        Color(0xd8091718),
        Color(0x68101c1a),
        Color(0xb9081517)
      ], begin: Alignment.centerLeft, end: Alignment.centerRight))),
      SafeArea(
          child: Center(
              child: SingleChildScrollView(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1160),
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: LayoutBuilder(builder: (context, box) {
                            final compact = box.maxWidth < 760;
                            final intro = Column(
                                crossAxisAlignment: compact
                                    ? CrossAxisAlignment.center
                                    : CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                          color: const Color(0xe6152828),
                                          border: Border.all(
                                              color: const Color(0x6677d5b1)),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Icon(Icons.castle_rounded,
                                          color: Color(0xffffd07a), size: 36)),
                                  const SizedBox(height: 24),
                                  Text(gameName.toUpperCase(),
                                      style: const TextStyle(
                                          color: Color(0xfff3f4dc),
                                          letterSpacing: 2.4,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 8),
                                  const Text(gameTagline,
                                      style: TextStyle(
                                          color: Color(0xff8bd6bd),
                                          letterSpacing: 3,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  const Text(
                                      'Raise a kingdom.\nShape the realm.',
                                      style: TextStyle(
                                          fontSize: 44,
                                          height: 1.04,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xfff3f4dc))),
                                  const SizedBox(height: 14),
                                  const Text(
                                      'Build your city, rally your forces, and claim your place in a living world.',
                                      style: TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                          color: Color(0xffc2d0c5))),
                                  const SizedBox(height: 26),
                                  const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.public,
                                            color: Color(0xffffd07a), size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                            'PERSISTENT REALMS  ·  LIVE BATTLES',
                                            style: TextStyle(
                                                fontSize: 10,
                                                letterSpacing: 1.2,
                                                color: Color(0xffe4e8d0),
                                                fontWeight: FontWeight.bold))
                                      ]),
                                ]);
                            final signIn = Container(
                                width: 420,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                    color: const Color(0xe8102021),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                        color: const Color(0x427fd1ae)),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x88000000),
                                          blurRadius: 40,
                                          offset: Offset(0, 18))
                                    ]),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Enter the realm',
                                          style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 4),
                                      const Text(
                                          'Your city is waiting for you.',
                                          style: TextStyle(
                                              color: Color(0xffa7bbb4))),
                                      const SizedBox(height: 22),
                                      TextField(
                                          controller: user,
                                          decoration: const InputDecoration(
                                              labelText: 'Commander name',
                                              prefixIcon:
                                                  Icon(Icons.person_outline))),
                                      const SizedBox(height: 12),
                                      TextField(
                                          controller: pass,
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                              labelText: 'Password',
                                              prefixIcon:
                                                  Icon(Icons.lock_outline))),
                                      const SizedBox(height: 18),
                                      if (error != null)
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: Text(error!,
                                                style: const TextStyle(
                                                    color: Colors.redAccent))),
                                      if (busy)
                                        const Center(
                                            child: CircularProgressIndicator())
                                      else
                                        Row(children: [
                                          Expanded(
                                              child: ElevatedButton(
                                                  onPressed: () =>
                                                      _go(st, login: true),
                                                  child: const Text(
                                                      'Enter realm'))),
                                          const SizedBox(width: 10),
                                          Expanded(
                                              child: OutlinedButton(
                                                  onPressed: () =>
                                                      _go(st, login: false),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                          foregroundColor:
                                                              const Color(
                                                                  0xffd8e7dc),
                                                          side: const BorderSide(
                                                              color: Color(
                                                                  0xff506967))),
                                                  child: const Text(
                                                      'Create account'))),
                                        ]),
                                      const SizedBox(height: 14),
                                      const Center(
                                          child: Text(
                                              'Local commanders: alice / bob · password123',
                                              style: TextStyle(
                                                  color: Color(0xff829b95),
                                                  fontSize: 11))),
                                    ]));
                            return compact
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        intro,
                                        const SizedBox(height: 28),
                                        signIn
                                      ])
                                : Row(children: [
                                    Expanded(
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 70),
                                            child: intro)),
                                    signIn
                                  ]);
                          })))))),
    ]));
  }

  Future<void> _go(GameState st, {required bool login}) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (login) {
        await st.login(user.text.trim(), pass.text);
      } else {
        await st.register(user.text.trim(), pass.text);
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

/// Lists the realms the account belongs to and starts a session in the chosen shard.
class RealmSelectScreen extends StatelessWidget {
  const RealmSelectScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final st = context.watch<GameState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your realm'), actions: [
        IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await st.logout();
            })
      ]),
      body: Stack(fit: StackFit.expand, children: [
        Image.asset('$assetPrefix$splashArt', fit: BoxFit.cover),
        const ColoredBox(color: Color(0xb4091719)),
        Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(padding: const EdgeInsets.all(24), children: [
                  const Text('Find your frontier',
                      style:
                          TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                  const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 22),
                      child: Text(
                          'Every realm is a persistent world. Choose where your story begins.',
                          style: TextStyle(color: Color(0xffc0d2c7)))),
                  for (final r in st.realms)
                    Card(
                        child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: const CircleAvatar(
                                radius: 26,
                                backgroundColor: Color(0xff1b403a),
                                child: Icon(Icons.public,
                                    color: Color(0xffffd07a))),
                            title: Text('${r['name']}  ·  ${r['status']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                    '${r['players']} commanders  ·  shard ${r['shard']}')),
                            trailing: ElevatedButton(
                                onPressed: () async {
                                  await st.joinRealm(r['realm_id'] as String);
                                },
                                child: const Text('Enter realm')))),
                ]))),
      ]),
    );
  }
}
