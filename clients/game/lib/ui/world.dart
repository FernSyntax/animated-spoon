part of '../screens.dart';

/// World map and tile inspector, including scouting and march actions.
class MapScreen extends StatefulWidget {
  final GameState st;
  final WorldMap map;
  const MapScreen({super.key, required this.st, required this.map});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

/// Owns the Flame map lifecycle and the chunk subscription controls.
class _MapScreenState extends State<MapScreen> {
  double lastScale = 1;
  late final TextEditingController jumpX =
      TextEditingController(text: '${widget.map.centerX.round()}');
  late final TextEditingController jumpY =
      TextEditingController(text: '${widget.map.centerY.round()}');
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadAround();
    });
  }

  @override
  void dispose() {
    jumpX.dispose();
    jumpY.dispose();
    super.dispose();
  }

  Future<void> _loadAround() async {
    final view = MediaQuery.sizeOf(context);
    final span = (view.width / (WorldMap.tileW * widget.map.zoom) +
            view.height / (WorldMap.tileH * widget.map.zoom)) /
        2;
    final radius = (span / 64).ceil().clamp(1, 2);
    final cx = (widget.map.centerX / 32).floor(),
        cy = (widget.map.centerY / 32).floor();
    final minX = (cx - radius).clamp(0, 63).toInt(),
        maxX = (cx + radius).clamp(0, 63).toInt();
    final minY = (cy - radius).clamp(0, 63).toInt(),
        maxY = (cy + radius).clamp(0, 63).toInt();
    final next = <List<int>>[];
    for (var x = minX; x <= maxX; x++) {
      for (var y = minY; y <= maxY; y++) {
        next.add([x, y]);
      }
    }
    await widget.st.updateChunks(next);
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.map, st = widget.st;
    final entities = (st.map['entities'] as List?) ?? [];
    final cities = (st.map['cities'] as List?) ?? [];
    final monsters = entities
        .where((e) =>
            e is Map && e['kind'].toString().toLowerCase().contains('monster'))
        .length;
    final resourceSites = entities
        .where((e) =>
            e is Map &&
            (e['kind'].toString().toLowerCase().contains('node') ||
                e['kind'].toString().toLowerCase().contains('resource')))
        .length;
    return Stack(children: [
      GestureDetector(
        onScaleStart: (d) {
          lastScale = 1;
          map.beginGesture(d.localFocalPoint);
        },
        onScaleUpdate: (d) {
          map.panBy(d.focalPointDelta, d.localFocalPoint);
          if (d.pointerCount > 1 && d.scale != lastScale) {
            map.zoomBy(d.scale / lastScale);
          }
          lastScale = d.scale;
        },
        onScaleEnd: (_) {
          final moved = map.panning;
          map.endGesture();
          if (moved) _loadAround();
        },
        child: flame.GameWidget(game: map),
      ),
      Positioned(
          left: 14,
          top: 14,
          child: _controls(st, map, monsters, cities.length, resourceSites)),
      Positioned(right: 14, bottom: 60, child: _legend()),
      Positioned(
          right: 16,
          top: 16,
          child: Row(children: [
            _mapButton(Icons.remove, () {
              setState(() => map.zoomBy(.8));
              _loadAround();
            }),
            const SizedBox(width: 6),
            _mapButton(Icons.add, () {
              setState(() => map.zoomBy(1.25));
              _loadAround();
            }),
            const SizedBox(width: 8),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                    color: const Color(0xe9101e20),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0x553b5e58))),
                child: Text('${(map.zoom * 100).round()}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 11))),
          ])),
      Positioned(left: 16, bottom: 60, child: _worldStatus(st)),
    ]);
  }

  Widget _controls(GameState st, WorldMap map, int monsters, int cityCount,
          int resourceSites) =>
      Container(
        width: 256,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xe9101d1e),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x553b5e58)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 18,
                  offset: Offset(0, 7))
            ]),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(children: [
                Icon(Icons.public, color: gold, size: 17),
                SizedBox(width: 8),
                Text('THE FRONTIER',
                    style: TextStyle(
                        letterSpacing: 1.6,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: gold))
              ]),
              const SizedBox(height: 5),
              Text('Sector ${map.centerX.floor()} : ${map.centerY.floor()}',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Row(children: [
                _stat(
                    Icons.pets, '$monsters', 'BEASTS', const Color(0xffe99e77)),
                const SizedBox(width: 14),
                _stat(Icons.location_city, '$cityCount', 'CITIES',
                    const Color(0xff8fcfba))
              ]),
              const SizedBox(height: 6),
              _stat(Icons.diamond_outlined, '$resourceSites', 'RESOURCE SITES',
                  const Color(0xffedc875)),
              const SizedBox(height: 12),
              Row(children: [
                SizedBox(
                    width: 58,
                    child: TextField(
                        controller: jumpX,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'X',
                            isDense: true,
                            contentPadding: EdgeInsets.all(10)))),
                const SizedBox(width: 6),
                SizedBox(
                    width: 58,
                    child: TextField(
                        controller: jumpY,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Y',
                            isDense: true,
                            contentPadding: EdgeInsets.all(10)))),
                const SizedBox(width: 2),
                IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    constraints:
                        const BoxConstraints.tightFor(width: 34, height: 40),
                    tooltip: 'Jump to coordinates',
                    onPressed: () {
                      setState(() => map.jumpTo(int.tryParse(jumpX.text) ?? 0,
                          int.tryParse(jumpY.text) ?? 0));
                      _loadAround();
                    },
                    icon: const Icon(Icons.my_location, color: accent)),
                IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    constraints:
                        const BoxConstraints.tightFor(width: 34, height: 40),
                    tooltip: 'Return to capital',
                    onPressed: () {
                      final c = st.firstCity;
                      setState(() => map.jumpTo((c['x'] as num?)?.toInt() ?? 64,
                          (c['y'] as num?)?.toInt() ?? 64));
                      _loadAround();
                    },
                    icon: const Icon(Icons.home_filled, color: gold)),
              ]),
              const SizedBox(height: 9),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                      onPressed: _loadAround,
                      icon: const Icon(Icons.travel_explore, size: 16),
                      label: const Text('Explore this sector'))),
              const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Drag to travel · tap a target to act',
                      style: TextStyle(color: subtle, fontSize: 10))),
            ]),
      );

  Widget _stat(IconData icon, String count, String label, Color color) =>
      Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Text(count, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 8,
                letterSpacing: .7,
                color: subtle,
                fontWeight: FontWeight.w800))
      ]);
  Widget _mapButton(IconData icon, VoidCallback action) => Material(
      color: const Color(0xe9101e20),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0x553b5e58))),
      child: InkWell(
          onTap: action,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: const Color(0xffeff6e9), size: 20))));
  Widget _worldStatus(GameState st) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
          color: const Color(0xe9101e20),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0x553b5e58))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(st.conn == ConnState.online ? Icons.circle : Icons.sync,
            size: 8, color: st.conn == ConnState.online ? accent : gold),
        const SizedBox(width: 7),
        Text(
            '${st.conn == ConnState.online ? 'REALM LIVE' : 'SYNCING'} · ${st.realmId.toUpperCase()}',
            style: const TextStyle(
                fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w900))
      ]));
  Widget _legend() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
          color: const Color(0xe9101e20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x553b5e58))),
      child: const Wrap(spacing: 12, runSpacing: 6, children: [
        _MapLegendDot(color: Color(0xff648f55), text: 'PLAINS'),
        _MapLegendDot(color: Color(0xff467f5b), text: 'FOREST'),
        _MapLegendDot(color: Color(0xffb39a65), text: 'HILLS'),
        _MapLegendDot(color: Color(0xff4c9bb0), text: 'WATER'),
        _MapLegendDot(color: Color(0xffaeb6b2), text: 'MOUNTAINS'),
        _MapLegendDot(color: Color(0xff83b6ff), text: 'CITY'),
        _MapLegendDot(color: Color(0xffec9a78), text: 'BEAST'),
        _MapLegendDot(color: Color(0xffedc875), text: 'RESOURCE'),
        _MapLegendDot(color: Color(0xfff1ce7a), text: 'MARCH'),
      ]));
}
