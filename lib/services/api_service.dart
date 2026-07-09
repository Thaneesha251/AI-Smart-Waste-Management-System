import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/constants.dart';

class ApiService {
  final String baseUrl = AppConstants.apiBaseUrl;

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      return _handleResponse(response);
    } catch (e) {
      print('GET Error: $e');
      throw Exception('Connection failed');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('POST Error: $e');
      throw Exception('Connection failed');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw Exception(body['detail'] ??
          'Request failed with status ${response.statusCode}');
    }
  }
}
