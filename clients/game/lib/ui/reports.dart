part of '../screens.dart';

/// Combat and scouting reports delivered from the realm worker.
class ReportsScreen extends StatelessWidget {
  final GameState st;
  const ReportsScreen({super.key, required this.st});
  @override
  Widget build(BuildContext context) => ListView(children: [
        _Section(title: 'Live event / report feed', children: [
          if (st.eventLog.isEmpty) const Text('No events yet.'),
          for (final e in st.eventLog.reversed) ListTile(title: Text(e)),
        ]),
      ]);
}
