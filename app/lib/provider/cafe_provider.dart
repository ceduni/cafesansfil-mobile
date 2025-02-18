import 'package:app/models/Cafe.dart';
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
   /// Updates category name and description
  void updateCategoryDetails({
    required String oldCategoryName,
    required String newCategoryName,
    required String newDescription,
  }) {
    if (_selectedCafe != null) {
      for (var item in _selectedCafe!.menuItems) {
        if (item.category == oldCategoryName) {
          item.category = newCategoryName;
          item.description = newDescription;
        }
      }
      notifyListeners();
    }
  }

      // TODO: updated data to backend
      //CafeService().updateMenuItems(_selectedCafe!.cafeId, _selectedCafe!.menuItems);
   // }
 // }
//}

/// Updates selected item list in category
  void updateCategoryItems(List<String> itemsIds, String newCategory){
    if(_selectedCafe != null){
      for(var item in _selectedCafe!.menuItems){
        if(itemsIds.contains(item.itemId)){
          item.category = newCategory;
        } else if(item.category == newCategory){
          item.category = "Autres";
        }
      }
      notifyListeners();
    }
  }
  //TODO: update data to backend

  /// Add new category with selected items
  void addNewCategory(String newCategoryName, String newDescription, List<String> selectedItemsIds){
    if(_selectedCafe != null){
      bool categoryExists = _selectedCafe!.menuItems.any((item) => item.category == newCategoryName);

      if(categoryExists){
        _errorMessage = "La catégorie existe déjà";
      } else {
        for(var item in _selectedCafe!.menuItems){
          if(selectedItemsIds.contains(item.itemId)){
            item.category = newCategoryName;
          }
        }
        notifyListeners();
      }
    }
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