class MaintenanceModel {
  final String id;
  final String title;
  final String subtitle;
  final String priority; 
  final String status; 
  final DateTime dueDate;
  final DateTime createdAt;
  String? attachmentPath;

  MaintenanceModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    this.attachmentPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'priority': priority,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'attachmentPath': attachmentPath,
    };
  }

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      priority: json['priority'],
      status: json['status'],
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: DateTime.parse(json['createdAt']),
      attachmentPath: json['attachmentPath'],
    );
  }
}