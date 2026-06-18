import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // The Android emulator reaches the host machine via 10.0.2.2, not localhost.
  // Desktop and web can use localhost directly.
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
  
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }
  
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
  
  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data};
      } else if (response.statusCode == 401) {
        await clearToken();
        return {'success': false, 'error': 'Token expired'};
      } else {
        return {'success': false, 'error': 'Failed to get user'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  static Future<void> logout() async {
    await clearToken();
  }

  // ---- Authed request helpers ----------------------------------------------
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET that returns the decoded JSON (List or Map) or throws on error.
  static Future<dynamic> getJson(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: await _authHeaders());
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception((body is Map && body['error'] != null) ? body['error'] : 'Request failed (${res.statusCode})');
  }

  /// POST that returns the decoded JSON or throws on error.
  static Future<dynamic> postJson(String path, [Map<String, dynamic>? data]) async {
    final res = await http.post(Uri.parse('$baseUrl$path'),
        headers: await _authHeaders(), body: jsonEncode(data ?? {}));
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception((body is Map && body['error'] != null) ? body['error'] : 'Request failed (${res.statusCode})');
  }

  // ---- Worker self-service -------------------------------------------------
  static Future<List> openTasks() async => await getJson('/me/tasks') as List;
  static Future<void> applyToTask(int taskId, String pitch) async =>
      await postJson('/me/applications', {'task_id': taskId, 'pitch': pitch});
  static Future<List> myApplications() async => await getJson('/me/applications') as List;
  static Future<Map<String, dynamic>> myWallet() async =>
      Map<String, dynamic>.from(await getJson('/me/wallet') as Map);
  static Future<List> myNotifications() async => await getJson('/me/notifications') as List;
  static Future<Map<String, dynamic>> submitKyc(Map<String, dynamic> data) async =>
      Map<String, dynamic>.from(await postJson('/me/kyc', data) as Map);
}
