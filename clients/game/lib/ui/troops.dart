part of '../screens.dart';

/// Unit training and hospital healing controls.
class TroopsScreen extends StatelessWidget {
  final GameState st;
  const TroopsScreen({super.key, required this.st});
  @override
  Widget build(BuildContext context) {
    final troops = (st.firstCity['troops'] as List?) ?? [];
    final wounded = (st.firstCity['wounded'] as List?) ?? [];
    final busyUntil =
        int.tryParse('${st.firstCity['busy_until_ms'] ?? 0}') ?? 0;
    final queueBusy = busyUntil > DateTime.now().millisecondsSinceEpoch;
    String label(dynamic t) => '${t['unit']} T${t['tier']}: ${t['count']}';
    int woundedCount(String unit, int tier) => wounded
        .where((troop) => troop['unit'] == unit && troop['tier'] == tier)
        .fold<int>(
            0, (sum, troop) => sum + ((troop['count'] as num?)?.toInt() ?? 0));
    return ListView(children: [
      _Section(title: 'Garrison', children: [
        if (troops.isEmpty)
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                  'Your garrison is quiet. Train troops before sending an army into the frontier.',
                  style: TextStyle(color: subtle))),
        for (final t in troops)
          ListTile(
              leading: Image.asset(
                  t['unit'] == 'ranged'
                      ? 'assets/art/unit_archer.png'
                      : 'assets/art/unit_cavalry.png',
                  width: 48,
                  height: 48),
              title: Text('${t['unit']} · Tier ${t['tier']}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              trailing: Text('${t['count']} ready',
                  style: const TextStyle(
                      color: accent, fontWeight: FontWeight.bold))),
        const Divider(),
        Text(
            'Hospital · ${wounded.isEmpty ? 'No wounded troops' : wounded.map(label).join('  ·  ')}',
            style: const TextStyle(color: subtle)),
      ]),
      _Section(title: 'Training grounds · x10 per order', children: [
        for (final u in units)
          for (var tier = 1; tier <= 3; tier++)
            ListTile(
              leading: Image.asset(
                  u == 'ranged'
                      ? 'assets/art/unit_archer.png'
                      : 'assets/art/unit_cavalry.png',
                  width: 44,
                  height: 44),
              title: Text('$u · Tier $tier',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                ElevatedButton(
                    onPressed: queueBusy
                        ? null
                        : () => st.submit(
                            'train $u',
                            CommandPayload(
                                trainTroops: TrainTroopsCmd(
                                    cityId:
                                        st.firstCity['id']?.toString() ?? '',
                                    unit: u,
                                    tier: tier,
                                    count: 10))),
                    child: const Text('Train x10')),
                const SizedBox(width: 6),
                OutlinedButton(
                    onPressed: queueBusy || woundedCount(u, tier) < 5
                        ? null
                        : () => st.submit(
                            'heal $u',
                            CommandPayload(
                                healTroops: HealTroopsCmd(
                                    cityId:
                                        st.firstCity['id']?.toString() ?? '',
                                    unit: u,
                                    tier: tier,
                                    count: 5))),
                    child: const Text('Heal x5')),
              ]),
            ),
      ]),
    ]);
  }
}
