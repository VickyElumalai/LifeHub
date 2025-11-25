import 'package:flutter/material.dart';
import 'package:life_hub/data/models/todo_model.dart';
import 'package:life_hub/data/service/hive_service.dart';
import 'package:life_hub/data/service/notification_service.dart';

class TodoProvider extends ChangeNotifier {
  List<TodoModel> _todoList = [];
  String _searchQuery = '';
  String _filterPriority = 'all';
  
  List<TodoModel> get todoList => _todoList;
  String get searchQuery => _searchQuery;
  String get filterPriority => _filterPriority;
  
  int get totalTasks => _getFilteredList(_todoList
      .where((task) => task.isPending)
      .toList()).length;
  
  int get completedTasks => _todoList.where((task) => task.isCompleted).length;
  int get skippedTasks => _todoList.where((task) => task.isSkipped).length;
  
  double get completionPercentage {
    final total = totalTasks + completedTasks;
    if (total == 0) return 0;
    return (completedTasks / total) * 100;
  }
  
  List<TodoModel> get pendingTodos => _getFilteredList(
    _todoList.where((task) => task.isPending).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
  );
  
  List<TodoModel> get completedTodos => _getFilteredList(
    _todoList.where((task) => task.isCompleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
  );
      
  List<TodoModel> get skippedTodos => _getFilteredList(
    _todoList.where((task) => task.isSkipped).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
  );
  
  TodoProvider() {
    loadTodoData();
  }
  
  List<TodoModel> _getFilteredList(List<TodoModel> list) {
    var filtered = list;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) =>
        task.content.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    if (_filterPriority != 'all') {
      filtered = filtered.where((task) =>
        task.priority == _filterPriority
      ).toList();
    }
    
    return filtered;
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void setFilterPriority(String priority) {
    _filterPriority = priority;
    notifyListeners();
  }
  
  void clearFilters() {
    _searchQuery = '';
    _filterPriority = 'all';
    notifyListeners();
  }
  
  Future<void> loadTodoData() async {
    try {
      final data = await HiveService.getAllData('todoBox');
      _todoList = data
          .map((item) => TodoModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      _todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading todos: $e');
    }
  }
  
  Future<void> addTodo(TodoModel todo, {bool enableNotifications = true}) async {
    try {
      await HiveService.saveData('todoBox', todo.id, todo.toJson());
      _todoList.add(todo);
      _todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Schedule notifications if enabled and has due time
      if (enableNotifications && todo.endTime != null) {
        await _scheduleTodoReminders(todo);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding todo: $e');
      rethrow;
    }
  }

  Future<void> updateTodo(TodoModel todo, {bool enableNotifications = true}) async {
    try {
      await HiveService.saveData('todoBox', todo.id, todo.toJson());
      final index = _todoList.indexWhere((item) => item.id == todo.id);
      if (index != -1) {
        _todoList[index] = todo;
        
        // Cancel old notifications and schedule new ones
        await _cancelTodoReminders(todo.id);
        if (enableNotifications && todo.endTime != null && todo.isPending) {
          await _scheduleTodoReminders(todo);
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating todo: $e');
      rethrow;
    }
  }

  // NEW: Schedule all reminder notifications for a todo
  Future<void> _scheduleTodoReminders(TodoModel todo) async {
    if (todo.endTime == null) return;

    // If no custom reminders, use default 1 minute before
    final reminders = todo.reminderMinutes.isEmpty ? ['1'] : todo.reminderMinutes;

    for (int remIdx = 0; remIdx < reminders.length; remIdx++) {
      final minutes = int.tryParse(reminders[remIdx]) ?? 0;
      if (minutes <= 0) continue;

      final fireAt = todo.endTime!.subtract(Duration(minutes: minutes));
      if (!fireAt.isAfter(DateTime.now())) continue;

      final reminderId = '${todo.id}_rem$remIdx';
      final reminderText = _formatReminderText(minutes);

      await NotificationService.scheduleReminder(
        reminderId: reminderId,
        title: todo.content,
        body: reminderText,
        fireAt: fireAt,
      );
    }
  }

  String _formatReminderText(int minutes) {
    if (minutes < 60) return '$minutes minute${minutes > 1 ? 's' : ''} before';
    if (minutes < 1440) {
      final h = minutes ~/ 60;
      return '$h hour${h > 1 ? 's' : ''} before';
    }
    final d = minutes ~/ 1440;
    return '$d day${d > 1 ? 's' : ''} before';
  }

  // NEW: Cancel all reminders for a todo
  Future<void> _cancelTodoReminders(String todoId) async {
    final todo = getTodoById(todoId);
    if (todo != null) {
      final reminders = todo.reminderMinutes.isEmpty ? ['1'] : todo.reminderMinutes;
      for (int remIdx = 0; remIdx < reminders.length; remIdx++) {
        final reminderId = '${todo.id}_rem$remIdx';
        await NotificationService.cancelNotification(reminderId);
      }
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await HiveService.deleteData('todoBox', id);
      await _cancelTodoReminders(id); // Updated
      _todoList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }
  
  Future<void> markAsCompleted(String id) async {
    try {
      final index = _todoList.indexWhere((item) => item.id == id);
      if (index != -1) {
        final updatedTodo = _todoList[index].copyWith(status: 'completed');
        await updateTodo(updatedTodo, enableNotifications: false);
        await NotificationService.cancelNotification(id);
      }
    } catch (e) {
      debugPrint('Error marking as completed: $e');
    }
  }
  
  Future<void> markAsSkipped(String id) async {
    try {
      final index = _todoList.indexWhere((item) => item.id == id);
      if (index != -1) {
        final updatedTodo = _todoList[index].copyWith(status: 'skipped');
        await updateTodo(updatedTodo, enableNotifications: false);
        await NotificationService.cancelNotification(id);
      }
    } catch (e) {
      debugPrint('Error marking as skipped: $e');
    }
  }
  
  Future<void> markAsPending(String id) async {
    try {
      final index = _todoList.indexWhere((item) => item.id == id);
      if (index != -1) {
        final updatedTodo = _todoList[index].copyWith(status: 'pending');
        final notificationsEnabled = await HiveService.getData('settingsBox', 'notifications') ?? true;
        await updateTodo(updatedTodo, enableNotifications: notificationsEnabled);
      }
    } catch (e) {
      debugPrint('Error marking as pending: $e');
    }
  } 

  
  TodoModel? getTodoById(String id) {
    try {
      return _todoList.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}