import 'package:app/config.dart';
import 'package:app/modeles/Cafe.dart';
import 'package:app/modeles/Volunteer.dart';
import 'package:app/services/volunteerService.dart';
import 'package:flutter/material.dart';

class VolunteerProvider with ChangeNotifier {
  List<Volunteer> _volunteers = [];
  //String cafeName = Config.cafeName;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  get volunteers => _volunteers;
  get isLoading => _isLoading;
  get errorMessage => _errorMessage;
  bool get hasError =>
      (_errorMessage != null && _errorMessage!.isNotEmpty) || _hasError;

  /*VolunteerProvider() {
    //fetchVolunteer();
    fetchVolunteer();
  }*/
  Future<void> fetchVolunteer(String cafeName) async {
    _isLoading = true;
    try {
      _volunteers = await VolunteerService().fetchVolunteers(cafeName);
      _isLoading = false;
    } catch (e) {
      // Handle error
      _errorMessage = e.toString();
      _isLoading = false;
      print(e);
    }

    notifyListeners();
  }

  void removeVolunteer(String username) {
    _volunteers.removeWhere((volunteer) => volunteer.username == username);
    notifyListeners(); // Notify listeners to rebuild the UI
  }
}
