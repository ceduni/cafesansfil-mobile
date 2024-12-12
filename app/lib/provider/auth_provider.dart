import 'package:flutter/material.dart';
import 'package:app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _token;
  String? _username;
  String? _userRole;
  String? _firstname;
  String? _lastname;
  List<String> _cafes = [];

  String? get token => _token;
  List<String> get cafes => _cafes;
  String? get username => _username;
  String? get firstname => _firstname;
  String? get lastname => _lastname;
  String? get userRole => _userRole;

  Future<void> login(String email, String password) async {
    try {
      _token = await _authService.login(email, password);
      notifyListeners(); // Notify listeners that the login state has changed
    } catch (e) {
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null; // Clear the token on logout
    notifyListeners(); // Notify listeners that the logout occurred
  }

  Future<bool> isLoggedIn() async {
    final token = await _authService.getToken();
    return token != null;
  }

  Future<String?> getUsername() async {
    await _authService.storeUserDetails();
    return await _authService.getUsername();
  }

  Future<String?> getFirstname() async {
    await _authService.storeUserDetails();
    _firstname = await _authService.getFirstName();
    return _firstname;
  }

  Future<String?> getLastname() async {
    await _authService.storeUserDetails();
    _lastname = await _authService.getLastName();
    return _lastname;
  }

  void setTheUsername(String? username) {
    _username = username; // Set the username
    notifyListeners(); // Notify listeners that the username has changed
  }

  void setTheUserRole(String? userRole) {
    _userRole = userRole; // Set the username
    notifyListeners(); // Notify listeners that the username has changed
  }
}
