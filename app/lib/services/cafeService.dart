import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/config.dart';
import 'package:app/modeles/Cafe.dart';
import 'package:uuid/uuid.dart';

class CafeService {
  /*
  Future<List<Cafe>> fetchCafes() async {
    var url = Uri.parse('${Config.baseUrl}/cafes');
    var response = await http.get(url).timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData['Cafes'] != null) {
        print("Cafe Service : json fetching");
        List<dynamic> cafesJson = jsonData['Cafes'];
        List<Cafe> cafes =
            cafesJson.map((json) => Cafe.fromJson(json)).toList();
        return cafes;
      } else {
        throw Exception('Cafes data is not available');
      }
    } else {
      throw Exception('Failed to load cafes from ${Config.baseUrl}');
    }
  }*/

  Future<Cafe> fetchCafeByName(String cafeName) async {
    var url = Uri.parse('${Config.baseUrl}/cafes/$cafeName');
    var response = await http.get(url).timeout(const Duration(seconds: 25));

    print("response : ${response.statusCode}");

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      print("JSON : $jsonData");

      if (jsonData['cafe'] != null) {
        print("Cafe Service : json fetching cafe by cafeName");

        print("jsondata cafe: ${jsonData['cafe']}");

        // Pas besoin de mapper, car c'est déjà un seul objet
        Cafe cafe = Cafe.fromJson(jsonData['cafe']);
        print("cafe : $cafe");
        return cafe;
      } else {
        throw Exception('Cafe data is not available for cafeName $cafeName');
      }
    } else {
      throw Exception(
          'Failed to load cafe for name $cafeName from ${Config.baseUrl}');
    }
  }

  Future<Cafe> getCafeBySlug(String cafeSlug) async {
    final response = await http.get(
        Uri.parse(
            'https://cafesansfil-api-r0kj.onrender.com/api/cafes/$cafeSlug'),
        headers: {
          'Content-Type': 'application/json',
        });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Assuming the data structure returned is a map that represents a Cafe
      return Cafe.fromJson(data);
    } else {
      // Handle the error according to your design
      throw Exception('Failed to load cafe: ${response.statusCode}');
    }
  }

  Future<List<Cafe>> getAllCafeList() async {
    final response = await http.get(
        Uri.parse(
            'https://cafesansfil-api-r0kj.onrender.com/api/cafes?sort_by=name&page=1&limit=40'),
        headers: {
          'Content-Type': 'application/json',
        });
    if (response.statusCode == 200) {
      final List<dynamic> cafesJson =
          json.decode(response.body); // Decode the response body

      // Mapping through the list of cafes and converting to Cafe objects
      List<Cafe> cafes = cafesJson.map((json) {
        final cafe = Cafe.fromJson(json);
        return Cafe(
          id: cafe.id, // Setting the id to an empty string as requested
          cafeId: cafe.cafeId,
          name: cafe.name,
          slug: cafe.slug,
          previousSlugs: cafe.previousSlugs,
          description: cafe.description,
          imageUrl: cafe.imageUrl,
          faculty: cafe.faculty,
          isOpen: cafe.isOpen,
          statusMessage: cafe.statusMessage,
          openingHours: cafe.openingHours,
          location: cafe.location,
          contact: cafe.contact,
          socialMedia: cafe.socialMedia,
          paymentMethods: cafe.paymentMethods,
          additionalInfo: cafe.additionalInfo,
          staff: cafe.staff,
          menuItems: cafe.menuItems,
        );
      }).toList();

      return cafes;
    } else {
      // Handle the error; you might want to throw an exception or return an empty list
      throw Exception('Failed to load cafes');
    }
  }
}
