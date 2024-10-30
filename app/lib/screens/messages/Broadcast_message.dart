import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/volunteer_provider.dart';
import 'package:app/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BroadcastMessagePage extends StatefulWidget {
  @override
  _BroadcastMessagePageState createState() => _BroadcastMessagePageState();
}

class _BroadcastMessagePageState extends State<BroadcastMessagePage> {
  List<String> selectedVolunteers = [];
  TextEditingController _messageController = TextEditingController();
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    final volunteerProvider = Provider.of<VolunteerProvider>(context);
    final volunteers = volunteerProvider.Volunteers;

    return Scaffold(
      appBar: AppBar(
        title: Text('Broadcast Message'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isDropdownOpen = !_isDropdownOpen;
              });
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                children: [
                  Text('Selected Volunteers: ${selectedVolunteers.join(', ')}'),
                  SizedBox(height: 8),
                  Icon(_isDropdownOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          if (_isDropdownOpen)
            Container(
              height: 200,
              child: ListView(
                children: volunteers.map<Widget>((volunteer) {
                  return CheckboxListTile(
                    title: Text(volunteer.firstName),
                    value: selectedVolunteers.contains(volunteer.username),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedVolunteers.add(volunteer.username);
                        } else {
                          selectedVolunteers.remove(volunteer.username);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_messageController.text.isNotEmpty &&
                  selectedVolunteers.isNotEmpty) {
                String? username =
                    await Provider.of<AuthProvider>(context, listen: false)
                        .getUsername();
                final messageService = MessageService();
                for (String volunteerUsername in selectedVolunteers) {
                  await messageService.sendMessage(
                      username!, volunteerUsername, _messageController.text);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Message sent to selected volunteers!')),
                );
                _messageController.clear();
                setState(() {
                  selectedVolunteers.clear();
                  _isDropdownOpen = false; // Close the dropdown after sending
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Please select at least one volunteer and type a message.')),
                );
              }
            },
            child: Icon(Icons.send, color: Colors.blue[400]),
          ),
        ],
      ),
    );
  }
}