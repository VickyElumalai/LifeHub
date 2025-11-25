import 'package:flutter/material.dart';
import 'package:life_hub/data/models/loan_maintenance_model.dart';
import 'package:life_hub/data/service/hive_service.dart';
import 'package:life_hub/data/service/notification_service.dart';

class LoanMaintenanceProvider extends ChangeNotifier {
  List<LoanMaintenanceModel> _itemList = [];
  
  List<LoanMaintenanceModel> get itemList => _itemList;

  
  
  // Loans - separate active and overdue
  List<LoanMaintenanceModel> get activeLoans => _itemList
      .where((item) => item.isLoan && item.status == 'active' && !item.isOverdue)
      .toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  
  List<LoanMaintenanceModel> get overdueLoans => _itemList
      .where((item) => item.isLoan && item.status == 'active' && item.isOverdue)
      .toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  
  // Maintenance - separate active and overdue
  List<LoanMaintenanceModel> get activeMaintenance => _itemList
      .where((item) => item.isMaintenance && item.status == 'active' && !item.isOverdue)
      .toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  
  List<LoanMaintenanceModel> get overdueMaintenance => _itemList
      .where((item) => item.isMaintenance && item.status == 'active' && item.isOverdue)
      .toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  
  // Stats for loans
  int get totalActiveLoans => activeLoans.length;
  int get totalOverdueLoans => overdueLoans.length;
  
  double get totalLoanAmount => [...activeLoans, ...overdueLoans].fold(
    0.0,
    (sum, loan) => sum + (loan.totalAmount ?? 0),
  );
  
  double get totalLoanPaid => [...activeLoans, ...overdueLoans].fold(
    0.0,
    (sum, loan) => sum + loan.totalPaid,
  );
  
  double get totalLoanRemaining => totalLoanAmount - totalLoanPaid;
  
  // Stats for maintenance
  int get totalActiveMaintenance => activeMaintenance.length;
  int get totalOverdueMaintenance => overdueMaintenance.length;

  int get totalCount => totalActiveLoans + totalActiveMaintenance;

  LoanMaintenanceProvider() {
    loadItemData();
  }

