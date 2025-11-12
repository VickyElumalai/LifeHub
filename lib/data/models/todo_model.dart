class TodoModel {
  final String id;
  final String content;
  final String priority;
  final DateTime? endTime;
  final DateTime createdAt;
  String? voicePath;
  String? imagePath;
  String status;

  TodoModel({
    required this.id,
    required this.content,
    required this.priority,
    this.endTime,
    required this.createdAt,
    this.voicePath,
    this.imagePath,
    this.status = 'pending',
  });

  bool get isCompleted => status == 'completed';
  bool get isSkipped => status == 'skipped';
  bool get isPending => status == 'pending';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'priority': priority,
      'endTime': endTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'voicePath': voicePath,
      'imagePath': imagePath,
      'status': status,
    };
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      content: json['content'],
      priority: json['priority'],
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      voicePath: json['voicePath'],
      imagePath: json['imagePath'],
      status: json['status'] ?? 'pending',
    );
  }

  TodoModel copyWith({
    String? content,
    String? priority,
    DateTime? endTime,
    String? voicePath,
    String? imagePath,
    String? status,
  }) {
    return TodoModel(
      id: id,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt,
      voicePath: voicePath ?? this.voicePath,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
    );
  }
}