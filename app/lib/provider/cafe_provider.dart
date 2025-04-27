import 'package:app/models/Cafe.dart';
import 'package:app/services/cafeService.dart';
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

  List<Categories> _categoryNames =[];
  List<Categories> get categoryNames =>_categoryNames;

  Future<void> fetchCategory(String cafeSlug) async{
    try{
      _categoryNames = await CafeService().getCategories(cafeSlug);
       print("DEBUG - Fetched Categories: $_categoryNames");
       if (_selectedCafe != null) {
      for (var item in _selectedCafe!.menuItems) {
       
        item.categories = item.categories.map((cat) {
          return _categoryNames.firstWhere(
            (fullCat) => fullCat.id == cat.id,
            orElse: () => cat,
          );
        }).toList();
      }
    }
      notifyListeners();
    }catch(e){
      print("ERROR - Failed to fetch category: $e");
    }
  }


  List<MenuItem> getMenuItemsbyCategory(String category) {
    return _selectedCafe?.menuItems.where((item) => item.categories.contains(category)).toList() ?? [];
  }
    List<MenuItem> get getMenuItems => _selectedCafe?.menuItems ?? [];

  Future<void> fetchCafe(String cafeSlug) async {
    _isLoading = true;
    try {
      _cafe = _selectedCafe;
      _selectedCafe = await CafeService().getCafeBySlug(cafeSlug);
      List<MenuItem> fetchMenuItems = await CafeService().getMenuItems(cafeSlug);
      _selectedCafe!.menuItems = fetchMenuItems; 

        print("DEBUG - Fetched ${_selectedCafe!.menuItems.length} Menu Items");

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
    required Categories oldCategory,
    required Categories newCategory,
    required String newDescription,
  }) {
    if (_selectedCafe != null) {
      for (var item in _selectedCafe!.menuItems) {
        if (item.categories.any((cat) => cat.id == oldCategory.id)) {
        item.categories.removeWhere((cat) => cat.id == oldCategory.id);
        if (!item.categories.any((cat) => cat.id == newCategory.id)) {
          item.categories.add(newCategory);
          }
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
  void updateCategoryItems(List<String> selectedItemsIds, Categories newCategory) async{
    if(_selectedCafe != null){
      for(var item in _selectedCafe!.menuItems){
        final hasCategory = item.categories.any((cat) => cat.id == newCategory.id);
      final shouldHave = selectedItemsIds.contains(item.itemId);

      if (shouldHave && !hasCategory) {
        item.categories.add(newCategory);
      } else if (!shouldHave && hasCategory) {
        item.categories.removeWhere((cat) => cat.id == newCategory.id);
      }
      await CafeService().updateMenuItem(_selectedCafe!.slug,item);
    }
    notifyListeners();
    }
  }
  //TODO: update data to backend


  Future<List<CafeRoleInfo>> getAdminCafe(String username) async {
    // Fetch all cafes first
    _allCafes = await CafeService().getAllCafeList();
    print(">>>>DEBUG provider getAdminCafe: ${_allCafes}");
    _cafesListRoles.clear();

     _cafesListRoles.add(CafeRoleInfo(
              cafeName: _allCafes[0].name, cafeId: _allCafes[0].cafeId, role: "Admin"));
    print(">>>>DEBUG provider getAdminCafe: ${_cafesListRoles}");
    // for (var cafe in _allCafes) {
    //   for (var staff in cafe.staff) {
    //     if (staff.username == username && staff.role == "Admin") {
    //       _cafesListRoles.add(CafeRoleInfo(
    //           cafeName: cafe.name, cafeId: cafe.cafeId, role: staff.role));
    //       break;
    //     }
    //   }
    //   if (_cafesListRoles.isNotEmpty) {
    //     break;
    //   }
    // }
    return _cafesListRoles;
  }

  Future<void> setSelectedCafe(String cafeSlug) async {
    _selectedCafe = await CafeService().getCafeBySlug(cafeSlug);
    notifyListeners(); // Notify listeners that the selected cafe has changed
  }

  void addNewCategory(Categories newCategory, String newDescription, List<String> selectedItemsIds) {
    if (_selectedCafe != null) {
    bool categoryExists = _selectedCafe!.menuItems
        .any((item) => item.categories.any((cat) => cat.id == newCategory.id));

    if (categoryExists) {
      _errorMessage = "La catégorie existe déjà";
      notifyListeners();
      return;
    }

    // Add category to selected items
    for (var item in _selectedCafe!.menuItems) {
      if (selectedItemsIds.contains(item.itemId)) {
        if (!item.categories.any((cat) => cat.id == newCategory.id)) {
          item.categories.add(newCategory);
        }
      }
    }
    
    notifyListeners();
  }
}
}