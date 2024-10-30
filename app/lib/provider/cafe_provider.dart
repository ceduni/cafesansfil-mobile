import 'package:app/config.dart';
import 'package:app/modeles/Cafe.dart';
import 'package:app/services/CafeService.dart';
import 'package:flutter/material.dart';

class CafeProvider with ChangeNotifier {
  String cafeName = Config.cafeName;
  bool _isLoading = false;
  String? _errorMessage;
  var _cafe;
  Cafe? _selectedCafe;

  get cafe => _cafe;
  get isLoading => _isLoading;
  get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;
  Cafe? get selectedCafe => _selectedCafe;

  CafeProvider() {
    fetchCafe();
  }

  List<MenuItem> get getMenuItems => _cafe?.menuItems ?? [];

  Future<void> fetchCafe() async {
    _isLoading = true;
    try {
      _cafe = await CafeService().fetchCafeByName(cafeName);

      _isLoading = false;
    } catch (e) {
      // Handle error
      _errorMessage = e.toString();
      _isLoading = false;
      print(e);
    }

    notifyListeners();
  }

  // Add a method to set the selected cafe
  Future<void> setSelectedCafe(String cafeSlug) async {
    _selectedCafe = await CafeService().getCafeBySlug(cafeSlug);
    notifyListeners(); // Notify listeners that the selected cafe has changed
  }
}
