import 'package:app/modeles/message_model.dart';
import 'package:app/provider/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart';

class MessagePage extends StatefulWidget {
  final String userName; // Receiver's ID (could be username or email)
  final String userEmail;
  final String firstName;

  MessagePage({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.firstName,
  }) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  String senderId = '';
  List<Message> message = [];

  @override
  void initState() {
    super.initState();
    _initializeSenderId();
  }

  Future<void> _initializeSenderId() async {
    String? username =
        await Provider.of<AuthProvider>(context, listen: false).getUsername();
    setState(() {
      senderId = username ?? ''; // Assign the username to senderId
    });
    await _fetchMessages(); // Retrieve messages on startup
  }

  Future<void> _fetchMessages() async {
    final provider = Provider.of<MessageProvider>(context, listen: false);
    String receiverId = widget.userName; // Populate with receiver's ID
    await provider.fetchMessages(senderId, receiverId);
  }

  void _sendMessage() async {
    final provider = Provider.of<MessageProvider>(context, listen: false);

    if (_messageController.text.isNotEmpty) {
      String receiverId = widget.userName; // Populate with the receiver's ID

      await provider.sendMessage(senderId, receiverId, _messageController.text);
      _messageController.clear();
      await _fetchMessages(); // Refresh messages after sending one
    }
  }

  @override
  Widget build(BuildContext context) {
    //final provider = Provider.of<MessageProvider>(context);
    return Consumer<MessageProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Messages for ${widget.firstName}'),
            ),
            body: Center(
              child: CircularProgressIndicator(), // Show loading spinner
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Messages for ${widget.firstName}'),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    final isSender = message.senderId == senderId;

                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(15.0),
                        margin: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: isSender ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          message.content,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
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
                      color: Colors.blue[300],
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
