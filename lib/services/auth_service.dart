import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://serviceonline.gov.in/configure/foreignHostAuth';
  static const String clientId = '464624';
  static const String authKey = 'Test@123';
  static const String userSecret = '312fb5609823b09a83660c84e9ede856afdc7b95871e98c1230b3ecce67a917d'; // Fixed for all users

  // Generate token API call
  static Future<Map<String, dynamic>> generateToken({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'client_id': clientId,
          'auth_key': authKey,
          'uid': email,
          'usecret': userSecret,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Store token if successful
        if (data['token'] != null) {
          await _saveToken(data['token']);
          await _saveEmail(email);
        }

        return {
          'success': true,
          'data': data,
          'message': 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Save token locally
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Save email locally
  static Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get stored email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
  }
}