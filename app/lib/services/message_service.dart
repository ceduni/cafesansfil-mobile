import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/services/auth_service.dart';
import 'package:app/config.dart';
import 'package:app/modeles/message_model.dart';

class MessageService {
  final AuthService _authService = AuthService();

  Stream<List<Map<String, dynamic>>> getUsersStream() async* {
    const String apiUrl = 'https://cafesansfil-api-r0kj.onrender.com/api/users';

    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Add the authorization header
          'Content-Type': 'application/json'
        },
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        List<dynamic> usersJson = json.decode(response.body);
        // Convert the JSON to a List of Maps
        List<Map<String, dynamic>> users =
            List<Map<String, dynamic>>.from(usersJson);

        // Yield the users list
        yield users;
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> sendMessage(
      String senderId, String receiverId, String content) async {
    final token = await _authService.getToken();
    final currentTime = DateTime.now().toIso8601String();
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': currentTime
      }),
    );
    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  Future<List<Message>> fetchMessages(
      String senderId, String receiverId) async {
    final token = await _authService.getToken();
    //print(token);
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/messages/$senderId/$receiverId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((msg) => Message.fromJson(msg)).toList();
    } else {
      throw Exception('Failed to fetch messages: ${response.body}');
    }
  }
}
