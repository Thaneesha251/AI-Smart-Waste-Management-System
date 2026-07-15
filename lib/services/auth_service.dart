import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Login
  Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(response);
  }

  // Register
  Future<Map<String, dynamic>> register(
      String fullName,
      String email,
      String password,
      String phone,
      String role,
      ) async {
    final response = await _apiService.post('/auth/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
    });
    return Map<String, dynamic>.from(response);
  }

  // Get logged-in user profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiService.get('/users/me');
    return Map<String, dynamic>.from(response);
  }

  // Update logged-in user profile
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final response = await _apiService.put('/users/me', data);
    return Map<String, dynamic>.from(response);
  }

  // Temporary placeholder until backend route is implemented
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return {
      'success': false,
      'message': 'Forgot password feature not implemented yet'
    };
  }

  // Temporary placeholder until backend route is implemented
  Future<Map<String, dynamic>> resetPassword(
      String token, String newPassword) async {
    return {
      'success': false,
      'message': 'Reset password feature not implemented yet'
    };
  }
}