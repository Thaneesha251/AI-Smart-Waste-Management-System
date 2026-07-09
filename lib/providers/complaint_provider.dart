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
    
    final local = await _storage.getComplaints();
    if (local.isEmpty) {
      _complaints = await _service.getComplaints();
      for (var c in _complaints) {
        await _storage.saveComplaint(c);
      }
    } else {
      _complaints = local;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addComplaint(Complaint complaint) async {
    _complaints.insert(0, complaint);
    await _storage.saveComplaint(complaint);
    notifyListeners();
  }

  Future<void> updateComplaint(Complaint updated) async {
    final index = _complaints.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _complaints[index] = updated;
      await _storage.updateStoredComplaints(_complaints);
      notifyListeners();
    }
  }

  Future<void> cancelComplaint(String id) async {
    final index = _complaints.indexWhere((c) => c.id == id);
    if (index != -1) {
      _complaints[index] = _complaints[index].copyWith(status: ComplaintStatus.cancelled);
      await _storage.updateStoredComplaints(_complaints);
      notifyListeners();
    }
  }
}
