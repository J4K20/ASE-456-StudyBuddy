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

  static Future<void> createSet(
    String title,
    bool public, [
    List<Map<String, String>> cards = const [],
  ]) async {
    await http.post(
      Uri.parse('${AuthService.baseUrl}/sets'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'userId': AuthService.currentUserId,
        'title': title,
        'public': public,
        'cards': cards,
      }),
    );
  }

  static Future<Map<String, dynamic>> getSet(String id) async {
    final res = await http.get(Uri.parse('${AuthService.baseUrl}/set/$id'));
    return jsonDecode(res.body);
  }
}
