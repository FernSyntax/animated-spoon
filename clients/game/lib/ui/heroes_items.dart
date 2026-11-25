part of '../screens.dart';

/// Hero recruitment, levelling and consumable item use.
class HeroesItemsScreen extends StatelessWidget {
  final GameState st;
  const HeroesItemsScreen({super.key, required this.st});
  @override
  Widget build(BuildContext context) {
    final hs = (st.player['heroes'] as Map?) ?? {};
    final assignments = (st.player['hero_assignment'] as Map?) ?? {};
    final its = (st.player['items'] as Map?) ?? {};
    final city = st.firstCity;
    final cityId = (city['id'] ?? '').toString();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cityQueueActive =
        (int.tryParse('${city['busy_until_ms'] ?? 0}') ?? 0) > now;
    final researchQueueActive =
        (int.tryParse('${st.player['research_busy_until_ms'] ?? 0}') ?? 0) >
            now;
    void useItem(String item, {String target = ''}) {
      // Speedups use a 'research' sentinel; every other item targets our city.
      st.submit(
          'use $item',
          CommandPayload(
              useItem: UseItemCmd(
                  item: item, targetCityId: target.isEmpty ? cityId : target)));
    }

    void useSpeedup(String item, String target, BuildContext dialogContext) {
      useItem(item, target: target);
      Navigator.of(dialogContext).pop();
    }

    return ListView(children: [
      _Section(title: 'Heroes', children: [
        for (final e in heroes.entries)
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                    color: const Color(0xff213a37),
                    width: 56,
                    height: 56,
                    child: Image.asset('assets/art/hero_${e.key}.png',
                        fit: BoxFit.cover))),
            title: Text(e.value,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(hs.containsKey(e.key)
                ? 'Level ${hs[e.key]} · ${assignments.containsValue(e.key) ? 'On a march' : 'Automatically joins your next march'}'
                : 'Recruit for ${heroRecruitGold[e.key]} gold'),
            trailing: hs.containsKey(e.key)
                ? const Icon(Icons.verified, color: accent)
                : ElevatedButton(
                    onPressed:
                        (num.tryParse('${st.resources['gold'] ?? 0}') ?? 0) <
                                (heroRecruitGold[e.key] ?? 0)
                            ? null
                            : () => st.submit(
                                'recruit ${e.key}',
                                CommandPayload(
                                    recruitHero: RecruitHeroCmd(hero: e.key))),
                    child: const Text('Recruit')),
          ),
      ]),
      _Section(title: 'Inventory', children: [
        for (final e in items.entries)
          ListTile(
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/art/item_bundle.png',
                    width: 48, height: 48, fit: BoxFit.cover)),
            title: Text(e.value,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(
                'Owned  ${its[e.key] ?? 0} · ${e.key.startsWith('speed_') ? 'reduces an active queue timer' : e.key == 'scout_kit' ? 'reveals nearby map tiles' : 'adds resources or protection'}'),
            trailing: ElevatedButton(
                onPressed: e.key.startsWith('speed_') &&
                        !cityQueueActive &&
                        !researchQueueActive
                    ? null
                    : e.key.startsWith('speed_') &&
                            cityQueueActive &&
                            researchQueueActive
                        ? () => showDialog<void>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                                  title: Text('Use ${items[e.key]}'),
                                  content: const Text(
                                      'Choose the active queue to speed up.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => useSpeedup(
                                          e.key, cityId, dialogContext),
                                      child: const Text('City construction'),
                                    ),
                                    TextButton(
                                      onPressed: () => useSpeedup(
                                          e.key, 'research', dialogContext),
                                      child: const Text('Research'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ))
                        : e.key.startsWith('speed_')
                            ? () => useSpeedup(
                                e.key,
                                researchQueueActive ? 'research' : cityId,
                                context)
                            : () => useItem(e.key),
                child: Text(e.key.startsWith('speed_')
                    ? cityQueueActive
                        ? 'Speed up city'
                        : researchQueueActive
                            ? 'Speed up research'
                            : 'No active queue'
                    : e.key == 'scout_kit'
                        ? 'Reveal map'
                        : 'Use')),
          ),
      ]),
    ]);
  }
}
