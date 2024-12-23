import 'dart:convert';

import 'package:app/config.dart';
import 'package:app/modeles/Cafe.dart';
import 'package:app/modeles/Stock.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/FlashMessage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StockService {
  final String baseUrl = "${Config.baseUrl}/stocks";
  final AuthService _authService = AuthService();

  StockService({dynamic});

  Future<List<Stock>> fetchStocks() async {
    var url = Uri.parse(baseUrl);
    var response = await http.get(url).timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData['Stock'] != null) {
        List<dynamic> stocksJson = jsonData['Stock'];
        List<Stock> stocks =
            stocksJson.map((json) => Stock.fromJson(json)).toList();
        return stocks;
      } else {
        throw Exception('Stock data is not available');
      }
    } else {
      throw Exception('Failed to load stock from $baseUrl');
    }
  }

  Future<MenuItem> getMenuItem(String cafeSlug, String itemSlug) async {
    final response = await http.get(
      Uri.parse(
        "https://cafesansfil-api-r0kj.onrender.com/api/cafes/$cafeSlug/menu/$itemSlug",
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return MenuItem.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to get menu item from cafe $cafeSlug');
    }
  }

  Future<String> updateMenuItem(
      String cafeSlug, String itemSlug, MenuItem item) async {
    final token = await _authService.getToken();
    String message = "";

    // Create a map of the updated item
    final Map<String, dynamic> body = {
      "category": item.category,
      "description": item.description,
      "image_url": item.imageUrl,
      "in_stock": item.inStock,
      "name": item.name,
      "options": item.options
          .map((option) => option.toJson())
          .toList(), // Convert options to JSON
      "price": item.price,
      "tags": item.tags,
    };

    final response = await http.put(
        Uri.parse(
            "https://cafesansfil-api-r0kj.onrender.com/api/cafes/$cafeSlug/menu/$itemSlug"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: json.encode(body));

    // Check the response status
    if (response.statusCode == 200) {
      message = 'Success: Menu item updated successfully';
      return message;
    } else {
      // Handle error response
      throw Exception('Failed to update menu item: ${response.body}');
    }
  }

  Future<String> removeMenuItem(String cafeSlug, String itemSlug) async {
    final token = await _authService.getToken();
    String message = "";
    final response = await http.delete(
        Uri.parse(
            "https://cafesansfil-api-r0kj.onrender.com/api/cafes/$cafeSlug/menu/$itemSlug"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        });
    if (response.statusCode == 200) {
      message = 'Menu item removed successfully.';
      message = 'Success: $message';
      return message;
    } else {
      message =
          'Failed to remove menu item. Status code: ${response.statusCode} - ${response.body}';
      throw Exception('Failed to remove menu item from cafe $cafeSlug');
    }
  }

  List<String> getLowStocksProductsNames(List<Stock> stocks) {
    List<String> alerts = [];

    for (Stock stock in stocks) {
      // Example condition for low stock
      if (stock.quantity < 10) {
        String alert = stock.itemName;
        alerts.add(alert);
      }
    }
    return alerts;
  }

/*
void main() async {
  var stockService = new StockService();
  List<Stock> stocks = await stockService.fetchStocks();
  print(stocks);
  List<Stock> lowStocks = Stock.lowQuantity(stocks);
  print(lowStocks);
}
*/

  void checkProductQuantities(List<Stock> lowStocks, BuildContext context) {
    for (Stock stock in lowStocks) {
      // Example condition for low stock
      showFlashMessage(context,
          'Le Product ${stock.itemName} a une quantite faible en stock!');
    }
  }

  void showFlashMessage(BuildContext context, String message) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: FlashMessage(message: message),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // Remove the flash message after 3 seconds
    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
}
