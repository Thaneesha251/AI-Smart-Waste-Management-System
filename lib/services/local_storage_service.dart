import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/complaint.dart';

class LocalStorageService {
  static const String _userKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _complaintsKey = 'user_complaints';
  static const String _locationKey = 'current_location';

  // --- Auth ---
  
  Future<void> registerUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final usersList = await getAllUsers();
    usersList.removeWhere((u) => u.email.toLowerCase() == user.email.toLowerCase());
    usersList.add(user);
    final usersJson = usersList.map((u) => u.toJson()).toList();
    await prefs.setString(_userKey, json.encode(usersJson));
  }

  Future<List<User>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_userKey);
    if (usersStr == null || usersStr.isEmpty) return [];
    try {
      final List<dynamic> usersJson = json.decode(usersStr);
      return usersJson.map((u) => User.fromJson(u)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCurrentUser(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));
    }
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_currentUserKey);
    if (userStr == null || userStr.isEmpty) return null;
    try {
      return User.fromJson(json.decode(userStr));
    } catch (e) {
      return null;
    }
  }

  Future<void> updateStoredUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.email.toLowerCase() == updatedUser.email.toLowerCase());
    if (index != -1) {
      users[index] = updatedUser;
      final usersJson = users.map((u) => u.toJson()).toList();
      await prefs.setString(_userKey, json.encode(usersJson));
    }
  }

  // --- Complaints ---

  Future<void> saveComplaint(Complaint complaint) async {
    final prefs = await SharedPreferences.getInstance();
    final complaints = await getComplaints();
    complaints.removeWhere((c) => c.id == complaint.id);
    complaints.insert(0, complaint);
    final complaintsJson = complaints.map((c) => c.toJson()).toList();
    await prefs.setString(_complaintsKey, json.encode(complaintsJson));
  }

  Future<List<Complaint>> getComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final complaintsStr = prefs.getString(_complaintsKey);
    if (complaintsStr == null || complaintsStr.isEmpty) return [];
    try {
      final List<dynamic> complaintsJson = json.decode(complaintsStr);
      return complaintsJson.map((c) => Complaint.fromJson(c)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateStoredComplaints(List<Complaint> complaints) async {
    final prefs = await SharedPreferences.getInstance();
    final complaintsJson = complaints.map((c) => c.toJson()).toList();
    await prefs.setString(_complaintsKey, json.encode(complaintsJson));
  }

  // --- Location ---

  Future<void> saveLocation(Map<String, String> location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, json.encode(location));
  }

  Future<Map<String, String>?> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locStr = prefs.getString(_locationKey);
    if (locStr == null || locStr.isEmpty) return null;
    try {
      return Map<String, String>.from(json.decode(locStr));
    } catch (e) {
      return null;
    }
  }
}
