import 'package:app/modeles/Shift.dart';
import 'package:app/services/shiftService.dart';
import 'package:flutter/material.dart';

class ShiftProvider with ChangeNotifier {
  final ShiftService _shiftService = ShiftService();
  List<Shift> shifts = [];

  Future<void> fetchAllShifts() async {
    shifts = await _shiftService.getAllShifts();
    notifyListeners();
  }

  Future<void> addStaff(String cafeName, String dayName, String hourName,
      String matricule, String name) async {
    try {
      final updatedShift = await _shiftService.addStaff(
          cafeName, dayName, hourName, matricule, name); // Pass name
      if (updatedShift != null) {
        await fetchAllShifts();
        notifyListeners();
      }
    } catch (e) {
      print("Error while adding staff: $e");
    }
  }

  Future<void> confirmStaff(String cafeName, String dayName, String hourName,
      String matricule) async {
    try {
      final updatedShift = await _shiftService.confirmStaff(
          cafeName, dayName, hourName, matricule);
      if (updatedShift != null) {
        await fetchAllShifts();
        notifyListeners();
      }
    } catch (e) {
      // Handle error
      print("Error while confirming staff: $e");
    }
  }

  Future<void> removeStaff(String cafeName, String dayName, String hourName,
      String matricule) async {
    try {
      final updatedShift = await _shiftService.removeStaff(
          cafeName, dayName, hourName, matricule);
      if (updatedShift != null) {
        // Optionally, update the local shift list for quicker feedback
        await fetchAllShifts();
        notifyListeners(); // Notify listeners of the new shift data
      }
    } catch (e) {
      // Handle error
      print("Error while removing staff: $e");
    }
  }
}
