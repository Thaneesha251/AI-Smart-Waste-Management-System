import '../models/complaint.dart';
import 'api_service.dart';

class ComplaintService {
  final ApiService _apiService = ApiService();

  Future<List<Complaint>> getComplaints() async {
    final response = await _apiService.get('/complaints/my');
    if (response['success'] == true) {
      final List<dynamic> data = response['data'];
      return data.map((c) => Complaint.fromJson(c)).toList();
    }
    throw Exception(response['message'] ?? 'Failed to fetch complaints');
  }

  Future<List<Complaint>> getWorkerTasks() async {
    final response = await _apiService.get('/complaints/all');
    if (response['success'] == true) {
      final List<dynamic> data = response['data'];
      return data.map((c) => Complaint.fromJson(c)).toList();
    }
    throw Exception(response['message'] ?? 'Failed to fetch tasks');
  }

  Future<Complaint> createComplaint(Complaint complaint) async {
    // Only send fields expected by ComplaintCreate schema
    final payload = {
      'title': complaint.title,
      'description': complaint.description,
      'location': complaint.location,
      'area': complaint.area,
      'zone': complaint.zone,
      'priority': complaint.priority,
      'wasteType': complaint.wasteType,
      'imageUrl': complaint.imageUrl,
    };

    final response = await _apiService.post('/complaints/create', payload);
    if (response['success'] == true) {
      return Complaint.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to create complaint');
  }

  Future<Complaint> updateComplaint(Complaint complaint) async {
    if (complaint.id == null) throw Exception("Complaint ID is missing");

    final payload = {
      'title': complaint.title,
      'description': complaint.description,
      'priority': complaint.priority,
      'wasteType': complaint.wasteType,
    };

    final response = await _apiService.put('/complaints/update/${complaint.id}', payload);
    if (response['success'] == true) {
      return Complaint.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to update complaint');
  }

  Future<Map<String, dynamic>> predictWaste(String filePath) async {
    final response = await _apiService.multipartPost('/ai/predict', filePath);
    return response;
  }

  Future<Map<String, dynamic>> cancelComplaint(int id) async {
    final response = await _apiService.put('/complaints/cancel/$id', {});
    return response;
  }
}
