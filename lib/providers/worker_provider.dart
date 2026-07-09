import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/complaint_service.dart';
import '../services/voice_assistant_service.dart';

class WorkerProvider with ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();
  final VoiceAssistantService _voiceService = VoiceAssistantService();
  
  bool _isOnDuty = false;
  List<Complaint> _tasks = [];
  bool _isLoading = false;
  String? _lastAnnouncedTaskId;

  bool get isOnDuty => _isOnDuty;
  List<Complaint> get tasks => _tasks;
  bool get isLoading => _isLoading;

  int get completedCount => _tasks.where((t) => t.status == ComplaintStatus.resolved).length;
  int get pendingCount => _tasks.where((t) => t.status != ComplaintStatus.resolved).length;

  void toggleDuty() {
    _isOnDuty = !_isOnDuty;
    if (_isOnDuty) {
      _checkForNewTasks();
    }
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _complaintService.getWorkerTasks();
      _checkForNewTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _checkForNewTasks() {
    if (!_isOnDuty) return;

    final pending = _tasks.where((t) => t.status != ComplaintStatus.resolved).toList();
    if (pending.isNotEmpty) {
      final latest = pending.first;
      if (latest.id != _lastAnnouncedTaskId) {
        _lastAnnouncedTaskId = latest.id;
        _voiceService.announceNewTask(latest.area, latest.wasteType);
      }
    }
  }

  Future<void> completeTask(String taskId, String afterImageUrl) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: ComplaintStatus.resolved,
      );
      _voiceService.announceCompletion();
      notifyListeners();
    }
  }
}
