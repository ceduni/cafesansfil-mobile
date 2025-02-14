import 'package:app/modeles/Cafe.dart';
import 'package:app/services/CafeService.dart';
import 'package:flutter/material.dart';

class CafeProvider with ChangeNotifier {
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

  List<MenuItem> get getMenuItems => _selectedCafe?.menuItems ?? [];

  Future<void> fetchCafe() async {
    _isLoading = true;
    try {
      _cafe = _selectedCafe;

      _isLoading = false;
    } catch (e) {
      // Handle error
      _errorMessage = e.toString();
      _isLoading = false;
      print(e);
    }

    notifyListeners();
  }

  Future<List<CafeRoleInfo>> getVolunteerCafe(String username) async {
    // Fetch all cafes first
    _allCafes = await CafeService().getAllCafeList();
    _cafesListRoles.clear();

    for (var cafe in _allCafes) {
      for (var staff in cafe.staff) {
        if (staff.username == username && (staff.role != "Admin")) {
          _cafesListRoles.add(CafeRoleInfo(
              cafeName: cafe.name, cafeId: cafe.cafeId, role: staff.role));
        }
      }
    }
    return _cafesListRoles;
  }

  Future<List<CafeRoleInfo>> getAdminCafe(String username) async {
    // Fetch all cafes first
    _allCafes = await CafeService().getAllCafeList();
    _cafesListRoles.clear();

    for (var cafe in _allCafes) {
      for (var staff in cafe.staff) {
        if (staff.username == username && staff.role == "Admin") {
          _cafesListRoles.add(CafeRoleInfo(
              cafeName: cafe.name, cafeId: cafe.cafeId, role: staff.role));
          break;
        }
      }
      if (_cafesListRoles.isNotEmpty) {
        break;
      }
    }
    return _cafesListRoles;
  }

  Future<void> setSelectedCafe(String cafeSlug) async {
    _selectedCafe = await CafeService().getCafeBySlug(cafeSlug);
    notifyListeners(); // Notify listeners that the selected cafe has changed
  }
}
