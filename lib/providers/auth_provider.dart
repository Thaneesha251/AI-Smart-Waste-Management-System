import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../core/constants/constants.dart';

class AuthProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Demo Credentials
  static const String demoWorkerEmail = "worker@swachhai.gov.in";
  static const String demoWorkerPassword = "worker123";

  Future<void> init() async {
    _user = await _storage.getCurrentUser();
    if (isAuthenticated) {
      await fetchProfile();
    }
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _authService.getProfile();
      if (response['success'] == true) {
        _user = User.fromJson(response['data']);
        await _storage.saveCurrentUser(_user);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch Profile Error: $e');
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      if (response != null && response['success'] == true) {
        final data = response['data'];
        final token = data['access_token'];
        final userData = data['user'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        
        _user = User.fromJson(userData);
        await _storage.saveCurrentUser(_user);
        
        _isLoading = false;
        notifyListeners();
        return null;
      } else {
        _isLoading = false;
        notifyListeners();
        return response?['message'] ?? "Login failed. Please check your credentials.";
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> register(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.register(
        user.fullName, 
        user.email, 
        user.password ?? '', 
        user.phone ?? '', 
        user.role.toString().split('.').last
      );
      
      _isLoading = false;
      notifyListeners();
      
      if (response != null && response['success'] == true) {
        return null;
      } else {
        return response?['message'] ?? "Registration failed. Please try again.";
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await _storage.saveCurrentUser(null);
    notifyListeners();
  }

  Future<void> updateProfile(User updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.updateProfile({
        'fullName': updatedUser.fullName,
        'phone': updatedUser.phone,
        'area': updatedUser.area,
        'address': updatedUser.address,
        if (updatedUser.profileImage != null) 'profileImage': updatedUser.profileImage,
        if (updatedUser.password != null) 'password': updatedUser.password,
      });

      if (response['success'] == true) {
        _user = User.fromJson(response['data']);
        await _storage.saveCurrentUser(_user);
        await _storage.updateStoredUser(_user!);
      }
    } catch (e) {
      print('Update Profile Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(email);
      if (response != null && response['success'] == true) {
        return null;
      } else {
        return response?['message'] ?? "Failed to send reset link.";
      }
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> resetPassword(String token, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(token, newPassword);
      if (response != null && response['success'] == true) {
        return null;
      } else {
        return response?['message'] ?? "Failed to reset password.";
      }
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
