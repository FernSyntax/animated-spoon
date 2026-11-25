part of '../screens.dart';

/// City view: building plots, queue state and the building inspector.
class CityScreen extends StatefulWidget {
  final GameState st;
  const CityScreen({super.key, required this.st});
  @override
  State<CityScreen> createState() => _CityScreenState();
}

/// Owns plot selection and dispatches upgrade orders from the inspector.
class _CityScreenState extends State<CityScreen> {
  String selectedKey = 'town_hall';

  void _upgrade(String keyName, String cityId) {
    widget.st.submit(
        'upgrade $keyName',
        CommandPayload(
            upgradeBuilding:
                UpgradeBuildingCmd(cityId: cityId, building: keyName)));
  }

  /// Demolition is irreversible, so the order is gated behind a dialog.
  Future<void> _confirmDemolish(
      BuildContext context, String keyName, String cityId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Demolish ${buildings[keyName] ?? keyName}?'),
        content: const Text(
            'This clears the plot and removes the structure and its level. It cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Demolish')),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.st.submit(
        'demolish $keyName',
        CommandPayload(
            demolishBuilding:
                DemolishBuildingCmd(cityId: cityId, building: keyName)));
  }

  Widget _demolishButton(BuildContext context, String keyName, String cityId,
          {required bool queued}) =>
      OutlinedButton.icon(
        onPressed:
            queued ? null : () => _confirmDemolish(context, keyName, cityId),
        icon: const Icon(Icons.delete_outline, size: 16),
        label: const Text('Demolish'),
        style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xffffb4a2),
            side: const BorderSide(color: Color(0x99d98b75))),
      );

  @override
  Widget build(BuildContext context) {
    final st = widget.st;
    final city = st.firstCity;
    final levels = Map<String, dynamic>.from(
        (city['buildings'] as Map?) ?? const <dynamic, dynamic>{});
    final queued = (int.tryParse('${city['busy_until_ms'] ?? 0}') ?? 0) >
        DateTime.now().millisecondsSinceEpoch;
    return LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= 840;
      final inspector =
          _inspector(context, city, levels, queued, compact: !wide);
      return wide
          ? Row(children: [
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _cityStage(city, levels, queued))),
              SizedBox(width: 316, child: inspector),
            ])
          : Column(children: [
              Expanded(child: _cityStage(city, levels, queued)),
              SizedBox(height: 206, child: inspector),
            ]);
    });
  }

  Widget _cityStage(Map<String, dynamic> city, Map<String, dynamic> levels,
          bool queued) =>
      LayoutBuilder(
        builder: (context, box) {
          final lotSize = math
              .min(box.maxWidth * .14, box.maxHeight * .22)
              .clamp(56.0, 142.0)
              .toDouble();
          final imageScale =
              math.max(box.maxWidth / 1536, box.maxHeight / 1024).toDouble();
          final imageOffset = Offset((box.maxWidth - 1536 * imageScale) / 2,
              (box.maxHeight - 1024 * imageScale) / 2);
          final cityLevel = (levels['town_hall'] as num?)?.toInt() ?? 0;
          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(fit: StackFit.expand, children: [
              Image.asset('assets/art/city_foundation.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: Color(0xff385b45))),
              const DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                    Color(0x16101a20),
                    Color(0x00101a20),
                    Color(0x44101a20)
                  ]))),
              Positioned(
                  left: 16,
                  top: 14,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: const Color(0xd9122020),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x667c9f71))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(city['name']?.toString() ?? 'Your Capital',
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 3),
                            Text(
                                'CAPITAL  ·  TOWN HALL $cityLevel  ·  ${city['x'] ?? 0}, ${city['y'] ?? 0}',
                                style: const TextStyle(
                                    color: Color(0xffd5e3d1),
                                    fontSize: 9,
                                    letterSpacing: .8,
                                    fontWeight: FontWeight.w800)),
                          ]))),
              for (final plot in _cityPlots)
                Builder(builder: (context) {
                  final center = Offset(plot.artCenter.dx * imageScale,
                          plot.artCenter.dy * imageScale) +
                      imageOffset;
                  final level = (levels[plot.keyName] as num?)?.toInt() ?? 0;
                  return Positioned(
                    left: center.dx - lotSize / 2,
                    top: center.dy - lotSize * .91,
                    width: lotSize,
                    height: lotSize + 22,
                    child: _CityBuildingSpot(
                        keyName: plot.keyName,
                        level: level,
                        selected: selectedKey == plot.keyName,
                        size: lotSize,
                        onTap: () {
                          setState(() => selectedKey = plot.keyName);
                          _openBuilding(
                              context,
                              plot.keyName,
                              buildings[plot.keyName] ?? 'Structure',
                              buildingArt(plot.keyName),
                              level,
                              queued,
                              city['id']?.toString() ?? '');
                        }),
                  );
                }),
              Positioned(
                  left: 16,
                  bottom: 14,
                  child: _CityQueuePill(city: city, queued: queued)),
            ]),
          );
        },
      );

  Widget _inspector(BuildContext context, Map<String, dynamic> city,
      Map<String, dynamic> levels, bool queued,
      {required bool compact}) {
    final title = buildings[selectedKey] ?? 'Structure';
    final level = (levels[selectedKey] as num?)?.toInt() ?? 0;
    final art = buildingArt(selectedKey);
    final content = Container(
      margin: EdgeInsets.fromLTRB(compact ? 8 : 0, 8, 8, 8),
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
          color: const Color(0xff101e20),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xff34534b)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x50000000), blurRadius: 22, offset: Offset(0, 8))
          ]),
      child: compact
          ? Row(children: [
              _selectedArt(art, 84),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    const Text('SELECTED BUILDING',
                        style: TextStyle(
                            color: gold,
                            fontSize: 9,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w900)),
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900)),
                    Text(
                        level == 0
                            ? 'Open plot · ready to build'
                            : 'Level $level · Tap to open',
                        style: const TextStyle(color: subtle, fontSize: 10)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                        onPressed: queued
                            ? null
                            : () => _upgrade(
                                selectedKey, city['id']?.toString() ?? ''),
                        icon: const Icon(Icons.upgrade_rounded, size: 16),
                        label: Text(level == 0 ? 'BUILD' : 'UPGRADE')),
                  ])),
              IconButton(
                  tooltip: 'Open building details',
                  onPressed: () => _openBuilding(context, selectedKey, title,
                      art, level, queued, city['id']?.toString() ?? ''),
                  icon: const Icon(Icons.open_in_full_rounded, color: gold)),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.castle_rounded, color: gold, size: 17),
                const SizedBox(width: 7),
                const Expanded(
                    child: Text('CITY COMMAND',
                        style: TextStyle(
                            color: gold,
                            letterSpacing: 1.3,
                            fontSize: 10,
                            fontWeight: FontWeight.w900))),
                Text(
                    '${_cityPlots.where((p) => ((levels[p.keyName] as num?)?.toInt() ?? 0) > 0).length}/${_cityPlots.length}',
                    style: const TextStyle(
                        color: subtle,
                        fontSize: 10,
                        fontWeight: FontWeight.w800))
              ]),
              const SizedBox(height: 10),
              _CityQueuePill(city: city, queued: queued, expanded: true),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xff29413a)),
              const SizedBox(height: 12),
              Row(children: [
                _selectedArt(art, 102),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('BUILDING DETAILS',
                          style: TextStyle(
                              color: accent,
                              letterSpacing: 1.1,
                              fontSize: 9,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900)),
                      Text(level == 0 ? 'Available plot' : 'LEVEL $level',
                          style: const TextStyle(
                              color: gold,
                              letterSpacing: 1,
                              fontSize: 9,
                              fontWeight: FontWeight.w800)),
                    ])),
              ]),
              const SizedBox(height: 10),
              Text(buildingLore[selectedKey] ?? '',
                  style: const TextStyle(
                      color: Color(0xffbfd0c5), fontSize: 11, height: 1.4)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => _openBuilding(
                            context,
                            selectedKey,
                            title,
                            art,
                            level,
                            queued,
                            city['id']?.toString() ?? ''),
                        child:
                            const Icon(Icons.open_in_full_rounded, size: 17))),
                const SizedBox(width: 8),
                Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                        onPressed: queued
                            ? null
                            : () => _upgrade(
                                selectedKey, city['id']?.toString() ?? ''),
                        icon: const Icon(Icons.upgrade_rounded, size: 16),
                        label: Text(level == 0
                            ? 'BUILD · LV 1'
                            : 'UPGRADE · LV ${level + 1}'))),
              ]),
              if (selectedKey != 'town_hall') ...[
                const SizedBox(height: 6),
                Align(
                    alignment: Alignment.centerLeft,
                    child: _demolishButton(
                        context, selectedKey, city['id']?.toString() ?? '',
                        queued: queued)),
              ],
              const SizedBox(height: 4),
              Text(
                  queued
                      ? 'Construction queue is occupied. Your next project is ready when it completes.'
                      : 'Tap any city structure to inspect it. Upgrades run in the city queue.',
                  style: const TextStyle(color: subtle, fontSize: 9)),
            ]),
    );
    return compact ? content : SingleChildScrollView(child: content);
  }

  Widget _selectedArt(String asset, double size) => Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: const Color(0xff1b302d),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x5578a574))),
      child: Image.asset('assets/art/$asset.png', fit: BoxFit.contain));

  void _openBuilding(BuildContext context, String keyName, String title,
      String art, int level, bool queued, String cityId) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xff101e20),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        builder: (context) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          SizedBox(
                              width: 150,
                              height: 150,
                              child: Image.asset('assets/art/$art.png',
                                  fit: BoxFit.contain)),
                          const SizedBox(width: 20),
                          Expanded(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                const Text('CITY STRUCTURE',
                                    style: TextStyle(
                                        color: gold,
                                        letterSpacing: 1.6,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900)),
                                const SizedBox(height: 5),
                                Text(title,
                                    style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900)),
                                Text('LEVEL $level',
                                    style: const TextStyle(
                                        color: accent,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w900)),
                                const SizedBox(height: 10),
                                Text(buildingLore[keyName] ?? '',
                                    style: const TextStyle(
                                        color: subtle,
                                        fontSize: 13,
                                        height: 1.4)),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                    onPressed: queued
                                        ? null
                                        : () => _upgrade(keyName, cityId),
                                    icon: const Icon(Icons.upgrade_rounded),
                                    label: Text(level == 0
                                        ? 'BUILD THIS STRUCTURE'
                                        : 'UPGRADE TO LEVEL ${level + 1}')),
                              ])),
                        ]),
                        const SizedBox(height: 16),
                        _BuildingOrders(
                            st: widget.st,
                            keyName: keyName,
                            cityId: cityId,
                            queued: queued),
                        if (keyName != 'town_hall') ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xff29413a)),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text('DANGER ZONE',
                                      style: TextStyle(
                                          color: Color(0xffffb4a2),
                                          fontSize: 10,
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.w900)),
                                  SizedBox(height: 3),
                                  Text(
                                      'Remove this building and free its plot.',
                                      style: TextStyle(
                                          color: subtle, fontSize: 11)),
                                ])),
                            const SizedBox(width: 10),
                            _demolishButton(context, keyName, cityId,
                                queued: queued),
                          ]),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
}
