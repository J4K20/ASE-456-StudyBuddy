import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class SetService {
  static Future<List<dynamic>> getSets() async {
    final res = await http.get(
      Uri.parse('${AuthService.baseUrl}/sets/${AuthService.currentUserId}'),
    );
    return jsonDecode(res.body);
  }

  static Future<void> createSet(String title) async {
    await http.post(
      Uri.parse('${AuthService.baseUrl}/sets'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'userId': AuthService.currentUserId, 'title': title}),
    );
  }
}
