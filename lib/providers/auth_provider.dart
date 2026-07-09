import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
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
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // 1. Check for Demo Worker
    if (email.toLowerCase() == demoWorkerEmail && password == demoWorkerPassword) {
      final demoWorker = User(
        fullName: "Selvam Kumar",
        email: demoWorkerEmail,
        phone: "+91 98765 43210",
        password: demoWorkerPassword,
        role: UserRole.worker,
      );
      _user = demoWorker;
      await _storage.saveCurrentUser(demoWorker);
      _isLoading = false;
      notifyListeners();
      return null;
    }

    // 2. Check Local Storage Users (for registered Citizens)
    final users = await _storage.getAllUsers();
    
    User? foundUser;
    try {
      foundUser = users.firstWhere(
        (u) => u.email.trim().toLowerCase() == email.trim().toLowerCase()
      );
    } catch (e) {
      foundUser = null;
    }

    _isLoading = false;
    notifyListeners();

    if (foundUser == null) {
      return "Account not found. Please register first.";
    }

    if (foundUser.password != password) {
      return "Incorrect password. Please try again.";
    }

    _user = foundUser;
    await _storage.saveCurrentUser(foundUser);
    notifyListeners();
    return null; // Success
  }

  Future<void> register(User user) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    await _storage.registerUser(user);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await _storage.saveCurrentUser(null);
    notifyListeners();
  }

  Future<void> updateProfile(User updatedUser) async {
    _user = updatedUser;
    await _storage.saveCurrentUser(updatedUser);
    await _storage.updateStoredUser(updatedUser);
    notifyListeners();
  }
}
