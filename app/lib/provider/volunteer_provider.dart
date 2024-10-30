import 'package:app/config.dart';
import 'package:app/modeles/Cafe.dart';
import 'package:app/modeles/Volunteer.dart';
import 'package:app/services/volunteerService.dart';
import 'package:flutter/material.dart';

class VolunteerProvider with ChangeNotifier {
  List<Volunteer> _Volunteers = [];
  //String cafeName = Config.cafeName;
  String cafeName = Config.cafeName;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  get Volunteers => _Volunteers;
  get isLoading => _isLoading;
  get errorMessage => _errorMessage;
  bool get hasError =>
      (_errorMessage != null && _errorMessage!.isNotEmpty) || _hasError;

  VolunteerProvider() {
    //fetchVolunteer();
    fetchVolunteer();
  }
  Future<void> fetchVolunteer() async {
    _isLoading = true;
    try {
      _Volunteers = await VolunteerService().fetchVolunteers();
      _isLoading = false;
    } catch (e) {
      // Handle error
      _errorMessage = e.toString();
      _isLoading = false;
      print(e);
    }

    notifyListeners();
  }

  Future<void> fetchVolunteersByStaff(List<Staff> staff) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // Fetch all volunteers (you might have this already implemented)
      await fetchVolunteer();

      // Filter volunteers based on staff usernames
      List<Volunteer> filteredVolunteers = Volunteers.where((volunteer) {
        return staff
            .any((staffMember) => staffMember.username == volunteer.username);
      }).toList();

      // Update the Volunteer list to the filtered list
      _Volunteers = filteredVolunteers;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
