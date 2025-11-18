class LoanMaintenanceModel {
  final String id;
  final String title;
  final String type; // 'loan' or 'maintenance'
  final String category; // For loans: bike, home, chittu, personal | For maintenance: vehicle, home, appliance
  
  // Common fields
  final String status; // active, completed, pending
  final DateTime createdAt;
  final List<String> attachmentPaths;
  final String? notes;
  
  // Loan-specific fields
  final double? totalAmount; // Total loan amount
  final int? totalMonths; // Total duration in months
  final DateTime? loanStartDate;
  final DateTime? loanEndDate;
  final int? paymentDay; // Day of month for payment (1-31)
  final double? interestRate; // Interest rate percentage
  final String? loanProvider; // Bank/Finance company name
  final String? accountNumber;
  
  // Maintenance-specific fields
  final String? maintenanceType; // insurance, service, general
  final int? reminderDays; // Days before to remind
  final DateTime? lastDoneDate;
  final String? recurrence; // none, monthly, quarterly, halfyearly, yearly, custom
  final int? customRecurrenceDays;
  
  // Common date field
  final DateTime nextDueDate;
  
  // Payment/Transaction history
  final List<PaymentModel> payments;

  LoanMaintenanceModel({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.nextDueDate,
    this.attachmentPaths = const [],
    this.notes,
    // Loan fields
    this.totalAmount,
    this.totalMonths,
    this.loanStartDate,
    this.loanEndDate,
    this.paymentDay,
    this.interestRate,
    this.loanProvider,
    this.accountNumber,
    // Maintenance fields
    this.maintenanceType,
    this.reminderDays,
    this.lastDoneDate,
    this.recurrence,
    this.customRecurrenceDays,
    // Payments
    this.payments = const [],
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

  // For loans - calculate total paid
  double get totalPaid {
    return payments
        .where((p) => p.status == 'paid')
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  // For loans - remaining amount
  double get remainingAmount {
    if (totalAmount == null) return 0.0;
    return totalAmount! - totalPaid;
  }

  // For loans - completed months
  int get completedMonths {
    return payments.where((p) => p.status == 'paid').length;
  }

  // For loans - remaining months
  int get remainingMonths {
    if (totalMonths == null) return 0;
    return totalMonths! - completedMonths;
  }

  // For loans - progress percentage
  double get progressPercentage {
    if (totalMonths == null || totalMonths == 0) return 0;
    return (completedMonths / totalMonths!) * 100;
  }

  // For loans - average payment amount
  double get averagePayment {
    final paidPayments = payments.where((p) => p.status == 'paid').toList();
    if (paidPayments.isEmpty) return 0.0;
    return totalPaid / paidPayments.length;
  }

  // Get display subtitle based on type
  String get displaySubtitle {
    if (isLoan) {
      if (totalAmount != null && totalMonths != null) {
        return '₹${totalAmount!.toStringAsFixed(0)} • $totalMonths months';
      }
      return loanProvider ?? '';
    } else {
      return maintenanceType ?? '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'category': category,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'attachmentPaths': attachmentPaths,
      'notes': notes,
      // Loan fields
      'totalAmount': totalAmount,
      'totalMonths': totalMonths,
      'loanStartDate': loanStartDate?.toIso8601String(),
      'loanEndDate': loanEndDate?.toIso8601String(),
      'paymentDay': paymentDay,
      'interestRate': interestRate,
      'loanProvider': loanProvider,
      'accountNumber': accountNumber,
      // Maintenance fields
      'maintenanceType': maintenanceType,
      'reminderDays': reminderDays,
      'lastDoneDate': lastDoneDate?.toIso8601String(),
      'recurrence': recurrence,
      'customRecurrenceDays': customRecurrenceDays,
      // Payments
      'payments': payments.map((p) => p.toJson()).toList(),
    };
  }

  factory LoanMaintenanceModel.fromJson(Map<String, dynamic> json) {
    return LoanMaintenanceModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      category: json['category'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      nextDueDate: DateTime.parse(json['nextDueDate']),
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
      loanEndDate: json['loanEndDate'] != null
          ? DateTime.parse(json['loanEndDate'])
          : null,
      paymentDay: json['paymentDay'],
      interestRate: json['interestRate'] != null
          ? (json['interestRate'] as num).toDouble()
          : null,
      loanProvider: json['loanProvider'],
      accountNumber: json['accountNumber'],
      // Maintenance fields
      maintenanceType: json['maintenanceType'],
      reminderDays: json['reminderDays'],
      lastDoneDate: json['lastDoneDate'] != null
          ? DateTime.parse(json['lastDoneDate'])
          : null,
      recurrence: json['recurrence'],
      customRecurrenceDays: json['customRecurrenceDays'],
      // Payments
      payments: json['payments'] != null
          ? (json['payments'] as List)
              .map((p) => PaymentModel.fromJson(p))
              .toList()
          : [],
    );
  }

  LoanMaintenanceModel copyWith({
    String? title,
    String? category,
    String? status,
    DateTime? nextDueDate,
    List<String>? attachmentPaths,
    String? notes,
    // Loan fields
    double? totalAmount,
    int? totalMonths,
    DateTime? loanStartDate,
    DateTime? loanEndDate,
    int? paymentDay,
    double? interestRate,
    String? loanProvider,
    String? accountNumber,
    // Maintenance fields
    String? maintenanceType,
    int? reminderDays,
    DateTime? lastDoneDate,
    String? recurrence,
    int? customRecurrenceDays,
    // Payments
    List<PaymentModel>? payments,
  }) {
    return LoanMaintenanceModel(
      id: id,
      title: title ?? this.title,
      type: type,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      totalMonths: totalMonths ?? this.totalMonths,
      loanStartDate: loanStartDate ?? this.loanStartDate,
      loanEndDate: loanEndDate ?? this.loanEndDate,
      paymentDay: paymentDay ?? this.paymentDay,
      interestRate: interestRate ?? this.interestRate,
      loanProvider: loanProvider ?? this.loanProvider,
      accountNumber: accountNumber ?? this.accountNumber,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      reminderDays: reminderDays ?? this.reminderDays,
      lastDoneDate: lastDoneDate ?? this.lastDoneDate,
      recurrence: recurrence ?? this.recurrence,
      customRecurrenceDays: customRecurrenceDays ?? this.customRecurrenceDays,
      payments: payments ?? this.payments,
    );
  }
}

class PaymentModel {
  final String id;
  final String parentId; // Loan/Maintenance ID
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status; // paid, pending, skipped
  final String? transactionId;
  final String paymentMethod; // online, cash, upi, card, cheque
  final String? notes;
  final DateTime createdAt;
  final int? monthNumber; // For loans to track which month payment

  PaymentModel({
    required this.id,
    required this.parentId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.transactionId,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.monthNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'monthNumber': monthNumber,
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      parentId: json['parentId'],
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null 
          ? DateTime.parse(json['paidDate']) 
          : null,
      status: json['status'],
      transactionId: json['transactionId'],
      paymentMethod: json['paymentMethod'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      monthNumber: json['monthNumber'],
    );
  }
}

// Category configuration helper
class LoanMaintenanceConfig {
  // Loan categories
  static const Map<String, Map<String, dynamic>> loanCategories = {
    'bike': {
      'icon': '🏍️',
      'label': 'Bike Loan/EMI',
      'color': 0xFF4facfe,
    },
    'home': {
      'icon': '🏠',
      'label': 'Home Loan/Gold Loan',
      'color': 0xFFf093fb,
    },
    'chittu': {
      'icon': '💰',
      'label': 'Chittu/Finance',
      'color': 0xFF43e97b,
    },
    'personal': {
      'icon': '💳',
      'label': 'Personal Loan',
      'color': 0xFFfa709a,
    },
  };

  // Maintenance categories
  static const Map<String, Map<String, dynamic>> maintenanceCategories = {
    'vehicle': {
      'icon': '🚗',
      'label': 'Vehicle Maintenance',
      'types': ['Insurance Renewal', 'Oil Change', 'Service', 'Tire Rotation', 'Battery Check'],
      'color': 0xFF4facfe,
    },
    'home': {
      'icon': '🏠',
      'label': 'Home Maintenance',
      'types': ['AC Service', 'Water Filter', 'Plumbing', 'Electrical', 'Painting'],
      'color': 0xFFf093fb,
    },
    'appliance': {
      'icon': '🔌',
      'label': 'Appliance Maintenance',
      'types': ['Refrigerator', 'Washing Machine', 'TV', 'Microwave', 'Other'],
      'color': 0xFF43e97b,
    },
  };
}