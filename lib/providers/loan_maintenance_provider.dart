import 'package:flutter/material.dart';
import 'package:life_hub/data/models/loan_maintenance_model.dart';
import 'package:life_hub/data/local/hive_service.dart';
import 'package:life_hub/data/local/notification_service.dart';

class LoanMaintenanceProvider extends ChangeNotifier {
  List<LoanMaintenanceModel> _itemList = [];
  
  List<LoanMaintenanceModel> get itemList => _itemList;
  
  // Loan getters
  List<LoanMaintenanceModel> get activeLoans => _itemList
      .where((item) => item.isLoan && item.status == 'active')
      .toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  
  List<LoanMaintenanceModel> get completedLoans => _itemList
      .where((item) => item.isLoan && item.status == 'completed')
      .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  int get totalActiveLoans => activeLoans.length;
  
  double get totalLoanAmount => activeLoans.fold(
    0.0, 
    (sum, loan) => sum + (loan.totalAmount ?? 0),
  );
  
  double get totalLoanPaid => activeLoans.fold(
    0.0, 
    (sum, loan) => sum + loan.totalPaid,
  );
  
  double get totalLoanRemaining => totalLoanAmount - totalLoanPaid;
  
  // Maintenance getters
  List<LoanMaintenanceModel> get activeMaintenance => _itemList
      .where((item) => item.isMaintenance && item.status == 'active')
      .toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  
  List<LoanMaintenanceModel> get completedMaintenance => _itemList
      .where((item) => item.isMaintenance && item.status == 'completed')
      .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  int get totalActiveMaintenance => activeMaintenance.length;
  
  // Common getters
  int get totalPending => _itemList
      .where((item) => item.status == 'active')
      .length;
  
  int get totalOverdue => _itemList
      .where((item) => item.isOverdue)
      .length;
  
  List<LoanMaintenanceModel> get dueSoonItems => _itemList
      .where((item) {
        final now = DateTime.now();
        final daysUntilDue = item.nextDueDate.difference(now).inDays;
        return item.status == 'active' && daysUntilDue <= 7 && daysUntilDue >= 0;
      })
      .toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

  LoanMaintenanceProvider() {
    loadData();
  }

  List<LoanMaintenanceModel> getActiveLoansByCategory(String category) {
    if (category == 'all') return activeLoans;
    return activeLoans.where((item) => item.category == category).toList();
  }

  List<LoanMaintenanceModel> getActiveMaintenanceByCategory(String category) {
    if (category == 'all') return activeMaintenance;
    return activeMaintenance.where((item) => item.category == category).toList();
  }

