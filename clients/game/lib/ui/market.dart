part of '../screens.dart';

/// Realm market: buy and sell catalog items at prices set by the server.
class MarketScreen extends StatefulWidget {
  final GameState st;
  const MarketScreen({super.key, required this.st});
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  static const quantities = [1, 5, 10];

  int qty = 1;

  int _amount(Object? value) => int.tryParse('$value') ?? 0;

  Map<String, dynamic> _inventory() {
    final raw = widget.st.player['items'];
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  void _trade(String item, {required bool buy}) {
    widget.st.submit(
      '${buy ? 'buy' : 'sell'} $item x$qty',
      CommandPayload(
        marketBuy: buy ? MarketBuyCmd(item: item, qty: qty) : null,
        marketSell: buy ? null : MarketSellCmd(item: item, qty: qty),
      ),
    );
  }

  IconData _itemIcon(String key) => switch (key) {
        final k when k.startsWith('speed_') => Icons.fast_forward_rounded,
        final k when k.startsWith('shield') => Icons.shield_rounded,
        'scout_kit' => Icons.explore_rounded,
        _ => Icons.inventory_2_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final owned = _inventory();
    final goldAmount = _amount(widget.st.resources['gold']);
    return ListView(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xff173734), Color(0xff102326)]),
              border: Border.all(color: const Color(0xff3d7463)),
              borderRadius: BorderRadius.circular(20)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.storefront_rounded, color: gold, size: 20),
              const SizedBox(width: 9),
              const Expanded(
                  child: Text('MARKET EXCHANGE',
                      style: TextStyle(
                          color: gold,
                          fontSize: 11,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w900))),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xdd0a1718),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x66c1dc8e))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.monetization_on, size: 14, color: gold),
                    const SizedBox(width: 6),
                    Text('Gold $goldAmount',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 12)),
                  ])),
            ]),
            const SizedBox(height: 14),
            const Text('TRADE QUANTITY',
                style: TextStyle(
                    color: subtle,
                    fontSize: 9,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (final value in quantities)
                  ButtonSegment<int>(
                      value: value,
                      label: Text('$value'),
                      tooltip: 'Trade $value at a time'),
              ],
              selected: {qty},
              onSelectionChanged: (selection) =>
                  setState(() => qty = selection.first),
            ),
          ]),
        ),
      ),
      _Section(title: 'Goods', children: [
        for (final entry in items.entries)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xff1b302d),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: const Color(0x5578a574))),
                    child: Icon(_itemIcon(entry.key), color: gold, size: 22)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(entry.value,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                          'Owned  ${_amount(owned[entry.key])}  ·  ${entry.key.replaceAll('_', ' ')}',
                          style: const TextStyle(color: subtle, fontSize: 10)),
                    ])),
                const SizedBox(width: 8),
                Column(children: [
                  SizedBox(
                      width: 76,
                      child: ElevatedButton(
                          onPressed: () => _trade(entry.key, buy: true),
                          child: const Text('Buy'))),
                  const SizedBox(height: 4),
                  SizedBox(
                      width: 76,
                      child: OutlinedButton(
                          onPressed: () => _trade(entry.key, buy: false),
                          child: const Text('Sell'))),
                ]),
              ]),
            ),
          ),
      ]),
      const Padding(
          padding: EdgeInsets.fromLTRB(18, 4, 18, 18),
          child: Text(
              'Prices, stock and delivery are resolved by the realm. Each order appears in the command log.',
              style: TextStyle(color: subtle, fontSize: 11, height: 1.4))),
    ]);
  }
}
