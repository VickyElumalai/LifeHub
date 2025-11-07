class TodoModel {
  final String id;
  final String title;
  final String category;
  final String priority;
  final DateTime dueDate;
  final DateTime createdAt;
  bool isCompleted;
  String? attachmentPath;

  TodoModel({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    this.isCompleted = false,
    this.attachmentPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'attachmentPath': attachmentPath,
    };
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      priority: json['priority'],
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      attachmentPath: json['attachmentPath'],
    );
  }
}