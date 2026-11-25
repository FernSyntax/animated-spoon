part of '../screens.dart';

/// Season score leaderboard for the selected realm.
class RankingsScreen extends StatelessWidget {
  final GameState st;
  const RankingsScreen({super.key, required this.st});
  @override
  Widget build(BuildContext context) {
    final scores = (st.map['season_score'] as Map?) ?? {};
    final entries = scores.entries.toList()
      ..sort(
          (a, b) => ((b.value as num?) ?? 0).compareTo((a.value as num?) ?? 0));
    return ListView(children: [
      _Section(title: 'Season objectives & rankings', children: [
        const Text(
            'Capture forts, defeat monsters and win battles for points.'),
        for (var i = 0; i < entries.length; i++)
          ListTile(
              leading: Text('#${i + 1}'),
              title: Text(entries[i].key.toString()),
              trailing: Text('${entries[i].value}')),
      ]),
    ]);
  }
}
