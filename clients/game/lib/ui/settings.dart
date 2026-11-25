part of '../screens.dart';

/// Session controls and local client settings.
class SettingsScreen extends StatelessWidget {
  final GameState st;
  const SettingsScreen({super.key, required this.st});
  @override
  Widget build(BuildContext context) => ListView(children: [
        _Section(title: 'Connection & account', children: [
          Text('Account: ${st.username ?? ''}  Player: ${st.playerId ?? ''}'),
          Text(
              'Realm: ${st.realmId}  State version: ${st.player['version'] ?? 0}'),
          Text(
              'Server time: ${DateTime.fromMillisecondsSinceEpoch((st.player['server_time_ms'] as num?)?.toInt() ?? 0)}'),
          const SizedBox(height: 8),
          Text('Realms: ${st.realms.map((r) => r['realm_id']).join(', ')}'),
          Wrap(spacing: 8, children: [
            for (final r in st.realms)
              ElevatedButton(
                  onPressed: () => st.joinRealm(r['realm_id'] as String),
                  child: Text('Switch to ${r['realm_id']}')),
          ]),
          const SizedBox(height: 8),
          ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
              onPressed: () async {
                await st.logout();
              }),
        ]),
      ]);
}
