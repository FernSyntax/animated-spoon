part of '../screens.dart';

/// Root navigation shell. Owns the feature menu and routes to each screen.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

/// Navigation owner: feature menu, status bar, world map and tile dialogs.
class _HomeShellState extends State<HomeShell> {
  String _page = 'City';
  WorldMap? _map;

  @override
  Widget build(BuildContext context) {
    final st = context.watch<GameState>();
    _map ??= WorldMap(st, onTileSelected: (p) => _showTile(context, p));
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.castle_rounded, color: gold, size: 22),
          const SizedBox(width: 9),
          Flexible(
              child: Text(
                  '$_page  ·  ${st.firstCity['name'] ?? 'New Frontier'}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16))),
        ]),
        actions: [
          IconButton(
            tooltip: 'Open game features',
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () => _showFeatures(context),
          ),
          if (st.cities.length > 1)
            IconButton(
              tooltip: 'Choose a city or change your capital',
              icon: const Icon(Icons.location_city_rounded),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: pageBg,
                builder: (sheetContext) => SafeArea(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(18),
                        child: Text('Your cities',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                      for (final city in st.cities)
                        ListTile(
                          leading: Icon(
                              city['is_capital'] == true
                                  ? Icons.stars_rounded
                                  : Icons.location_city_outlined,
                              color:
                                  city['is_capital'] == true ? gold : accent),
                          title: Text(city['name']?.toString() ?? 'City'),
                          subtitle: Text(
                              '(${city['x']}, ${city['y']})${city['is_capital'] == true ? ' · Capital' : ''}'),
                          selected: city['id'] == st.firstCity['id'],
                          onTap: () {
                            st.selectCity(city['id'].toString());
                            Navigator.pop(sheetContext);
                          },
                          trailing: city['is_capital'] == true
                              ? null
                              : IconButton(
                                  tooltip: 'Make capital',
                                  icon: const Icon(Icons.flag_outlined),
                                  onPressed: () {
                                    st.selectCity(city['id'].toString());
                                    st.submit(
                                        'make capital',
                                        CommandPayload(
                                            switchCapital: SwitchCapitalCmd(
                                                cityId:
                                                    city['id'].toString())));
                                    Navigator.pop(sheetContext);
                                  },
                                ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Active marches',
            icon: const Icon(Icons.route_rounded),
            onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: pageBg,
                builder: (_) => SafeArea(
                    child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * .76,
                        child: MarchesScreen(st: st)))),
          ),
          _statusChip(st),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => st.refresh(),
              tooltip: 'Sync realm'),
        ],
      ),
      body: Column(children: [
        _resourceBar(st),
        if (st.lastError.isNotEmpty)
          Container(
            width: double.infinity,
            color: Colors.red.shade900,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text('Server: ${st.lastError}',
                style: const TextStyle(color: Colors.white)),
          ),
        Expanded(child: _body(st)),
        _bottomNav(),
      ]),
    );
  }

  Widget _statusChip(GameState st) {
    final color = switch (st.conn) {
      ConnState.online => Colors.green,
      ConnState.connecting => Colors.orange,
      ConnState.error => Colors.red,
      ConnState.offline => Colors.grey,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Chip(
          avatar: CircleAvatar(backgroundColor: color, radius: 5),
          label: Text(st.conn.name.toUpperCase())),
    );
  }

  Widget _resourceBar(GameState st) {
    final r = st.resources;
    String v(String k) => (r[k] ?? 0).toString();
    return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Color(0xff102023),
            border: Border(bottom: BorderSide(color: Color(0xff263b3b)))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _res('Food', v('food'), Icons.grass, const Color(0xff9dcd7a)),
              _separator(),
              _res('Wood', v('wood'), Icons.forest, const Color(0xffd8ae73)),
              _separator(),
              _res('Stone', v('stone'), Icons.hexagon_outlined,
                  const Color(0xffb8c4c1)),
              _separator(),
              _res('Iron', v('iron'), Icons.hardware_outlined,
                  const Color(0xff84a6b8)),
              _separator(),
              _res('Gold', v('gold'), Icons.circle, gold),
            ])));
  }

  Widget _separator() => Container(
      width: 1,
      height: 24,
      color: const Color(0xff2a3d3d),
      margin: const EdgeInsets.symmetric(horizontal: 16));
  Widget _res(String label, String value, IconData icon, Color color) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 7),
        Text('$value ',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: subtle,
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.w700)),
      ]);

  void _showFeatures(BuildContext context) {
    const pages = [
      ('Buildings', Icons.construction_rounded),
      ('Shop', Icons.shopping_bag_outlined),
      ('Research', Icons.science_rounded),
      ('Market', Icons.storefront_rounded),
      ('Troops', Icons.shield_rounded),
      ('Heroes & Items', Icons.auto_awesome_rounded),
      ('Alliances', Icons.groups_rounded),
      ('Chat', Icons.chat_bubble_outline_rounded),
      ('Marches & Rallies', Icons.route_rounded),
      ('Reports', Icons.article_outlined),
      ('Rankings', Icons.leaderboard_rounded),
      ('Settings', Icons.settings_rounded),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: pageBg,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('Game features',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            for (final (name, icon) in pages)
              ListTile(
                leading: Icon(icon, color: accent),
                title: Text(name),
                onTap: () {
                  setState(() => _page = name);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return NavigationBar(
        backgroundColor: const Color(0xff0b191b),
        indicatorColor: const Color(0x3349d7b2),
        selectedIndex: _page == 'World' ? 1 : 0,
        onDestinationSelected: (i) =>
            setState(() => _page = i == 0 ? 'City' : 'World'),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.castle_outlined),
              selectedIcon: Icon(Icons.castle),
              label: 'City'),
          NavigationDestination(icon: Icon(Icons.public), label: 'World'),
        ]);
  }

  Widget _body(GameState st) {
    return switch (_page) {
      'World' => MapScreen(st: st, map: _map!),
      'Buildings' => BuildingsScreen(st: st),
      'Shop' => const ShopScreen(),
      'Research' => ResearchScreen(st: st),
      'Market' => MarketScreen(st: st),
      'Troops' => TroopsScreen(st: st),
      'Heroes & Items' => HeroesItemsScreen(st: st),
      'Alliances' => AllianceScreen(st: st),
      'Chat' => ChatScreen(st: st),
      'Marches & Rallies' => MarchesScreen(st: st),
      'Reports' => ReportsScreen(st: st),
      'Rankings' => RankingsScreen(st: st),
      'Settings' => SettingsScreen(st: st),
      _ => CityScreen(st: st),
    };
  }

  void _showTile(BuildContext context, List<int> p) {
    final st = context.read<GameState>();
    final entities = (st.map['entities'] as List?) ?? [];
    final cities = (st.map['cities'] as List?) ?? [];
    final nearbyEntities = entities
        .where((e) => e is Map && e['x'] == p[0] && e['y'] == p[1])
        .toList();
    final nearbyCities = cities
        .where((c) => c is Map && c['x'] == p[0] && c['y'] == p[1])
        .toList();
    final city = st.firstCity;
    final myCityId = city['id']?.toString() ?? '';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Frontier ${p[0]} : ${p[1]}'),
        content: SizedBox(
            width: 340,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nearbyCities.isNotEmpty) ...[
                    Row(children: [
                      Image.asset(
                          nearbyCities.first['player_id'] == st.playerId
                              ? 'assets/art/city_own.png'
                              : 'assets/art/city_enemy.png',
                          width: 72,
                          height: 72),
                      const SizedBox(width: 9),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('${nearbyCities.first['name']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 17)),
                            Text(
                                '${nearbyCities.first['player_name']}  ·  TH ${nearbyCities.first['town_hall_level']}',
                                style: const TextStyle(
                                    color: subtle, fontSize: 11)),
                            if ((nearbyCities.first['shield_until_ms']
                                        as num? ??
                                    0) >
                                DateTime.now().millisecondsSinceEpoch)
                              const Text('Peace shield active',
                                  style: TextStyle(
                                      color: Color(0xff90c8ff), fontSize: 10))
                          ]))
                    ]),
                    const SizedBox(height: 6),
                    if (nearbyCities.first['player_id'] == st.playerId)
                      ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() => _page = 'City');
                          },
                          icon: const Icon(Icons.castle_rounded, size: 16),
                          label: const Text('Enter city')),
                    if (nearbyCities.first['player_id'] != st.playerId) ...[
                      const Text(
                          'Scout before attacking to reveal the garrison.',
                          style: TextStyle(color: subtle, fontSize: 11)),
                      Wrap(spacing: 8, children: [
                        OutlinedButton.icon(
                            onPressed: () {
                              st.submit(
                                  'scout city',
                                  CommandPayload(
                                      scoutTile: ScoutTileCmd(
                                          pos: Vec2(x: p[0], y: p[1]))));
                              Navigator.pop(ctx);
                            },
                            icon: const Icon(Icons.visibility, size: 16),
                            label: const Text('Scout city')),
                        ElevatedButton.icon(
                            onPressed: (nearbyCities.first['shield_until_ms']
                                            as num? ??
                                        0) >
                                    DateTime.now().millisecondsSinceEpoch
                                ? null
                                : () {
                                    st.submit(
                                        'attack city',
                                        CommandPayload(
                                            attackCity: AttackCityCmd(
                                                cityId: myCityId,
                                                targetCityId: nearbyCities
                                                    .first['id']
                                                    .toString())));
                                    Navigator.pop(ctx);
                                  },
                            icon: const Icon(Icons.gavel, size: 16),
                            label: const Text('Attack city')),
                        ElevatedButton(
                            onPressed: () => _reinforceDialog(ctx, st, myCityId,
                                nearbyCities.first['id'].toString()),
                            child: const Text('Reinforce')),
                        ElevatedButton(
                            onPressed: () => _transportDialog(ctx, st, myCityId,
                                nearbyCities.first['id'].toString()),
                            child: const Text('Transport')),
                      ]),
                    ],
                  ],
                  for (final e in nearbyEntities) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      Image.asset(
                          e['kind'].toString().toLowerCase().contains('monster')
                              ? ((e['level'] as num? ?? 1) >= 4
                                  ? 'assets/art/monster_golem.png'
                                  : 'assets/art/monster_dragon.png')
                              : e['kind']
                                      .toString()
                                      .toLowerCase()
                                      .contains('node')
                                  ? 'assets/art/resource_node.png'
                                  : 'assets/art/fort.png',
                          width: 72,
                          height: 72),
                      const SizedBox(width: 9),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                                e['kind']
                                        .toString()
                                        .toLowerCase()
                                        .contains('monster')
                                    ? '${e['subtype']} · Level ${e['level']}'
                                    : '${e['kind']} · ${e['subtype']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 15)),
                            if (e['kind']
                                .toString()
                                .toLowerCase()
                                .contains('monster'))
                              Text('Vitality  ${e['hp']}',
                                  style: const TextStyle(
                                      color: Color(0xffffb695), fontSize: 11)),
                            if (e['kind']
                                .toString()
                                .toLowerCase()
                                .contains('node'))
                              Text('Available  ${e['stock']}',
                                  style: const TextStyle(
                                      color: gold, fontSize: 11))
                          ]))
                    ]),
                    Wrap(spacing: 8, children: [
                      if (e['kind'].toString().toLowerCase().contains('node'))
                        ElevatedButton(
                            onPressed: () {
                              st.submit(
                                  'gather',
                                  CommandPayload(
                                      gather: GatherCmd(
                                          cityId: myCityId,
                                          nodeId: e['id'].toString())));
                              Navigator.pop(ctx);
                            },
                            child: const Text('Gather')),
                      if (e['kind']
                          .toString()
                          .toLowerCase()
                          .contains('monster'))
                        ElevatedButton.icon(
                            onPressed: () {
                              st.submit(
                                  'hunt monster',
                                  CommandPayload(
                                      attackMonster: AttackMonsterCmd(
                                          cityId: myCityId,
                                          monsterId: e['id'].toString())));
                              Navigator.pop(ctx);
                            },
                            icon:
                                const Icon(Icons.sports_martial_arts, size: 16),
                            label: const Text('Hunt monster')),
                      if (e['kind'].toString().toLowerCase().contains('fort'))
                        ElevatedButton(
                            onPressed: () {
                              st.submit(
                                  'attack fort',
                                  CommandPayload(
                                      attackFort: AttackFortCmd(
                                          cityId: myCityId,
                                          fortId: e['id'].toString())));
                              Navigator.pop(ctx);
                            },
                            child: const Text('Capture fort')),
                    ]),
                  ],
                  if (nearbyEntities.isEmpty && nearbyCities.isEmpty)
                    const Text('Empty tile'),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, children: [
                    ElevatedButton(
                        onPressed: () {
                          st.submit(
                              'scout',
                              CommandPayload(
                                  scoutTile: ScoutTileCmd(
                                      pos: Vec2(x: p[0], y: p[1]))));
                          Navigator.pop(ctx);
                        },
                        child: const Text('Scout here')),
                    if (nearbyEntities.isEmpty && nearbyCities.isEmpty)
                      OutlinedButton.icon(
                          onPressed: () => _foundCityAt(ctx, st, p),
                          icon: const Icon(Icons.add_location_alt_outlined,
                              size: 16),
                          label: const Text('Found city here')),
                    ElevatedButton(
                        onPressed: () => _rallyDialog(ctx, st, myCityId, p),
                        child: const Text('Rally here')),
                  ]),
                ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
        ],
      ),
    );
  }

  void _foundCityAt(BuildContext context, GameState st, List<int> position) {
    final name = TextEditingController(text: 'New City');
    showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: Text('Found a city · ${position[0]}, ${position[1]}'),
              content: TextField(
                  controller: name,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'City name')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () {
                      st.submit(
                          'found city',
                          CommandPayload(
                              createCity: CreateCityCmd(
                                  name: name.text.trim(),
                                  pos: Vec2(x: position[0], y: position[1]))));
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    child: const Text('Found')),
              ],
            )).whenComplete(name.dispose);
  }

  void _reinforceDialog(
      BuildContext ctx, GameState st, String from, String target) {
    final n = TextEditingController(text: '20');
    showDialog<void>(
        context: ctx,
        builder: (c) => AlertDialog(
                title: const Text('Reinforce ally'),
                content: TextField(
                    controller: n,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Infantry count')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () {
                        st.submit(
                            'reinforce',
                            CommandPayload(
                                reinforce: ReinforceCmd(
                                    cityId: from,
                                    targetCityId: target,
                                    troops: [
                                  TroopSend(
                                      unit: 'infantry',
                                      tier: 1,
                                      count: int.tryParse(n.text) ?? 0)
                                ])));
                        Navigator.pop(c);
                      },
                      child: const Text('Send')),
                ])).whenComplete(n.dispose);
  }

  void _transportDialog(
      BuildContext ctx, GameState st, String from, String target) {
    final n = TextEditingController(text: '500');
    showDialog<void>(
        context: ctx,
        builder: (c) => AlertDialog(
                title: const Text('Transport resources'),
                content: TextField(
                    controller: n,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Food')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () {
                        st.submit(
                            'transport',
                            CommandPayload(
                                transport: TransportCmd(
                                    cityId: from,
                                    targetCityId: target,
                                    resources: Resources(
                                        food: Int64(
                                            int.tryParse(n.text) ?? 0)))));
                        Navigator.pop(c);
                      },
                      child: const Text('Send')),
                ])).whenComplete(n.dispose);
  }

  void _rallyDialog(BuildContext ctx, GameState st, String from, List<int> p) {
    showDialog<void>(
        context: ctx,
        builder: (c) => AlertDialog(
                title: const Text('Create rally'),
                content: Text(
                    'Target (${p[0]}, ${p[1]}). Allies can join before launch.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () {
                        st.submit(
                            'rally',
                            CommandPayload(
                                rallyCreate: RallyCreateCmd(
                                    cityId: from,
                                    targetPos: Vec2(x: p[0], y: p[1]),
                                    startAtUnixMs: Int64(
                                        DateTime.now().millisecondsSinceEpoch +
                                            15000))));
                        Navigator.pop(c);
                      },
                      child: const Text('Create')),
                ]));
  }
}