  Future<void> loadItemData() async {
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
      await HiveService.saveData('loanMaintenanceBox', item.id, item.toJson());
      _itemList.add(item);
      _itemList.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      
      // Schedule notification if enabled
      if (enableNotifications && item.status == 'active') {
        await NotificationService.scheduleLoanMaintenanceNotification(
          id: item.id,
          title: item.isLoan ? 'Loan Payment Reminder' : 'Maintenance Reminder',
          content: item.title,
          scheduledTime: item.nextDueDate,
          reminderDays: item.reminderDays,
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item: $e');
    }
  }

  Future<void> updateItem(LoanMaintenanceModel item, {bool enableNotifications = true}) async {
    try {
      await HiveService.saveData('loanMaintenanceBox', item.id, item.toJson());
      final index = _itemList.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _itemList[index] = item;
        _itemList.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
        
        // Update notification
        await NotificationService.cancelNotification(item.id);
        if (enableNotifications && item.status == 'active') {
          await NotificationService.scheduleLoanMaintenanceNotification(
            id: item.id,
            title: item.isLoan ? 'Loan Payment Reminder' : 'Maintenance Reminder',
            content: item.title,
            scheduledTime: item.nextDueDate,
            reminderDays: item.reminderDays,
          );
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  // Mark loan payment as completed - AUTO-CALCULATES NEXT DUE DATE
  Future<void> markLoanAsPaid({
    required String loanId,
    required double amount,
    String? notes,
  }) async {
    try {
      final index = _itemList.indexWhere((item) => item.id == loanId);
      if (index == -1) return;
      
      final loan = _itemList[index];
      if (!loan.isLoan) return;
      
      debugPrint('💰 Recording loan payment for: ${loan.title}');
      
      // Create new payment record
      final payment = PaymentRecord(
        id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        paidDate: DateTime.now(),
        monthNumber: loan.completedMonths + 1,
        isPaid: true,
        notes: notes,
      );
      
      // Calculate next due date based on paymentDay
      DateTime nextDue;
      if (loan.paymentDay != null) {
        final now = DateTime.now();
        int targetMonth = now.month + 1;
        int targetYear = now.year;
        
        if (targetMonth > 12) {
          targetMonth = 1;
          targetYear++;
        }
        
        // Handle day overflow (e.g., Feb 30 -> Feb 28)
        final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;
        final actualDay = loan.paymentDay! > lastDayOfMonth 
            ? lastDayOfMonth 
            : loan.paymentDay!;
        
        nextDue = DateTime(targetYear, targetMonth, actualDay);
      } else {
        // Fallback: add 30 days
        nextDue = DateTime.now().add(const Duration(days: 30));
      }
      
      // Check if loan is completed
      final newCompletedMonths = loan.completedMonths + 1;
      final newStatus = (loan.totalMonths != null && newCompletedMonths >= loan.totalMonths!)
          ? 'completed'
          : 'active';
      
      // Update loan
      final updatedLoan = loan.copyWith(
        completedMonths: newCompletedMonths,
        nextDueDate: nextDue,
        paymentHistory: [...loan.paymentHistory, payment],
        status: newStatus,
      );
      
      // Save to Hive FIRST
      await HiveService.saveData('loanMaintenanceBox', updatedLoan.id, updatedLoan.toJson());
      
      // Update local list IMMEDIATELY
      _itemList[index] = updatedLoan;
      
      // Sort list
      _itemList.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      
      // Update notification
      await NotificationService.cancelNotification(updatedLoan.id);
      if (newStatus == 'active') {
        await NotificationService.scheduleLoanMaintenanceNotification(
          id: updatedLoan.id,
          title: 'Loan Payment Reminder',
          content: updatedLoan.title,
          scheduledTime: updatedLoan.nextDueDate,
          reminderDays: updatedLoan.reminderDays,
        );
      }
      
      // Force UI update IMMEDIATELY
      notifyListeners();
      
      debugPrint('✅ Loan payment recorded successfully');
      debugPrint('   Completed: $newCompletedMonths/${loan.totalMonths}');
      debugPrint('   Next due: $nextDue');
      debugPrint('   Status: $newStatus');
      
    } catch (e) {
      debugPrint('❌ Error marking loan as paid: $e');
      rethrow;
    }
  }

  // Mark maintenance as completed - DOES NOT REMOVE, JUST UPDATES HISTORY
  Future<void> markMaintenanceAsCompleted({
    required String maintenanceId,
    String? notes,
  }) async {
    try {
      final index = _itemList.indexWhere((item) => item.id == maintenanceId);
      if (index != -1) {
        final maintenance = _itemList[index];
        
        if (!maintenance.isMaintenance) return;
        
        // Create maintenance completion record
        final completionRecord = PaymentRecord(
          id: 'maintenance_${DateTime.now().millisecondsSinceEpoch}',
          amount: 0.0, // No amount for maintenance
          paidDate: DateTime.now(),
          monthNumber: maintenance.paymentHistory.length + 1,
          isPaid: true,
          notes: notes,
        );
        
        // Calculate next due date based on recurrence
        DateTime? nextDue;
        String newStatus = maintenance.status;
        
        if (maintenance.recurrence == 'none') {
          // One-time maintenance - mark as completed (will be removed from active list)
          newStatus = 'completed';
          nextDue = maintenance.nextDueDate; // Keep same date
        } else {
          // Recurring maintenance - calculate next occurrence
          switch (maintenance.recurrence) {
            case 'monthly':
              nextDue = DateTime(
                maintenance.nextDueDate.year,
                maintenance.nextDueDate.month + 1,
                maintenance.nextDueDate.day,
              );
              break;
            case 'quarterly':
              nextDue = DateTime(
                maintenance.nextDueDate.year,
                maintenance.nextDueDate.month + 3,
                maintenance.nextDueDate.day,
              );
              break;
            case 'halfyearly':
              nextDue = DateTime(
                maintenance.nextDueDate.year,
                maintenance.nextDueDate.month + 6,
                maintenance.nextDueDate.day,
              );
              break;
            case 'yearly':
              nextDue = DateTime(
                maintenance.nextDueDate.year + 1,
                maintenance.nextDueDate.month,
                maintenance.nextDueDate.day,
              );
              break;
            case 'custom':
              if (maintenance.customRecurrenceDays != null) {
                nextDue = maintenance.nextDueDate.add(
                  Duration(days: maintenance.customRecurrenceDays!),
                );
              }
              break;
          }
        }
        
        if (nextDue != null) {
          final updatedMaintenance = maintenance.copyWith(
            nextDueDate: nextDue,
            lastDoneDate: DateTime.now(),
            paymentHistory: [...maintenance.paymentHistory, completionRecord],
            status: newStatus,
          );
          
          // CRITICAL: Save to Hive first
          await HiveService.saveData('loanMaintenanceBox', updatedMaintenance.id, updatedMaintenance.toJson());
          
          // CRITICAL: Update local list immediately
          _itemList[index] = updatedMaintenance;
          _itemList.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
          
          // Update notification
          await NotificationService.cancelNotification(updatedMaintenance.id);
          if (newStatus == 'active') {
            await NotificationService.scheduleLoanMaintenanceNotification(
              id: updatedMaintenance.id,
              title: 'Maintenance Reminder',
              content: updatedMaintenance.title,
              scheduledTime: updatedMaintenance.nextDueDate,
              reminderDays: updatedMaintenance.reminderDays,
            );
          }
          
          // CRITICAL: Force UI update
          notifyListeners();
          
          debugPrint('✅ Maintenance completed: ${updatedMaintenance.title}');
          debugPrint('   Next due: ${updatedMaintenance.nextDueDate}');
          debugPrint('   Status: ${updatedMaintenance.status}');
          debugPrint('   History count: ${updatedMaintenance.paymentHistory.length}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error marking maintenance as completed: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await HiveService.deleteData('loanMaintenanceBox', id);
      await NotificationService.cancelNotification(id);
      _itemList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting item: $e');
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