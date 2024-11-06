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
  List<Cafe> _allCafes = [];
  List<CafeRoleInfo> _cafesListRoles = [];

  get cafe => _cafe;
  get isLoading => _isLoading;
  get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;
  Cafe? get selectedCafe => _selectedCafe;
  List<Cafe> get allCafes => _allCafes;
  List<CafeRoleInfo> get cafesListRoles => _cafesListRoles;

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

  Future<List<CafeRoleInfo>> getRolesByUsername(String username) async {
    // Fetch all cafes first
    _allCafes = await CafeService().getAllCafeList();

    for (var cafe in _allCafes) {
      for (var staff in cafe.staff) {
        if (staff.username == username) {
          _cafesListRoles.add(CafeRoleInfo(
              cafeName: cafe.name, cafeSlug: cafe.slug, role: staff.role));
        }
      }
    }
    return _cafesListRoles;
  }

  // Add a method to set the selected cafe
  Future<void> setSelectedCafe(String cafeSlug) async {
    _selectedCafe = await CafeService().getCafeBySlug(cafeSlug);
    notifyListeners(); // Notify listeners that the selected cafe has changed
  }
}
