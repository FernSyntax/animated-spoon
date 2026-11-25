part of '../screens.dart';

/// Reusable widgets used by the city screen (plots, queue, inspector).

/// Live countdown for the city's currently queued action.
class ActiveQueuePanel extends StatefulWidget {
  final Map<String, dynamic> city;
  final VoidCallback? onOpenBuildings;
  const ActiveQueuePanel({super.key, required this.city, this.onOpenBuildings});
  @override
  State<ActiveQueuePanel> createState() => _ActiveQueuePanelState();
}

/// Ticks a local clock so the busy countdown updates without server polling.
class _ActiveQueuePanelState extends State<ActiveQueuePanel> {
  Timer? _clock;
  int now = DateTime.now().millisecondsSinceEpoch;
  bool synced = false;
  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => now = DateTime.now().millisecondsSinceEpoch);
      final until = int.tryParse('${widget.city['busy_until_ms'] ?? 0}') ?? 0;
      if (until > 0 && now >= until && !synced) {
        synced = true;
        context.read<GameState>().refresh();
      }
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ActiveQueuePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city['busy_until_ms'] != widget.city['busy_until_ms']) {
      synced = false;
    }
  }

  String _time(int ms) {
    final sec = (ms / 1000).ceil().clamp(0, 999999);
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final s = sec % 60;
    return h > 0
        ? '${h}h ${m.toString().padLeft(2, '0')}m'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final until = int.tryParse('${widget.city['busy_until_ms'] ?? 0}') ?? 0;
    final action = (widget.city['busy_action'] ?? '').toString();
    final active = until > now;
    final targetKey = (widget.city['busy_target'] ?? '').toString();
    final target = targetKey.isEmpty
        ? 'the next structure'
        : targetKey.replaceAll('_', ' ');
    final label = action == 'building'
        ? 'Upgrading $target'
        : action.isEmpty
            ? 'Queue ready for orders'
            : '${action.replaceAll('_', ' ')} in progress';
    final image = buildings.containsKey(targetKey)
        ? buildingArt(targetKey)
        : 'building_town_hall';
    return Container(
        margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xff173734), Color(0xff122426)]),
            border: Border.all(color: const Color(0xff3d7463)),
            borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                  color: const Color(0xff0e211f),
                  borderRadius: BorderRadius.circular(14)),
              child: Image.asset('assets/art/$image.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.construction, color: gold, size: 30))),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('CITY WORKSHOP · QUEUE 1/1',
                    style: TextStyle(
                        color: Color(0xff96c9ae),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        fontSize: 9)),
                const SizedBox(height: 3),
                Text(label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                active
                    ? const LinearProgressIndicator(
                        minHeight: 4,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: accent,
                        backgroundColor: Color(0xff29413a))
                    : const Text(
                        'Choose a structure to begin your next upgrade.',
                        style: TextStyle(color: subtle, fontSize: 11)),
              ])),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (active)
              Text(_time(until - now),
                  style: const TextStyle(
                      color: gold,
                      fontFeatures: [ui.FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w900,
                      fontSize: 18)),
            Text(active ? 'REMAINING' : 'IDLE',
                style: const TextStyle(
                    color: subtle, fontSize: 9, letterSpacing: 1)),
            if (widget.onOpenBuildings != null)
              TextButton(
                  onPressed: widget.onOpenBuildings,
                  child: const Text('Manage')),
          ]),
        ]));
  }
}

/// Screen-space anchor for one building plot on the isometric city image.
class _CityPlot {
  final String keyName;
  final Offset artCenter;
  const _CityPlot(this.keyName, this.artCenter);
}

