import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const baseUrl = 'http://10.0.2.2:8080';
  static String? currentUserId;
  static String? currentUsername;
  static Future<String?> submit({
    required String username,
    required String password,
    required bool isLogin,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/${isLogin ? 'login' : 'register'}'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        currentUserId = jsonDecode(res.body)['id'];
        currentUsername = username;
        return null;
      }
      return jsonDecode(res.body)['error'] as String? ?? 'Something went wrong';
    } catch (_) {
      return 'Could not reach server';
    }
  }
}
