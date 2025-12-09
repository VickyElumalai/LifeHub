import 'package:flutter/material.dart';
import 'package:life_hub/data/models/expense_model.dart';
import 'package:life_hub/data/service/hive_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenseList = [];
  double _monthlyBudget = 10000.0;
  
  List<ExpenseModel> get expenseList => _expenseList;
  double get monthlyBudget => _monthlyBudget;
  
  // Regular expenses (money you spent)
  List<ExpenseModel> get regularExpenses => _expenseList
      .where((e) => e.isExpense)
      .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  
  // Last week expenses (default view)
  List<ExpenseModel> get lastWeekExpenses {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return regularExpenses
        .where((e) => e.date.isAfter(weekAgo))
        .toList();
  }
  
  // This month expenses
  List<ExpenseModel> get thisMonthExpenses {
    final now = DateTime.now();
    return regularExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
  }
  
  // Money you borrowed (you owe)
  List<ExpenseModel> get borrowedMoney => _expenseList
      .where((e) => e.isBorrowed && e.isPending)
      .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  
  // Money you lent (others owe you)
  List<ExpenseModel> get lentMoney => _expenseList
      .where((e) => e.isLent && e.isPending)
      .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  
  // Settled borrowed/lent transactions
  List<ExpenseModel> get settledTransactions => _expenseList
      .where((e) => (e.isBorrowed || e.isLent) && e.isSettled)
      .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  
  // Total spent this month (only regular expenses)
  double get totalSpent {
    final now = DateTime.now();
    return regularExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }
  
  // Total borrowed (pending only)
  double get totalBorrowed => borrowedMoney.fold(0.0, (sum, e) => sum + e.amount);
  
  // Total lent (pending only)
  double get totalLent => lentMoney.fold(0.0, (sum, e) => sum + e.amount);
  
  double get remainingBudget => _monthlyBudget - totalSpent;
  
  double get budgetPercentage {
    if (_monthlyBudget == 0) return 0;
    return (totalSpent / _monthlyBudget * 100).clamp(0, 100);
  }

  // Add this method after the settledTransactions getter
  List<ExpenseModel> getFilteredSettledTransactions(String filter) {
    if (filter == 'all') {
      return settledTransactions;
    } else if (filter == 'borrowed') {
      return settledTransactions.where((e) => e.isBorrowed).toList();
    } else if (filter == 'lent') {
      return settledTransactions.where((e) => e.isLent).toList();
    }
    return settledTransactions;
  }
  
  ExpenseProvider() {
    loadExpenseData();
    loadBudget();
  }
  
  
  Future<void> loadExpenseData() async {
    try {
      final data = await HiveService.getAllData('expenseBox');
      _expenseList = data
          .map((item) => ExpenseModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      _expenseList.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading expenses: $e');
    }
  }
  
  Future<void> loadBudget() async {
    try {
      final data = await HiveService.getData('settingsBox', 'monthlyBudget');
      if (data != null) {
        _monthlyBudget = (data as num).toDouble();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading budget: $e');
    }
  }
  
  Future<void> updateBudget(double budget) async {
    try {
      await HiveService.saveData('settingsBox', 'monthlyBudget', budget);
      _monthlyBudget = budget;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating budget: $e');
    }
  }
  
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await HiveService.saveData('expenseBox', expense.id, expense.toJson());
      _expenseList.add(expense);
      _expenseList.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }
  
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await HiveService.saveData('expenseBox', expense.id, expense.toJson());
      final index = _expenseList.indexWhere((item) => item.id == expense.id);
      if (index != -1) {
        _expenseList[index] = expense;
        _expenseList.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }
  
  Future<void> markAsSettled(String id) async {
    try {
      final index = _expenseList.indexWhere((item) => item.id == id);
      if (index != -1) {
        final updated = _expenseList[index].copyWith(status: 'settled');
        await updateExpense(updated);
      }
    } catch (e) {
      debugPrint('Error marking as settled: $e');
    }
  }
  
  Future<void> deleteExpense(String id) async {
    try {
      await HiveService.deleteData('expenseBox', id);
      _expenseList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
    }
  }
  
  ExpenseModel? getExpenseById(String id) {
    try {
      return _expenseList.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}