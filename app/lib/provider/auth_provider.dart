import 'package:flutter/material.dart';
import 'package:app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _token;
  String? _username;
  String? _userRole;
  String? _firstname;
  String? _lastname;
  String? _matricule;
  String? _email;
  String? _photoUrl;

  List<String> _cafes = [];

  String? get token => _token;
  List<String> get cafes => _cafes;
  String? get username => _username;
  String? get firstname => _firstname;
  String? get lastname => _lastname;
  String? get userRole => _userRole;
  String? get matricule => _matricule;
  String? get email => _email;
  String? get photoUrl => _photoUrl;

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

  Future<String?> getPhotoUrl() async {
    await _authService.storeUserDetails();
    return await _authService.getPhotoUrl();
  }

  Future<List<String?>> getUserDetails() async {
    // Ensure user details are stored first
    await _authService.storeUserDetails();

    // Fetch user details using AuthService methods
    _firstname = await _authService.getFirstName();
    _lastname = await _authService.getLastName();
    _username = await _authService.getUsername();
    _matricule = await _authService.getMatricule();
    _email = await _authService.getEmail();
    _photoUrl = await _authService.getPhotoUrl();

    // Return a list containing all the user details
    return [_firstname, _lastname, _username, _matricule, _email, _photoUrl];
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
