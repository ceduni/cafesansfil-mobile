import 'dart:convert';
import 'package:app/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/models/user_model.dart';
//import 'package:app/config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
    final FlutterSecureStorage storage = const FlutterSecureStorage();

    Future<String?> login(String email, String password) async {
        final response = await http.post(
            Uri.parse('${Config.apiUrl}/auth/login'),
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: {
                'grant_type': 'password',
                'username': email,
                'password': password,
                'scope': '',
                'client_id': 'string', // Mettez votre Client ID ici
                'client_secret': 'string' // Mettez votre Client Secret ici
            });

        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            
            if (data['access_token'] != null) {
                String accessToken = data['access_token'];
                String refreshToken = data['refresh_token'];
                await storeToken(accessToken, refreshToken);

                return accessToken;
            } else {
                throw Exception('Auth Token not found in response: ${response.body}');
            }
        } else {
            throw Exception('Failed to login: ${response.body}');
        }
    }

    Future<void> logout() async {
        final token = await getToken();
        if (token != null) {
            await storage.delete(key: 'token'); // Suppression du token
            await storage.delete(key: 'refresh_token');
        }
    }

    Future<String?> refreshAccessToken() async {
        final refreshToken = await storage.read(key: 'refresh_token');
        if (refreshToken == null) {
            throw Exception("No refresh token available");
        }

        final response = await http.post(
            Uri.parse('${Config.apiUrl}/auth/refresh'),
            headers: { 'Content-Type': 'application/json' },
            body: {
                'refresh_token': refreshToken,
                'client_id': 'string',
                'client_secret': 'string'
            });

        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            String newAccessToken = data['access_token'];
            if (data['refresh_token'] != null) {
                await storeToken(newAccessToken, data['refresh_token']);
            } else {
                // Keep the same refresh token and store the new access token
                await storeToken(newAccessToken, refreshToken);
            }
            return newAccessToken;
        } else {
            throw Exception('Failed to refresh token: ${response.body}');
        }
    }

    Future<void> storeUserDetails() async {
        final token = await storage.read(key: 'token');
        
        if (token == null) {
            throw Exception("No token found");
        }

        final response = await http.get(
            Uri.parse('${Config.apiUrl}/users/me'),
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
            });

        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            String email = data['email'];
            String firstName = data['first_name'];
            String lastName = data['last_name'];
            String matricule = data['matricule'];
            String username = data['username'];
            String photoUrl = data['photo_url'];
            if ((data['email'] != null) &&
                (data['first_name'] != null) &&
                (data['last_name'] != null) &&
                (data['matricule'] != null) &&
                (data['username'] != null)) {
                await storage.write(key: 'email', value: email);
                await storage.write(key: 'first_name', value: firstName);
                await storage.write(key: 'last_name', value: lastName);
                await storage.write(key: 'username', value: username);
                await storage.write(key: 'matricule', value: matricule);
                await storage.write(key: 'photo_url', value: photoUrl);
            }
        } else {
        throw Exception('Failed to refresh token: ${response.body}');
        }
    }

    Future<List<String>> getUserCafes(String username) async {
        final token = await storage.read(key: 'token');
        if (token == null) {
            throw Exception("No token found");
        }

        final response = await http.get(
        Uri.parse(
            '${Config.apiUrl}/user/$username/cafes'),
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
            },
        );


      print(">>>> DEBUG getUserCafes");

        if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            return data.map<String>((json) => json['name'] as String).toList();
        } else {
            throw Exception('Failed to load cafes: ${response.body}');
        }
    }

    Future<void> storeToken(String accessToken, String refreshToken) async {
        await storage.write(key: 'token', value: accessToken);
        await storage.write(key: 'refresh_token', value: refreshToken);
    }

    Future<String?> getFirstName() async => storage.read(key: 'first_name');
    Future<String?> getLastName() async => storage.read(key: 'last_name');
    Future<String?> getToken() async => storage.read(key: 'token');
    Future<String?> getEmail() async => storage.read(key: 'email');
    Future<String?> getUsername() async => storage.read(key: 'username');
    Future<String?> getUserRole() async => storage.read(key: 'role');
    Future<String?> getMatricule() async => storage.read(key: 'matricule');
    Future<String?> getPhotoUrl() async => storage.read(key: 'photo_url');

    bool isTokenExpired(String token) => JwtDecoder.isExpired(token);

    User? getUserFromToken(String token) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        return User.fromJson(decodedToken);
    }
}

// le code est inspiré de https://medium.com/@hpatilabhi10/understanding-jwt-tokens-in-flutter-0dfd0f495715
