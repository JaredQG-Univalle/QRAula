import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<String> getText(String path) async {
    final res = await http.get(_uri(path));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return res.body;
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final res = await http.get(_uri(path));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
