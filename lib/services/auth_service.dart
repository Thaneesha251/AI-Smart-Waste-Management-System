import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'username': username,
        'password': password,
      });
      return response;
    } catch (e) {
      // Mock for development if backend not running
      if (username == 'citizen' && password == 'password') {
        return {
          'user_id': 1,
          'username': 'citizen',
          'role': 'citizen',
          'message': 'Login successful (Mock)'
        };
      } else if (username == 'worker' && password == 'password') {
        return {
          'user_id': 2,
          'username': 'worker',
          'role': 'worker',
          'message': 'Login successful (Mock)'
        };
      }
      rethrow;
    }
  }

  Future<User> register(
      String username, String email, String password, UserRole role) async {
    final response = await _apiService.post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
      'role': role.toString().split('.').last,
    });
    return User.fromJson(response);
  }
}
