import 'dart:convert';
import 'package:app/config.dart';
import 'package:http/http.dart' as http;
import 'package:app/modeles/Shift.dart';

class ShiftService {
  final String baseUrl = '${Config.baseUrl}';

  Future<List<Shift>> getAllShifts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/shifts/all'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body)['shifts'];
        return jsonResponse.map((shift) => Shift.fromJson(shift)).toList();
      } else {
        throw Exception('Failed to load shifts');
      }
    } catch (e) {
      throw Exception('Error fetching shifts: $e');
    }
  }

  Future<Shift?> addStaff(String cafeName, String day, String hourName,
      String matricule, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shifts/$day/addStaff'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cafeName': cafeName,
        'hourName': hourName,
        'matricule': matricule,
        'name': name, // Include name in the request body
      }),
    );

    if (response.statusCode == 200) {
      return Shift.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add staff');
    }
  }

  Future<Shift?> confirmStaff(
      String cafeName, String day, String hourName, String matricule) async {
    final response = await http.put(
      Uri.parse('$baseUrl/shifts/$day/$hourName/confirmStaff'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cafeName': cafeName,
        'matricule': matricule,
      }),
    );

    if (response.statusCode == 200) {
      return Shift.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to confirm staff');
    }
  }

  Future<Shift?> removeStaff(
      String cafeName, String day, String hourName, String matricule) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/shifts/$day/removeStaff'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cafeName': cafeName,
        'hourName': hourName,
        'matricule': matricule,
      }),
    );

    if (response.statusCode == 200) {
      return Shift.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to remove staff');
    }
  }
}
