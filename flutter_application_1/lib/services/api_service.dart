import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/profile.dart';
import 'auth_storage.dart';

class RegisterResponse {
  final String? token;
  final Profile? profile;

  RegisterResponse({this.token, this.profile});
}

class ApiService {
  static const String baseUrl = 'https://stepbystep.wasl-x.com';

  // Register -> returns token and optional profile data
  static Future<RegisterResponse> register(Map<String, dynamic> payload) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;

      // token may appear as 'token' or inside 'data' — adapt
      String? token;
      if (body.containsKey('token')) token = body['token'] as String?;
      if (token == null && body.containsKey('data') && body['data'] is Map) {
        final d = body['data'] as Map<String, dynamic>;
        if (d.containsKey('token')) token = d['token'] as String?;
      }

      Profile? profile;
      if (body.containsKey('data') && body['data'] is Map) {
        final d = body['data'] as Map<String, dynamic>;
        // if backend returns user data in `data` or in `data.user`
        if (d.containsKey('user') && d['user'] is Map) {
          profile = Profile.fromJson(d['user'] as Map<String, dynamic>);
        } else {
          try {
            profile = Profile.fromJson(d);
          } catch (_) {
            profile = null;
          }
        }
      }

      return RegisterResponse(token: token, profile: profile);
    }

    throw Exception('Register failed: ${resp.statusCode} ${resp.body}');
  }

  static Future<Profile> getProfile() async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('No auth token');

    final resp = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return Profile.fromJson(data);
    }

    throw Exception('Get profile failed: ${resp.statusCode}');
  }

  static Future<Profile> updateProfile(Profile profile) async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('No auth token');

    final resp = await http.put(
      Uri.parse('$baseUrl/api/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(profile.toJson()),
    );

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return Profile.fromJson(data);
    }

    throw Exception('Update profile failed: ${resp.statusCode}');
  }
}
