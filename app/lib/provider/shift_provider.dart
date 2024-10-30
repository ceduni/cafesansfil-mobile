import 'package:app/config.dart';
import 'package:app/modeles/Shift.dart';
import 'package:app/services/shiftService.dart';
import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

class ShiftProvider with ChangeNotifier {
  List<Shift> _shifts = [];
  String cafeName = Config.cafeName;
  List<TimePlannerTask> shiftsPlanToDisplay = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Shift> get shifts => _shifts;
  get shiftsToDisplay => shiftsPlanToDisplay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  ShiftProvider() {
    fetchShifts();
  }

  Future<void> fetchShifts() async {
    _isLoading = true;
    try {
      _shifts = await ShiftService().fetchShifts();
      shiftsPlanToDisplay = ShiftService()
          .shiftsPlanToDisplay(_shifts, cafeName, DateTime(2023, 3, 23));
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> createShift(Shift newShift) async {
    _isLoading = true;
    try {
      await ShiftService().createShift(newShift);
      await fetchShifts(); // Fetch shifts again to update the display
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateShift(String id, Shift updatedShift) async {
    _isLoading = true;
    try {
      await ShiftService().updateShift(id, updatedShift);
      await fetchShifts(); // Fetch shifts again to update the display
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addShiftDetail(
      String matricule, ShiftDetail newShiftDetail) async {
    _isLoading = true;
    notifyListeners(); // Notify listeners to update UI
    try {
      // Call the service to add a shift detail using matricule
      await ShiftService().addShiftDetail(matricule, newShiftDetail);
      await fetchShifts(); // Fetch shifts again to update the display
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners(); // Notify listeners about the error
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners to update the loading state
    }
  }
}
