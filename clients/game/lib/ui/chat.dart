part of '../screens.dart';

/// World and alliance chat fed by authoritative delta events.
class ChatScreen extends StatefulWidget {
  final GameState st;
  const ChatScreen({super.key, required this.st});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

/// Chat controller: composer, scope selection and live message feed.
class _ChatScreenState extends State<ChatScreen> {
  final text = TextEditingController();
  String scope = 'world';
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              DropdownButton<String>(
                  value: scope,
                  items: const [
                    DropdownMenuItem(value: 'world', child: Text('World')),
                    DropdownMenuItem(
                        value: 'alliance', child: Text('Alliance')),
                  ],
                  onChanged: (v) => setState(() => scope = v ?? 'world')),
              Expanded(
                  child: TextField(
                      controller: text,
                      decoration: const InputDecoration(labelText: 'Message'))),
              ElevatedButton(
                  onPressed: () {
                    widget.st.submit(
                        'chat',
                        CommandPayload(
                            chat: ChatCmd(scope: scope, text: text.text)));
                    text.clear();
                  },
                  child: const Text('Send')),
            ])),
        Expanded(
            child: ListView.builder(
                itemCount: widget.st.eventLog.length,
                itemBuilder: (ctx, i) => ListTile(
                    title: Text(widget
                        .st.eventLog[widget.st.eventLog.length - 1 - i])))),
      ]);
}