const _cityPlots = [
  // Coordinates are pad centers on city_foundation.png. They are transformed
  // through the same BoxFit.cover crop as the artwork, so the buildings stay
  // planted on their stone lots at every screen aspect ratio.
  _CityPlot('town_hall', Offset(280, 265)),
  _CityPlot('farm', Offset(544, 265)),
  _CityPlot('barracks', Offset(810, 265)),
  _CityPlot('academy', Offset(1080, 265)),
  _CityPlot('lumber_mill', Offset(216, 455)),
  _CityPlot('quarry', Offset(446, 455)),
  _CityPlot('iron_mine', Offset(994, 455)),
  _CityPlot('market', Offset(1260, 455)),
  _CityPlot('warehouse', Offset(260, 670)),
  _CityPlot('hospital', Offset(535, 670)),
  _CityPlot('wall', Offset(820, 670)),
  _CityPlot('embassy', Offset(1200, 670)),
];

/// Upgrade controls for a selected building plot.
class _BuildingOrders extends StatelessWidget {
  final GameState st;
  final String keyName;
  final String cityId;
  final bool queued;
  const _BuildingOrders(
      {required this.st,
      required this.keyName,
      required this.cityId,
      required this.queued});

  @override
  Widget build(BuildContext context) {
    if (keyName == 'academy') {
      final done = (st.player['research'] as Map?) ?? {};
      return _orderPanel(
        'ACADEMY · RESEARCH',
        Icons.auto_awesome,
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final tech in techs.entries)
            OutlinedButton.icon(
                onPressed: () => st.submit(
                    'research ${tech.key}',
                    CommandPayload(
                        startResearch: StartResearchCmd(tech: tech.key))),
                icon: const Icon(Icons.science_outlined, size: 16),
                label: Text('${tech.value}  ${done[tech.key] ?? 0}/3')),
        ]),
      );
    }
    if (keyName == 'barracks') {
      final garrison = (st.firstCity['troops'] as List?) ?? [];
      return _orderPanel(
        'BARRACKS · GARRISON ${garrison.fold<int>(0, (n, t) => n + ((t['count'] as num?)?.toInt() ?? 0))}',
        Icons.shield_outlined,
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              'Train a squad of ten. The army queue starts a march from the World Map.',
              style: TextStyle(color: subtle, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final unit in units)
              for (var tier = 1; tier <= 3; tier++)
                OutlinedButton.icon(
                    onPressed: queued
                        ? null
                        : () => st.submit(
                            'train $unit',
                            CommandPayload(
                                trainTroops: TrainTroopsCmd(
                                    cityId: cityId,
                                    unit: unit,
                                    tier: tier,
                                    count: 10))),
                    icon: const Icon(Icons.add, size: 15),
                    label: Text('${unit.toUpperCase()} T$tier')),
          ]),
        ]),
      );
    }
    if (keyName == 'hospital') {
      final wounded = (st.firstCity['wounded'] as List?) ?? [];
      return _orderPanel(
        'HOSPITAL · RECOVERY',
        Icons.health_and_safety_outlined,
        wounded.isEmpty
            ? const Text('All troops are fit for duty.',
                style: TextStyle(color: subtle))
            : Wrap(spacing: 8, runSpacing: 8, children: [
                for (final troop in wounded)
                  OutlinedButton.icon(
                      onPressed: queued
                          ? null
                          : () => st.submit(
                              'heal ${troop['unit']}',
                              CommandPayload(
                                  healTroops: HealTroopsCmd(
                                      cityId: cityId,
                                      unit: troop['unit'].toString(),
                                      tier:
                                          (troop['tier'] as num?)?.toInt() ?? 1,
                                      count: math
                                          .min(
                                              5,
                                              (troop['count'] as num?)
                                                      ?.toInt() ??
                                                  0)
                                          .toInt()))),
                      icon: const Icon(Icons.favorite_outline, size: 16),
                      label: Text('Heal ${troop['unit']} · ${troop['count']}')),
              ]),
      );
    }
    if (keyName == 'market' || keyName == 'warehouse') {
      final resources = st.resources;
      return _orderPanel(
          keyName == 'market' ? 'MARKET · CITY STORES' : 'WAREHOUSE · STORES',
          Icons.inventory_2_outlined,
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final resource in ['food', 'wood', 'stone', 'iron', 'gold'])
              Chip(
                  avatar: const Icon(Icons.circle, size: 10, color: gold),
                  label: Text(
                      '${resource.toUpperCase()}  ${resources[resource] ?? 0}')),
          ]));
    }
    if (keyName == 'embassy') {
      return _orderPanel(
          'EMBASSY · FIELD COMMAND',
          Icons.groups_2_outlined,
          Text(
              st.alliance.isEmpty
                  ? 'Join an alliance to coordinate reinforcements and rallies from the World Map.'
                  : 'Alliance ${st.alliance['id']} · ${st.alliance['role']}',
              style: const TextStyle(color: subtle, height: 1.4)));
    }
    return const SizedBox.shrink();
  }

  Widget _orderPanel(String title, IconData icon, Widget content) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xff17292a),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xff34534b))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: gold, size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    color: gold,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 12),
          content,
        ]),
      );
}

