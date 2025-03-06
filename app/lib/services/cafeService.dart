import 'dart:convert';
import 'package:app/config.dart';
import 'package:http/http.dart' as http;
import 'package:app/models/Cafe.dart';

class CafeService {
    /// Fetches a list of cafes sorted by name.
    Future<List<Cafe>> getAllCafeList() async {
        final uri = Uri.parse('${Config.apiUrl}/cafes');
        final response = await http.get(
            uri,
            headers: { 'Content-Type': 'application/json', });

        if (response.statusCode == 200) {
            final List<dynamic> cafesJson = json.decode(utf8.decode(response.bodyBytes))['items'];
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
}
