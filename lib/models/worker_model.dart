class WorkerModel {
  final int id;
  final String name;
  final int assignedTasksCount;
  final int completedTasksCount;
  final bool isAvailable;
  final double? currentLatitude;
  final double? currentLongitude;

  WorkerModel({
    required this.id,
    required this.name,
    required this.assignedTasksCount,
    required this.completedTasksCount,
    required this.isAvailable,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Sanitation Worker',
      assignedTasksCount: json['assigned_tasks_count'] as int? ?? 0,
      completedTasksCount: json['completed_tasks_count'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'assigned_tasks_count': assignedTasksCount,
      'completed_tasks_count': completedTasksCount,
      'is_available': isAvailable,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
    };
  }

  WorkerModel copyWith({
    int? id,
    String? name,
    int? assignedTasksCount,
    int? completedTasksCount,
    bool? isAvailable,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      assignedTasksCount: assignedTasksCount ?? this.assignedTasksCount,
      completedTasksCount: completedTasksCount ?? this.completedTasksCount,
      isAvailable: isAvailable ?? this.isAvailable,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }
}
