import 'package:flutter/material.dart';

enum ComplaintStatus { pending, assigned, inProgress, resolved, cancelled }

class Complaint {
  final String id;
  final String title;
  final String description;
  final String location;
  final String area;
  final String zone;
  final ComplaintStatus status;
  final String priority;
  final String wasteType;
  final DateTime createdAt;
  final String assignedAuthority;
  final DateTime expectedResolution;
  final String? imageUrl; // Local file path or network URL
  final String? afterImageUrl;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.area,
    required this.zone,
    required this.status,
    required this.priority,
    required this.wasteType,
    required this.createdAt,
    required this.assignedAuthority,
    required this.expectedResolution,
    this.imageUrl,
    this.afterImageUrl,
  });

  String get statusString {
    switch (status) {
      case ComplaintStatus.pending: return 'Pending';
      case ComplaintStatus.assigned: return 'Assigned';
      case ComplaintStatus.inProgress: return 'In Progress';
      case ComplaintStatus.resolved: return 'Resolved';
      case ComplaintStatus.cancelled: return 'Cancelled';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case ComplaintStatus.pending: return Colors.orange;
      case ComplaintStatus.assigned: return Colors.blue;
      case ComplaintStatus.inProgress: return Colors.purple;
      case ComplaintStatus.resolved: return Colors.green;
      case ComplaintStatus.cancelled: return Colors.red;
    }
  }

  Color getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      default: return Colors.green;
    }
  }

  Complaint copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? area,
    String? zone,
    ComplaintStatus? status,
    String? priority,
    String? wasteType,
    DateTime? createdAt,
    String? assignedAuthority,
    DateTime? expectedResolution,
    String? imageUrl,
    String? afterImageUrl,
  }) {
    return Complaint(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      area: area ?? this.area,
      zone: zone ?? this.zone,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      wasteType: wasteType ?? this.wasteType,
      createdAt: createdAt ?? this.createdAt,
      assignedAuthority: assignedAuthority ?? this.assignedAuthority,
      expectedResolution: expectedResolution ?? this.expectedResolution,
      imageUrl: imageUrl ?? this.imageUrl,
      afterImageUrl: afterImageUrl ?? this.afterImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'area': area,
      'zone': zone,
      'status': status.index,
      'priority': priority,
      'wasteType': wasteType,
      'createdAt': createdAt.toIso8601String(),
      'assignedAuthority': assignedAuthority,
      'expectedResolution': expectedResolution.toIso8601String(),
      'imageUrl': imageUrl,
      'afterImageUrl': afterImageUrl,
    };
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      area: json['area'],
      zone: json['zone'],
      status: ComplaintStatus.values[json['status']],
      priority: json['priority'],
      wasteType: json['wasteType'],
      createdAt: DateTime.parse(json['createdAt']),
      assignedAuthority: json['assignedAuthority'],
      expectedResolution: DateTime.parse(json['expectedResolution']),
      imageUrl: json['imageUrl'],
      afterImageUrl: json['afterImageUrl'],
    );
  }
}
