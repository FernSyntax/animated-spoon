part of '../screens.dart';

/// Technology catalogue driven by the authoritative player state.
class ResearchScreen extends StatelessWidget {
  final GameState st;
  const ResearchScreen({super.key, required this.st});
  @override
  Widget build(BuildContext context) {
    final done = (player()['research'] as Map?) ?? {};
    final researchUntil =
        int.tryParse('${st.player['research_busy_until_ms'] ?? 0}') ?? 0;
    final researchTarget = (st.player['research_busy_target'] ?? '').toString();
    final researchActive =
        researchUntil > DateTime.now().millisecondsSinceEpoch;
    return ListView(children: [
      ActiveQueuePanel(city: st.firstCity),
      if (researchActive)
        Card(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: ListTile(
            leading: const Icon(Icons.science, color: gold),
            title:
                Text('Researching ${techs[researchTarget] ?? researchTarget}'),
            subtitle: Text(
                'Completes ${DateTime.fromMillisecondsSinceEpoch(researchUntil)}'),
            trailing: const Chip(label: Text('QUEUE ACTIVE')),
          ),
        ),
      _Section(title: 'Research · one scholar queue', children: [
        for (final e in techs.entries)
          ListTile(
            leading: Image.asset('assets/art/building_academy.png',
                width: 46, height: 46),
            title: Text(e.value,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('Level ${done[e.key] ?? 0}/3'),
            trailing: ElevatedButton(
                onPressed: researchActive
                    ? null
                    : () => st.submit(
                        'research ${e.key}',
                        CommandPayload(
                            startResearch: StartResearchCmd(tech: e.key))),
                child: const Text('Research')),
          ),
      ]),
    ]);
  }

  Map<String, dynamic> player() => st.player;
}
