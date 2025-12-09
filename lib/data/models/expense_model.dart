class ExpenseModel {
  final String id;
  final double amount;
  final String type; 
  final DateTime date;
  final DateTime createdAt;
  final String description;
  final String status; 
  final String? personName; 
  String? attachmentPath;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.createdAt,
    required this.description,
    required this.status,
    this.personName,
    this.attachmentPath,
  });

  bool get isExpense => type == 'expense';
  bool get isBorrowed => type == 'borrowed';
  bool get isLent => type == 'lent';
  bool get isPending => status == 'pending';
  bool get isSettled => status == 'settled';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'status': status,
      'personName': personName,
      'attachmentPath': attachmentPath,
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
      status: json['status'],
      personName: json['personName'],
      attachmentPath: json['attachmentPath'],
    );
  }

  ExpenseModel copyWith({
    double? amount,
    String? type,
    DateTime? date,
    String? description,
    String? status,
    String? personName,
    String? attachmentPath,
  }) {
    return ExpenseModel(
      id: id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      createdAt: createdAt,
      description: description ?? this.description,
      status: status ?? this.status,
      personName: personName ?? this.personName,
      attachmentPath: attachmentPath ?? this.attachmentPath,
    );
  }
}