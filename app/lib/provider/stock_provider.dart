import 'package:app/config.dart';
import 'package:app/models/Stock.dart';
import 'package:app/services/StockService.dart';
import 'package:flutter/material.dart';
import 'package:app/models/fournisseur.dart';

class StockProvider with ChangeNotifier {
    List<Stock> _Stocks = [];
    List<Fournisseur> _fournisseurs = [];
    List<String> lowStockProcductName = [];

    String cafeName = Config.cafeName;
    bool _isLoading = false;
    String? _errorMessage;

    get Stocks => _Stocks;
    get isLoading => _isLoading;
    List<Fournisseur> get fournisseurs => _fournisseurs;
    get errorMessage => _errorMessage;
    bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;
    List<String> get lowStockProcductNameList => lowStockProcductName;

    StockProvider() {
        fetchStock();
        fetchFournisseurs();
    }

    Future<void> fetchStock() async {
        _isLoading = true;
        try {
        _Stocks = await StockService().fetchStocks();
        lowStockProcductName = StockService().getLowStocksProductsNames(_Stocks);
        _isLoading = false;
        } catch (e) {
        // Handle error
        _errorMessage = e.toString();
        _isLoading = false;
        print(e);
        }

        notifyListeners();
    }
    Future<void> fetchFournisseurs() async {
        _isLoading = true;
    notifyListeners();

    try {
      _fournisseurs = await StockService().fetchFournisseurs(); // Ensure this function exists in `StockService`
    } catch (e) {
      _errorMessage = "Failed to fetch suppliers: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add Stock Item
  Future<void> addStockItem(Stock stock) async {
    try {
      await StockService().addStockItem(stock);
      _Stocks.add(stock);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to add stock: $e";
    }
  }

  // Set Fournisseurs List (Manual Update)
  void setFournisseurs(List<Fournisseur> fournisseurs) {
    _fournisseurs = fournisseurs;
    notifyListeners();
  }
}
