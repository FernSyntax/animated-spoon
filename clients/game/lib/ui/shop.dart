part of '../screens.dart';

/// Real-money shop backed by the payments service.
///
/// In development the service uses a local stub checkout (no credentials
/// needed); in production the same endpoint returns a Stripe-hosted URL. The
/// client never handles card data and never sees a Stripe secret.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const _paymentsBase = String.fromEnvironment(
    'KD_PAYMENTS',
    defaultValue: 'http://localhost:8084',
  );

  static const _products = [
    ('gems_1000', '1,000 Gems', '\$4.99'),
    ('gems_5000', '5,000 Gems', '\$19.99'),
  ];

  bool _busy = false;
  String? _checkoutUrl;
  String? _provider;
  String? _error;

  Future<void> _checkout(String sku) async {
    final accountId = context.read<GameState>().accountId ?? '';
    if (accountId.isEmpty) {
      setState(() => _error = 'Sign in before visiting the shop');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _checkoutUrl = null;
    });
    try {
      final response = await http.post(
        Uri.parse('$_paymentsBase/checkout'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'account_id': accountId, 'sku': sku}),
      );
      if (response.statusCode >= 400) {
        throw Exception('${response.statusCode}: ${response.body}');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _checkoutUrl = body['checkout_url'] as String?;
        _provider = body['provider'] as String?;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Checkout unavailable: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Gem shop',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        const SizedBox(height: 6),
        const Text(
          'Payments are processed by the payments service. Card details are '
          'never handled by the game client.',
          style: TextStyle(color: subtle),
        ),
        const SizedBox(height: 18),
        for (final product in _products)
          Card(
            child: ListTile(
              leading: const Icon(Icons.diamond_outlined, color: secondary),
              title: Text(product.$2),
              subtitle: Text(product.$3),
              trailing: ElevatedButton(
                onPressed: _busy ? null : () => _checkout(product.$1),
                child: const Text('Checkout'),
              ),
            ),
          ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
        ],
        if (_checkoutUrl != null) ...[
          const SizedBox(height: 16),
          _Section(title: 'Checkout ready ($_provider)', children: [
            SelectableText(_checkoutUrl!),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: _checkoutUrl!)),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy checkout link'),
            ),
          ]),
        ],
        const SizedBox(height: 24),
        const Text(
          'The in-game Market trades items for gold. This shop handles '
          'real-money gem purchases.',
          style: TextStyle(color: subtle, fontSize: 12),
        ),
      ],
    );
  }
}
