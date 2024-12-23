import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/modeles/Cafe.dart';

class CafeService {
  Future<List<Cafe>> getAllCafeList() async {
    final response = await http.get(
        Uri.parse(
            'https://cafesansfil-api-r0kj.onrender.com/api/cafes?sort_by=name&page=1&limit=40'),
        headers: {
          'Content-Type': 'application/json',
        });
    if (response.statusCode == 200) {
      /*final List<dynamic> cafesJson =
          json.decode(response.body);*/ // Decode the response body
      final List<dynamic> cafesJson = json
          .decode(utf8.decode(response.bodyBytes)); // Decode the response body

      // Mapping through the list of cafes and converting to Cafe objects
      List<Cafe> cafes = cafesJson.map((json) {
        return Cafe.fromJson(json);
      }).toList();

      return cafes;
    } else {
      throw Exception('Failed to load cafes');
    }
  }

  // Modify this method to use the new CafeModel as well
  Future<Cafe> getCafeBySlug(String cafeSlug) async {
    final response = await http.get(
        Uri.parse(
            'https://cafesansfil-api-r0kj.onrender.com/api/cafes/$cafeSlug'),
        headers: {
          'Content-Type': 'application/json',
        });

    if (response.statusCode == 200) {
      //final data = jsonDecode(response.body);
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return Cafe.fromJson(data);
    } else {
      throw Exception('Failed to load cafe: ${response.statusCode}');
    }
  }
}
