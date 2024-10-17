import 'package:app/provider/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  MessagePage({Key? key, required this.userName, required this.userEmail})
      : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];

  void _sendMessage() async {
    final provider = Provider.of<MessageProvider>(context, listen: false);

    if (_messageController.text.isNotEmpty) {
      String senderId = '';
      String receiverId = '';

      await provider.sendMessage(senderId, receiverId, _messageController.text);
      _messageController.clear();
    }

    //Pour les broadcast, on fait la meme chose mais un change String
    //receiverId = ''; par une listes de string et on envoies le message
    //a tout le monde
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages for ${widget.userName}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
