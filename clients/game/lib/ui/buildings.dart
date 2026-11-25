part of '../screens.dart';

/// Compact resource chip used by the building catalogue header.
class _ResourcePill extends StatelessWidget {
  final String name;
  final Object amount;
  const _ResourcePill({required this.name, required this.amount});
  @override
  Widget build(BuildContext context) {
    const icons = {
      'food': Icons.grass,
      'wood': Icons.forest,
      'stone': Icons.landscape,
      'iron': Icons.hardware,
      'gold': Icons.monetization_on
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xc9111c1d),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x667b916c))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icons[name] ?? Icons.circle, size: 13, color: gold),
        const SizedBox(width: 5),
        Text('$amount',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

/// Building catalogue with costs and one-tap upgrade actions.
class BuildingsScreen extends StatelessWidget {
  final GameState st;
  const BuildingsScreen({super.key, required this.st});
  @override
  Widget build(BuildContext context) {
    final built = (st.firstCity['buildings'] as Map?) ?? {};
    final city = st.firstCity;
    final queued = (int.tryParse('${city['busy_until_ms'] ?? 0}') ?? 0) >
        DateTime.now().millisecondsSinceEpoch;
    final resources = (city['resources'] as Map?) ?? {};
    return ListView(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 198,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset('assets/art/city_own.png',
                  fit: BoxFit.cover, alignment: Alignment.centerRight),
              const DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                Color(0xef0b1719),
                Color(0x99101b1b),
                Color(0x08101b1b)
              ], begin: Alignment.centerLeft, end: Alignment.centerRight))),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('CITY STEWARD',
                          style: TextStyle(
                              color: gold,
                              letterSpacing: 2,
                              fontSize: 10,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 5),
                      Text(city['name']?.toString() ?? 'Your capital',
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w900)),
                      Text(
                          'Town Hall ${built['town_hall'] ?? 1}  ·  ${buildings.length} BUILDING SITES',
                          style: const TextStyle(
                              color: Color(0xffd5e2d9),
                              fontSize: 10,
                              letterSpacing: 1)),
                      const SizedBox(height: 12),
                      Wrap(spacing: 7, runSpacing: 6, children: [
                        for (final key in [
                          'food',
                          'wood',
                          'stone',
                          'iron',
                          'gold'
                        ])
                          _ResourcePill(
                              name: key,
                              amount: (resources[key] ?? 0) as Object),
                      ]),
                    ],
                  )),
            ]),
          ),
        ),
      ),
      ActiveQueuePanel(city: city),
      Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
          child: Row(children: [
            const Icon(Icons.castle_rounded, color: gold),
            const SizedBox(width: 9),
            const Expanded(
                child: Text('City projects',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
            Text(queued ? 'QUEUE ACTIVE' : 'READY TO BUILD',
                style: TextStyle(
                    color: queued ? const Color(0xffffc56e) : accent,
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900)),
          ])),
      Padding(
          padding: const EdgeInsets.all(14),
          child: LayoutBuilder(builder: (context, box) {
            final columns = box.maxWidth > 1000
                ? 3
                : box.maxWidth > 620
                    ? 2
                    : 1;
            final width = (box.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(spacing: 12, runSpacing: 12, children: [
              for (final e in buildings.entries)
                SizedBox(
                    width: width,
                    child: _BuildingCard(
                        keyName: e.key,
                        title: e.value,
                        level: (built[e.key] as num?)?.toInt() ?? 0,
                        cityId: city['id']?.toString() ?? '',
                        queued: queued,
                        onUpgrade: () => st.submit(
                            'upgrade ${e.key}',
                            CommandPayload(
                                upgradeBuilding: UpgradeBuildingCmd(
                                    cityId: city['id']?.toString() ?? '',
                                    building: e.key)))))
            ]);
          })),
    ]);
  }
}

/// One building row with its level, cost and upgrade action.
class _BuildingCard extends StatelessWidget {
  final String keyName, title, cityId;
  final int level;
  final bool queued;
  final VoidCallback onUpgrade;
  const _BuildingCard(
      {required this.keyName,
      required this.title,
      required this.level,
      required this.cityId,
      required this.queued,
      required this.onUpgrade});
  @override
  Widget build(BuildContext context) => Card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
                height: 145,
                width: double.infinity,
                child: Stack(fit: StackFit.expand, children: [
                  const ColoredBox(color: Color(0xff19302d)),
                  Image.asset('assets/art/${buildingArt(keyName)}.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.apartment, size: 64, color: accent)),
                  Align(
                      alignment: Alignment.topRight,
                      child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: const Color(0xdd091416),
                              borderRadius: BorderRadius.circular(30)),
                          child: Text('LVL $level',
                              style: const TextStyle(
                                  color: gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1)))),
                ]))),
        Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(buildingLore[keyName] ?? '',
                  style: const TextStyle(
                      color: subtle, fontSize: 11, height: 1.35)),
              const SizedBox(height: 12),
              ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                      value: (level / 10).clamp(0.0, 1.0).toDouble(),
                      minHeight: 4,
                      color: accent,
                      backgroundColor: const Color(0xff2b3b3a))),
              const SizedBox(height: 11),
              Row(children: [
                Text('NEXT  ${level + 1}',
                    style: const TextStyle(
                        color: subtle,
                        letterSpacing: .8,
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
                const Spacer(),
                ElevatedButton.icon(
                    onPressed: queued ? null : onUpgrade,
                    icon: Icon(
                        queued ? Icons.hourglass_top : Icons.arrow_upward,
                        size: 15),
                    label: Text(queued ? 'QUEUE BUSY' : 'UPGRADE'))
              ]),
            ])),
      ]));
}
