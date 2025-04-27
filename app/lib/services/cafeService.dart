import 'dart:convert';
import 'package:app/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app/models/Cafe.dart';

class CafeService {
    /// Fetches a list of cafes sorted by name.
    Future<List<Cafe>> getAllCafeList() async {
        final uri = Uri.parse('${Config.apiUrl}/cafes');
        final response = await http.get(
            uri,
            headers: { 'Content-Type': 'application/json', });
        print("DEBUG - Réponse API brute: ${utf8.decode(response.bodyBytes)}"); // API fonctionne?
        if (response.statusCode == 200) {
            final List<dynamic> cafesJson = json.decode(utf8.decode(response.bodyBytes))['items'];
            print("DEBUG - JSON après conversion: $cafesJson"); // Vérifie si menu_items est bien extrait
            final List<Cafe> cafes = cafesJson.map((json) => Cafe.fromJson(json)).toList();
            print("DEBUG: ${cafes.length} cafes fetched");
            return cafes;
        } else {
            throw Exception('Failed to load cafes');
        }
    }

    /// Fetches a single cafe using its slug.
    Future<Cafe> getCafeBySlug(String cafeSlug) async {
        final uri = Uri.parse('${Config.apiUrl}/cafes/$cafeSlug');
        final response = await http.get(
            uri,
            headers: { 'Content-Type': 'application/json' });

        if (response.statusCode == 200) {
            final data = jsonDecode(utf8.decode(response.bodyBytes));
            return Cafe.fromJson(data);
        } else {
            throw Exception('Failed to load cafe: ${response.statusCode}');
        }
    }
    Future <List<MenuItem>> getMenuItems(String cafeSlug) async {
        final uri = Uri.parse('${Config.apiUrl}/cafes/$cafeSlug/menu/items');
        final response = await http.get(uri, headers: { 'Content-Type': 'application/json' });
        print("DEBUG - API Response Menu Items: ${utf8.decode(response.bodyBytes)}"); // Debugging

        if (response.statusCode == 200) {
      final List<dynamic> menuItemsJson = json.decode(utf8.decode(response.bodyBytes))['items'];
      final List<MenuItem> menuItems = menuItemsJson.map((json) => MenuItem.fromJson(json)).toList();
      print("DEBUG: ${menuItems.length} menu items fetched");
      return menuItems;
    } else {
      throw Exception('Failed to load menu items');
    }
    }

    //Modify le API après changement dans un item
    Future<void> updateMenuItem(String cafeSlug, MenuItem item) async {
    final url = Uri.parse('${Config.apiUrl}/cafes/$cafeSlug/menu/items/${item.itemId}');
// need to change pcq utilise uri
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": item.name,
        "slug": item.slug,
        "description": item.description,
        "price": item.price,
        "in_stock": item.inStock,
        "category_ids": item.categories.map((c) => c.id).toList(),
        "tags": item.tags,
        "image_url": item.imageUrl,
        "options": item.options.map((o) => o.toJson()).toList()
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update item ${item.itemId}");
    }
  }

    Future<List<Categories>> getCategories(String cafeSlug) async {
    final uri = Uri.parse('${Config.apiUrl}/cafes/$cafeSlug/menu/categories');
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    print("DEBUG - API Response Categories: ${utf8.decode(response.bodyBytes)}"); //debug

    if (response.statusCode == 200) {
      final List<dynamic> categoriesJson = json.decode(utf8.decode(response.bodyBytes));

      return categoriesJson.map((json) => Categories.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

}