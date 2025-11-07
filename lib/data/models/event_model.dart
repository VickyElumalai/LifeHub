class EventModel {
  final String id;
  final String title;
  final String location;
  final String priority;
  final DateTime dateTime;
  final DateTime createdAt;
  String? attachmentPath;

  EventModel({
    required this.id,
    required this.title,
    required this.location,
    required this.priority,
    required this.dateTime,
    required this.createdAt,
    this.attachmentPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'priority': priority,
      'startTime': dateTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'attachmentPath': attachmentPath,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      priority: json['priority'],
      dateTime: DateTime.parse(json['startTime']),
      createdAt: DateTime.parse(json['createdAt']),
      attachmentPath: json['attachmentPath'],
    );
  }
}