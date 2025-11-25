class EventModel {
  final String id;
  final String title;
  final DateTime dateTime;
  final DateTime createdAt;
  final Recurrence recurrence; 
  final List<String> reminderMinutes; // e.g., ['60', '1440'] for 1hr and 1day
  String? location;
  String? attachmentPath;

  EventModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.createdAt,
    required this.recurrence,
    required this.reminderMinutes,
    this.location,
    this.attachmentPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': dateTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'recurrence': recurrence.name,
      'reminderMinutes': reminderMinutes,
      'location': location,
      'attachmentPath': attachmentPath,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      dateTime: DateTime.parse(json['startTime']),
      createdAt: DateTime.parse(json['createdAt']),
      recurrence: (json['recurrence'] as String).toRecurrence,
      reminderMinutes: List<String>.from(json['reminderMinutes'] ?? []),
      location: json['location'],
      attachmentPath: json['attachmentPath'],
    );
  }

  EventModel copyWith({
    String? title,
    DateTime? dateTime,
    Recurrence? recurrence,
    List<String>? reminderMinutes,
    String? location,
    String? attachmentPath,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      createdAt: createdAt,
      recurrence: recurrence ?? this.recurrence,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      location: location ?? this.location,
      attachmentPath: attachmentPath ?? this.attachmentPath,
    );
  }

  
}

enum Recurrence { once, daily,  yearly }
extension RecurrenceExtension on String {
  Recurrence get toRecurrence {
    return Recurrence.values.firstWhere(
      (e) => e.name == this,
      orElse: () => Recurrence.once,
    );
  }
}