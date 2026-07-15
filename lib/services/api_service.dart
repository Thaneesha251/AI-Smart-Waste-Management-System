import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/constants.dart';

class ApiService {
  final String baseUrl = AppConstants.apiBaseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('GET Error: $e');
      throw Exception('Connection failed');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('POST Error: $e');
      throw Exception('Connection failed');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('PUT Error: $e');
      throw Exception('Connection failed');
    }
  }

  Future<dynamic> multipartPost(String endpoint, String filePath, {Map<String, String>? fields}) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type'); // Let http set boundary
      
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      if (fields != null) request.fields.addAll(fields);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      print('Multipart POST Error: $e');
      throw Exception('Upload failed');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? body['detail'] ??
          'Request failed with status ${response.statusCode}');
    }
  }
}