/// One interactive building plot on the city image.
class _CityBuildingSpot extends StatelessWidget {
  final String keyName;
  final int level;
  final bool selected;
  final double size;
  final VoidCallback onTap;
  const _CityBuildingSpot(
      {required this.keyName,
      required this.level,
      required this.selected,
      required this.size,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = buildings[keyName] ?? 'Structure';
    return Tooltip(
      message: '$title · ${level == 0 ? 'Build' : 'Level $level'}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
            decoration: BoxDecoration(
                color: selected ? const Color(0x335addb6) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: selected
                    ? Border.all(color: const Color(0xffc1dc8e), width: 1.5)
                    : Border.all(color: Colors.transparent)),
            child: Stack(fit: StackFit.expand, children: [
              if (level > 0)
                Image.asset('assets/art/${buildingArt(keyName)}.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.location_city_rounded,
                        color: Color(0xffe3d0a0),
                        size: 42))
              else
                Center(
                    child: Container(
                        width: size * .58,
                        height: size * .42,
                        decoration: BoxDecoration(
                            color: const Color(0xd81a302c),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xfff4d17f), width: 1.3),
                            boxShadow: const [
                              BoxShadow(color: Color(0x70000000), blurRadius: 9)
                            ]),
                        child: const Icon(Icons.add_business_rounded,
                            color: gold, size: 28))),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Container(
                          constraints: BoxConstraints(maxWidth: size * 1.35),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xe9101a19),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: selected
                                      ? const Color(0xffe6c473)
                                      : const Color(0x664c6653))),
                          child: Text(
                              level == 0
                                  ? '＋  BUILD'
                                  : '${title.toUpperCase()}  ·  $level',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Color(0xfff1f2df),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .4))))),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Status pill showing the active build queue and its progress indicator.
class _CityQueuePill extends StatelessWidget {
  final Map<String, dynamic> city;
  final bool queued;
  final bool expanded;
  const _CityQueuePill(
      {required this.city, required this.queued, this.expanded = false});
  @override
  Widget build(BuildContext context) {
    final action = (city['busy_action'] ?? '').toString();
    final target = (city['busy_target'] ?? '').toString().replaceAll('_', ' ');
    final name = queued
        ? action == 'building'
            ? 'Upgrading $target'
            : '${action.replaceAll('_', ' ')} in progress'
        : 'Construction queue is ready';
    return Container(
      width: expanded ? double.infinity : null,
      padding: EdgeInsets.symmetric(
          horizontal: expanded ? 12 : 11, vertical: expanded ? 11 : 8),
      decoration: BoxDecoration(
          color: const Color(0xe910211f),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x88699b69))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.construction_rounded, color: gold, size: 16),
        const SizedBox(width: 7),
        Flexible(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: queued ? const Color(0xffffe0a1) : Colors.white,
                    fontSize: expanded ? 11 : 9,
                    fontWeight: FontWeight.w800))),
        if (queued) ...[
          const SizedBox(width: 8),
          const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: accent)),
        ],
      ]),
    );
  }
}
