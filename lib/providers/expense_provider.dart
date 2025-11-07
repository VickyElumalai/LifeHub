import 'package:flutter/material.dart';
import 'package:life_hub/data/models/expense_model.dart';
import 'package:life_hub/data/local/hive_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenseList = [];
  double _monthlyBudget = 3000.0;
  
  List<ExpenseModel> get expenseList => _expenseList;
  double get monthlyBudget => _monthlyBudget;
  
  double get totalSpent {
    return _expenseList.fold(0.0, (sum, expense) => sum + expense.amount);
  }
  
  double get remainingBudget => _monthlyBudget - totalSpent;
  
  double get budgetPercentage {
    if (_monthlyBudget == 0) return 0;
    return (totalSpent / _monthlyBudget) * 100;
  }
  
  Map<String, double> get expensesByCategory {
    final Map<String, double> categoryTotals = {};
    for (var expense in _expenseList) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }
  
  List<ExpenseModel> get recentExpenses => _expenseList
      .take(10)
      .toList();
  
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
      print('Error loading expense data: $e');
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
      print('Error loading budget: $e');
    }
  }
  
  Future<void> updateBudget(double budget) async {
    try {
      await HiveService.saveData('settingsBox', 'monthlyBudget', budget);
      _monthlyBudget = budget;
      notifyListeners();
    } catch (e) {
      print('Error updating budget: $e');
    }
  }
  
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await HiveService.saveData('expenseBox', expense.id, expense.toJson());
      _expenseList.add(expense);
      _expenseList.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      print('Error adding expense: $e');
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
      print('Error updating expense: $e');
    }
  }
  
  Future<void> deleteExpense(String id) async {
    try {
      await HiveService.deleteData('expenseBox', id);
      _expenseList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting expense: $e');
    }
  }
}