part of '../screens.dart';

/// Coloured legend marker for one map entity category.
class _MapLegendDot extends StatelessWidget {
  final Color color;
  final String text;
  const _MapLegendDot({required this.color, required this.text});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text,
            style: const TextStyle(
                fontSize: 8,
                letterSpacing: .6,
                fontWeight: FontWeight.w800,
                color: Color(0xffcfddd5)))
      ]);
}

/// Active marches and rallies with recall/join/cancel controls.
class MarchesScreen extends StatelessWidget {
  final GameState st;
  const MarchesScreen({super.key, required this.st});
  @override
  Widget build(BuildContext context) {
    final marches = (st.player['marches'] as List?) ?? [];
    final rallies = (st.map['rallies'] as List?) ?? [];
    return ListView(children: [
      _Section(title: 'Your marches', children: [
        if (marches.isEmpty) const Text('No active marches.'),
        for (final m in marches)
          ListTile(
            title: Text(
                '${missions[m['mission']] ?? m['mission']} → (${m['to'][0]}, ${m['to'][1]})'),
            subtitle: Text(
                '${m['state']} · arrives ${DateTime.fromMillisecondsSinceEpoch((m['arrive_at_ms'] as num).toInt())}'),
            trailing: ElevatedButton(
                onPressed: () => st.submit(
                    'recall',
                    CommandPayload(
                        recall: RecallCmd(marchId: m['id']?.toString() ?? ''))),
                child: const Text('Recall')),
          ),
      ]),
      _Section(title: 'Rallies', children: [
        const Text(
            'Create a rally from the map tile dialog. Join/cancel below.'),
        for (final r in rallies)
          ListTile(
            title: Text('Rally ${r['rally_id']?.toString().substring(0, 8)}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton(
                  onPressed: () => st.submit(
                      'join rally',
                      CommandPayload(
                          rallyJoin: RallyJoinCmd(
                              rallyId: r['rally_id']?.toString() ?? '',
                              troops: [
                            TroopSend(unit: 'infantry', tier: 1, count: 10)
                          ]))),
                  child: const Text('Join')),
              const SizedBox(width: 6),
              OutlinedButton(
                  onPressed: () => st.submit(
                      'cancel rally',
                      CommandPayload(
                          rallyCancel: RallyCancelCmd(
                              rallyId: r['rally_id']?.toString() ?? ''))),
                  child: const Text('Cancel')),
            ]),
          ),
      ]),
    ]);
  }
}