  Future<void> loadData() async {
    try {
      final data = await HiveService.getAllData('loanMaintenanceBox');
      _itemList = data
          .map((item) => LoanMaintenanceModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      _itemList.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading loan/maintenance data: $e');
    }
  }

  Future<void> addItem(LoanMaintenanceModel item, {bool enableNotifications = true}) async {
    try {
      debugPrint('📝 Adding ${item.type}: ${item.title}');
      
      await HiveService.saveData('loanMaintenanceBox', item.id, item.toJson());
      _itemList.add(item);
      _itemList.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      
      // Schedule notification if enabled and active
      if (enableNotifications && item.status == 'active') {
        await _scheduleNotification(item);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item: $e');
      rethrow;
    }
  }

  Future<void> updateItem(LoanMaintenanceModel item, {bool enableNotifications = true}) async {
    try {
      debugPrint('📝 Updating ${item.type}: ${item.title}');
      
      await HiveService.saveData('loanMaintenanceBox', item.id, item.toJson());
      final index = _itemList.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _itemList[index] = item;
        _itemList.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
        
        // Cancel existing notifications
        await NotificationService.cancelNotification(item.id);
        await NotificationService.cancelNotification('${item.id}_reminder');
        
        // Schedule new notification if active
        if (enableNotifications && item.status == 'active') {
          await _scheduleNotification(item);
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating item: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await HiveService.deleteData('loanMaintenanceBox', id);
      await NotificationService.cancelNotification(id);
      await NotificationService.cancelNotification('${id}_reminder');
      _itemList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  // Record loan payment
  Future<void> recordLoanPayment({
    required String loanId,
    required double amount,
    required String paymentMethod,
    String? transactionId,
    String? notes,
  }) async {
    try {
      final index = _itemList.indexWhere((item) => item.id == loanId);
      if (index != -1) {
        final loan = _itemList[index];
        
        // Create new payment
        final payment = PaymentModel(
          id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
          parentId: loanId,
          amount: amount,
          dueDate: loan.nextDueDate,
          paidDate: DateTime.now(),
          status: 'paid',
          transactionId: transactionId,
          paymentMethod: paymentMethod,
          notes: notes,
          createdAt: DateTime.now(),
          monthNumber: loan.completedMonths + 1,
        );
        
        // Add payment to list
        final updatedPayments = List<PaymentModel>.from(loan.payments)..add(payment);
        
        // Calculate next due date
        DateTime newNextDueDate;
        if (loan.paymentDay != null) {
          // Use specific payment day
          final now = DateTime.now();
          newNextDueDate = DateTime(
            now.month == 12 ? now.year + 1 : now.year,
            now.month == 12 ? 1 : now.month + 1,
            loan.paymentDay!.clamp(1, 31),
          );
        } else {
          // Add 30 days
          newNextDueDate = DateTime.now().add(const Duration(days: 30));
        }
        
        // Check if loan is completed
        String newStatus = loan.status;
        if (loan.totalMonths != null && updatedPayments.length >= loan.totalMonths!) {
          newStatus = 'completed';
        }
        
        final updatedLoan = loan.copyWith(
          payments: updatedPayments,
          nextDueDate: newNextDueDate,
          status: newStatus,
        );
        
        // Check if notifications are enabled
        final notificationsEnabled = await HiveService.getData('settingsBox', 'notifications') ?? true;
        
        await updateItem(updatedLoan, enableNotifications: notificationsEnabled && newStatus == 'active');
      }
    } catch (e) {
      debugPrint('Error recording loan payment: $e');
      rethrow;
    }
  }

  // Mark maintenance as completed
  Future<void> markMaintenanceAsCompleted(String id) async {
    try {
      final index = _itemList.indexWhere((item) => item.id == id);
      if (index != -1) {
        final maintenance = _itemList[index];
        
        // Cancel current notifications
        await NotificationService.cancelNotification(id);
        await NotificationService.cancelNotification('${id}_reminder');
        
        // Calculate next due date based on recurrence
        DateTime newNextDueDate;
        String newStatus = maintenance.status;
        
        switch (maintenance.recurrence) {
          case 'monthly':
            newNextDueDate = DateTime(
              DateTime.now().year,
              DateTime.now().month + 1,
              DateTime.now().day,
            );
            break;
          case 'quarterly':
            newNextDueDate = DateTime(
              DateTime.now().year,
              DateTime.now().month + 3,
              DateTime.now().day,
            );
            break;
          case 'halfyearly':
            newNextDueDate = DateTime(
              DateTime.now().year,
              DateTime.now().month + 6,
              DateTime.now().day,
            );
            break;
          case 'yearly':
            newNextDueDate = DateTime(
              DateTime.now().year + 1,
              DateTime.now().month,
              DateTime.now().day,
            );
            break;
          case 'custom':
            if (maintenance.customRecurrenceDays != null) {
              newNextDueDate = DateTime.now().add(
                Duration(days: maintenance.customRecurrenceDays!),
              );
            } else {
              newNextDueDate = DateTime.now().add(const Duration(days: 30));
            }
            break;
          case 'none':
          default:
            // For non-recurring, mark as completed
            newStatus = 'completed';
            newNextDueDate = maintenance.nextDueDate;
        }
        
        final updatedMaintenance = maintenance.copyWith(
          status: newStatus,
          lastDoneDate: DateTime.now(),
          nextDueDate: newNextDueDate,
        );
        
        // Check if notifications are enabled
        final notificationsEnabled = await HiveService.getData('settingsBox', 'notifications') ?? true;
        
        await updateItem(updatedMaintenance, enableNotifications: notificationsEnabled && newStatus == 'active');
      }
    } catch (e) {
      debugPrint('Error marking maintenance as completed: $e');
      rethrow;
    }
  }

  Future<void> _scheduleNotification(LoanMaintenanceModel item) async {
    try {
      final now = DateTime.now();
      final dueDate = item.nextDueDate;
      
      if (item.isLoan) {
        // For loans: Notify 3 days before and on due date at 9 AM
        final threeDaysBefore = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day - 3,
          9,
          0,
        );
        final onDueDate = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
          9,
          0,
        );
        
        debugPrint('💰 Scheduling loan notifications for: ${item.title}');
        debugPrint('   Due date: $dueDate');
        
        // Calculate expected payment amount
        String amountText = '';
        if (item.averagePayment > 0) {
          amountText = ' - ₹${item.averagePayment.toStringAsFixed(0)}';
        } else if (item.totalAmount != null && item.totalMonths != null) {
          final avgPayment = item.totalAmount! / item.totalMonths!;
          amountText = ' - ₹${avgPayment.toStringAsFixed(0)}';
        }
        
        if (threeDaysBefore.isAfter(now)) {
          debugPrint('   3-day reminder: $threeDaysBefore');
          await NotificationService.scheduleTaskNotification(
            id: '${item.id}_reminder',
            title: '💰 Loan Payment Due in 3 Days',
            content: '${item.title}$amountText',
            scheduledTime: threeDaysBefore,
          );
        }
        
        if (onDueDate.isAfter(now)) {
          debugPrint('   Due date reminder: $onDueDate');
          final monthInfo = item.totalMonths != null
              ? ' - Month ${item.completedMonths + 1}/${item.totalMonths}'
              : '';
          await NotificationService.scheduleTaskNotification(
            id: item.id,
            title: '💸 Loan Payment Due Today!',
            content: '${item.title}$amountText$monthInfo',
            scheduledTime: onDueDate,
          );
        }
      } else {
        // For maintenance: Use reminderDays (default: 1 day before) and on due date
        final reminderDays = item.reminderDays ?? 1;
        final reminderDate = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day - reminderDays,
          9,
          0,
        );
        final onDueDate = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
          9,
          0,
        );
        
        debugPrint('🔧 Scheduling maintenance notifications for: ${item.title}');
        debugPrint('   Due date: $dueDate');
        
        if (reminderDate.isAfter(now)) {
          debugPrint('   Reminder: $reminderDate ($reminderDays days before)');
          await NotificationService.scheduleTaskNotification(
            id: '${item.id}_reminder',
            title: '🔧 Maintenance Due in $reminderDays Day${reminderDays > 1 ? 's' : ''}',
            content: '${item.title}${item.maintenanceType != null ? ' - ${item.maintenanceType}' : ''}',
            scheduledTime: reminderDate,
          );
        }
        
        if (onDueDate.isAfter(now)) {
          debugPrint('   Due date reminder: $onDueDate');
          await NotificationService.scheduleTaskNotification(
            id: item.id,
            title: '⚠️ Maintenance Due Today!',
            content: '${item.title} - ${item.category.toUpperCase()}',
            scheduledTime: onDueDate,
          );
        }
      }
      
      debugPrint('✅ Notifications scheduled successfully');
    } catch (e) {
      debugPrint('❌ Failed to schedule notification: $e');
    }
  }

  LoanMaintenanceModel? getItemById(String id) {
    try {
      return _itemList.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}