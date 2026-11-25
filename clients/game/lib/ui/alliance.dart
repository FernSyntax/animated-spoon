part of '../screens.dart';

/// Alliance lifecycle, roles, help and rally management.
class AllianceScreen extends StatefulWidget {
  final GameState st;
  const AllianceScreen({super.key, required this.st});

  @override
  State<AllianceScreen> createState() => _AllianceScreenState();
}

/// Alliance actions: create, join, invite, help and role-aware controls.
class _AllianceScreenState extends State<AllianceScreen> {
  late final TextEditingController name;
  late final TextEditingController tag;
  late final TextEditingController invite;
  late final TextEditingController helpTarget;
  late final TextEditingController allianceId;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: 'My Alliance');
    tag = TextEditingController(text: 'KOD');
    invite = TextEditingController();
    helpTarget = TextEditingController();
    allianceId = TextEditingController();
  }

  @override
  void dispose() {
    name.dispose();
    tag.dispose();
    invite.dispose();
    helpTarget.dispose();
    allianceId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.st;
    final ally = st.alliance;
    return ListView(children: [
      _Section(title: 'Alliance', children: [
        if (ally.isEmpty) ...[
          TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Alliance name')),
          TextField(
              controller: tag,
              decoration: const InputDecoration(labelText: 'Tag')),
          ElevatedButton(
              onPressed: () => st.submit(
                  'create alliance',
                  CommandPayload(
                      createAlliance:
                          CreateAllianceCmd(name: name.text, tag: tag.text))),
              child: const Text('Create alliance')),
          const SizedBox(height: 10),
          TextField(
              controller: allianceId,
              decoration: const InputDecoration(
                  labelText: 'Alliance ID from your invitation')),
          ElevatedButton(
              onPressed: () => st.submit(
                  'accept alliance invitation',
                  CommandPayload(
                      allianceAccept:
                          AllianceAcceptCmd(allianceId: allianceId.text))),
              child: const Text('Accept invitation & join')),
          const SizedBox(height: 10),
          SelectableText('Your player ID: ${st.playerId ?? ''}'),
          const Text(
              'Share your player ID with an alliance leader so they can invite you.',
              style: TextStyle(color: subtle)),
          const SizedBox(height: 10),
        ] else ...[
          Text('ID: ${ally['id']}  Role: ${ally['role']}'),
          const Text('Share this alliance ID with players you invite.'),
          SelectableText('${ally['id']}'),
          if (ally['role'] == 'leader' || ally['role'] == 'officer') ...[
            TextField(
                controller: invite,
                decoration: const InputDecoration(
                    labelText: 'Player ID to invite or remove')),
            Wrap(spacing: 8, children: [
              ElevatedButton(
                  onPressed: () => st.submit(
                      'invite',
                      CommandPayload(
                          allianceInvite:
                              AllianceInviteCmd(playerId: invite.text))),
                  child: const Text('Invite')),
              ElevatedButton(
                  onPressed: () => st.submit(
                      'kick',
                      CommandPayload(
                          allianceKick:
                              AllianceKickCmd(playerId: invite.text))),
                  child: const Text('Remove player')),
            ]),
          ],
          TextField(
              controller: helpTarget,
              decoration:
                  const InputDecoration(labelText: 'Ally player ID to help')),
          Wrap(spacing: 8, children: [
            ElevatedButton(
                onPressed: () => st.submit(
                    'help ally queue',
                    CommandPayload(
                        allianceHelp:
                            AllianceHelpCmd(targetPlayerId: helpTarget.text))),
                child: const Text('Help next queue task')),
            OutlinedButton(
                onPressed: () => st.submit('leave alliance',
                    CommandPayload(allianceLeave: AllianceLeaveCmd())),
                child: const Text('Leave')),
          ]),
        ],
      ]),
    ]);
  }
}
