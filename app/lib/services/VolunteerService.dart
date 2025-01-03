import 'dart:convert';
import 'package:app/config.dart';
import 'package:http/http.dart' as http;
import 'package:app/modeles/Volunteer.dart';
import 'package:app/services/auth_service.dart';

class VolunteerService {
  //final String baseUrl = "${Config.baseUrl}/cafes/${Config.cafeName}/volunteer";
  final AuthService _authService = AuthService();

  VolunteerService({dynamic});

  Future<List<Volunteer>> fetchVolunteers(String cafeName) async {
    var url = Uri.parse("${Config.baseUrl}/cafes/$cafeName/volunteer");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData['volunteers'] != null) {
        print("in json volunteers tab");

        List<dynamic> volunteersJson = jsonData['volunteers'];

        List<Volunteer> volunteers =
            volunteersJson.map((json) => Volunteer.fromJson(json)).toList();

        print(volunteers);

        return volunteers;
      } else {
        throw Exception('Volunteers data is not available');
      }
    } else {
      throw Exception('Failed to load volunteers from Url');
    }
  }

  Future<String> postVolunteer(
      String cafeName, String matricule, String role) async {
    String message = "";
    final url = Uri.parse('${Config.baseUrl}/cafes/$cafeName/volunteer');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({"userName": matricule, "Role": role});
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      print(responseJson);
      message = responseJson['message'];
      message = 'Success: $message';
    } else {
      message = 'Failed: ${response.statusCode}';
    }
    return message;
  }

  Future<String> addVolunteer(
      String cafeSlug, String username, String role) async {
    String message = "";
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse(
          'https://cafesansfil-api-r0kj.onrender.com/api/cafes/$cafeSlug/staff'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'role': role,
        'username': username,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      print(responseJson);
      //message = responseJson['message'];
      message = 'New Volunteer added successfully';
      message = 'Success: $message';
    } else {
      message = 'Failed: ${response.statusCode}-${response.body}';
    }
    return message;
  }

  Future<String> deleteVolunteer(String cafeSlug, String username) async {
    final token = await _authService.getToken();
    String message = "";
    final response = await http.delete(
        Uri.parse(
            'https://cafesansfil-api-r0kj.onrender.com/api/cafes/$cafeSlug/staff/$username'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      print(responseJson);
      //message = responseJson['message'] ?? 'Volunteer deleted successfully.';
      message = 'Volunteer deleted successfully.';
      message = 'Success: $message';
    } else {
      message = 'Failed: ${response.statusCode} - ${response.body}';
    }
    return message;
  }
}
