class LoanMaintenanceModel {
  final String id;
  final String title;
  final String type; // 'loan' or 'maintenance'
  
  // Common fields
  final String status; // active, completed
  final DateTime createdAt;
  final List<String> attachmentPaths;
  final String? notes;
  final DateTime nextDueDate;
  final int reminderDays; // Days before to remind
  final int? paymentDay; // Day of month for payments (1-31) - ADDED THIS
  
  // Loan-specific fields
  final double? totalAmount;
  final int? totalMonths;
  final DateTime? loanStartDate;
  final int completedMonths; // Count of completed payments
  
  // Maintenance-specific fields
  final String? recurrence; // none, monthly, quarterly, halfyearly, yearly, custom
  final int? customRecurrenceDays;
  final DateTime? lastDoneDate;
  
  // Payment history for tracking
  final List<PaymentRecord> paymentHistory;

  LoanMaintenanceModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.nextDueDate,
    required this.reminderDays,
    this.paymentDay, // ADDED THIS
    this.attachmentPaths = const [],
    this.notes,
    // Loan fields
    this.totalAmount,
    this.totalMonths,
    this.loanStartDate,
    this.completedMonths = 0,
    // Maintenance fields
    this.recurrence,
    this.customRecurrenceDays,
    this.lastDoneDate,
    // Payment history
    this.paymentHistory = const [],
  });

  // Computed properties
  bool get isLoan => type == 'loan';
  bool get isMaintenance => type == 'maintenance';
  
  bool get isOverdue => DateTime.now().isAfter(nextDueDate) && status == 'active';
  
  bool get isDueToday {
    final now = DateTime.now();
    return nextDueDate.year == now.year &&
           nextDueDate.month == now.month &&
           nextDueDate.day == now.day &&
           status == 'active';
  }

  // For loans
  int get remainingMonths {
    if (totalMonths == null) return 0;
    return totalMonths! - completedMonths;
  }

  double get progressPercentage {
    if (totalMonths == null || totalMonths == 0) return 0;
    return (completedMonths / totalMonths!) * 100;
  }

  double get totalPaid {
    return paymentHistory
        .where((p) => p.isPaid)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get remainingAmount {
    if (totalAmount == null) return 0.0;
    return totalAmount! - totalPaid;
  }

  double get averagePayment {
    final paidPayments = paymentHistory.where((p) => p.isPaid).toList();
    if (paidPayments.isEmpty) return 0.0;
    return totalPaid / paidPayments.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'reminderDays': reminderDays,
      'paymentDay': paymentDay, // ADDED THIS
      'attachmentPaths': attachmentPaths,
      'notes': notes,
      // Loan fields
      'totalAmount': totalAmount,
      'totalMonths': totalMonths,
      'loanStartDate': loanStartDate?.toIso8601String(),
      'completedMonths': completedMonths,
      // Maintenance fields
      'recurrence': recurrence,
      'customRecurrenceDays': customRecurrenceDays,
      'lastDoneDate': lastDoneDate?.toIso8601String(),
      // Payment history
      'paymentHistory': paymentHistory.map((p) => p.toJson()).toList(),
    };
  }

  factory LoanMaintenanceModel.fromJson(Map<String, dynamic> json) {
    return LoanMaintenanceModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      nextDueDate: DateTime.parse(json['nextDueDate']),
      reminderDays: json['reminderDays'] ?? 1,
      paymentDay: json['paymentDay'], // ADDED THIS
      attachmentPaths: json['attachmentPaths'] != null
          ? List<String>.from(json['attachmentPaths'])
          : [],
      notes: json['notes'],
      // Loan fields
      totalAmount: json['totalAmount'] != null 
          ? (json['totalAmount'] as num).toDouble() 
          : null,
      totalMonths: json['totalMonths'],
      loanStartDate: json['loanStartDate'] != null
          ? DateTime.parse(json['loanStartDate'])
          : null,
      completedMonths: json['completedMonths'] ?? 0,
      // Maintenance fields
      recurrence: json['recurrence'],
      customRecurrenceDays: json['customRecurrenceDays'],
      lastDoneDate: json['lastDoneDate'] != null
          ? DateTime.parse(json['lastDoneDate'])
          : null,
      // Payment history
      paymentHistory: json['paymentHistory'] != null
          ? (json['paymentHistory'] as List)
              .map((p) => PaymentRecord.fromJson(p))
              .toList()
          : [],
    );
  }

  LoanMaintenanceModel copyWith({
    String? title,
    String? status,
    DateTime? nextDueDate,
    int? reminderDays,
    int? paymentDay, // ADDED THIS
    List<String>? attachmentPaths,
    String? notes,
    // Loan fields
    double? totalAmount,
    int? totalMonths,
    DateTime? loanStartDate,
    int? completedMonths,
    // Maintenance fields
    String? recurrence,
    int? customRecurrenceDays,
    DateTime? lastDoneDate,
    // Payment history
    List<PaymentRecord>? paymentHistory,
  }) {
    return LoanMaintenanceModel(
      id: id,
      title: title ?? this.title,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      reminderDays: reminderDays ?? this.reminderDays,
      paymentDay: paymentDay ?? this.paymentDay, // ADDED THIS
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      totalMonths: totalMonths ?? this.totalMonths,
      loanStartDate: loanStartDate ?? this.loanStartDate,
      completedMonths: completedMonths ?? this.completedMonths,
      recurrence: recurrence ?? this.recurrence,
      customRecurrenceDays: customRecurrenceDays ?? this.customRecurrenceDays,
      lastDoneDate: lastDoneDate ?? this.lastDoneDate,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }
}

class PaymentRecord {
  final String id;
  final double amount;
  final DateTime paidDate;
  final int monthNumber;
  final bool isPaid;
  final String? notes;

  PaymentRecord({
    required this.id,
    required this.amount,
    required this.paidDate,
    required this.monthNumber,
    this.isPaid = true,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'paidDate': paidDate.toIso8601String(),
      'monthNumber': monthNumber,
      'isPaid': isPaid,
      'notes': notes,
    };
  }

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      paidDate: DateTime.parse(json['paidDate']),
      monthNumber: json['monthNumber'],
      isPaid: json['isPaid'] ?? true,
      notes: json['notes'],
    );
  }
}