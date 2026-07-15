import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/complaint_service.dart';
import '../services/local_storage_service.dart';

class ComplaintProvider with ChangeNotifier {
  final ComplaintService _service = ComplaintService();
  final LocalStorageService _storage = LocalStorageService();
  
  List<Complaint> _complaints = [];
  bool _isLoading = false;

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;

  int get totalComplaints => _complaints.length;
  int get pendingComplaints => _complaints.where((c) => c.status == ComplaintStatus.pending).length;
  int get inProgressComplaints => _complaints.where((c) => c.status == ComplaintStatus.assigned || c.status == ComplaintStatus.inProgress).length;
  int get resolvedComplaints => _complaints.where((c) => c.status == ComplaintStatus.resolved).length;

  Future<void> init() async {
    await fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _complaints = await _service.getComplaints();
      await _storage.updateStoredComplaints(_complaints);
    } catch (e) {
      print('Fetch Error: $e');
      _complaints = await _storage.getComplaints();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _complaints = [];
    notifyListeners();
  }

  Future<void> addComplaint(Complaint complaint) async {
    try {
      final created = await _service.createComplaint(complaint);
      _complaints.insert(0, created);
      await _storage.saveComplaint(created);
    } catch (e) {
      print('Add Error: $e');
      // If offline, save locally but marked as pending (optional)
      _complaints.insert(0, complaint);
      await _storage.saveComplaint(complaint);
    }
    notifyListeners();
  }

  Future<void> updateComplaint(Complaint updated) async {
    try {
      final result = await _service.updateComplaint(updated);
      final index = _complaints.indexWhere((c) => c.id == result.id);
      if (index != -1) {
        _complaints[index] = result;
        await _storage.updateStoredComplaints(_complaints);
        notifyListeners();
      }
    } catch (e) {
      print('Update Error: $e');
      rethrow;
    }
  }

  Future<void> cancelComplaint(int id) async {
    try {
      final response = await _service.cancelComplaint(id);
      if (response['success'] == true) {
        final updated = Complaint.fromJson(response['data']);
        final index = _complaints.indexWhere((c) => c.id == id);
        if (index != -1) {
          _complaints[index] = updated;
          await _storage.updateStoredComplaints(_complaints);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Cancel Error: $e');
      rethrow;
    }
  }
}
