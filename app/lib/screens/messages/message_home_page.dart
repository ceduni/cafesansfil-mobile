import 'package:flutter/material.dart';
import 'package:app/services/message_service.dart';
import 'message.dart'; // Import the MessagePage

class MessageHomePage extends StatelessWidget {
  final MessageService messageService = MessageService();

  MessageHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users List'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: messageService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }

          List<Map<String, dynamic>> users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['name'] ?? 'No Name'),
                subtitle: Text(user['email'] ?? 'No Email'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagePage(
                        userName: user['name'] ?? 'Unknown User',
                        userEmail: user['email'] ?? 'Unknown Email',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
