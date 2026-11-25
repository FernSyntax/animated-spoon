part of '../screens.dart';

/// Titled section container shared by every feature screen.
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w900,
                      color: accent)),
              const SizedBox(height: 4),
              const Divider(color: Color(0xff2a3d3d)),
              ...children,
            ])),
      );
}
