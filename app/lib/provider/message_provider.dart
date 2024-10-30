import 'package:app/services/message_service.dart';
import 'package:flutter/material.dart';
import '../modeles/message_model.dart';

class MessageProvider with ChangeNotifier {
  final MessageService _messageService = MessageService();
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> sendMessage(
      String senderId, String receiverId, String content) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _messageService.sendMessage(senderId, receiverId, content);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String senderId, String receiverId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Fetch messages from service
      _messages = await _messageService.fetchMessages(senderId, receiverId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
