import 'package:flutter/material.dart';
import 'package:life_hub/data/models/todo_model.dart';
import 'package:life_hub/data/local/hive_service.dart';
import 'package:life_hub/data/local/notification_service.dart';

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
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) =>
        task.content.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Filter by priority
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
    }
  }
  
  Future<void> addTodo(TodoModel todo, {bool enableNotifications = true}) async {
    try {
      
      // Save to Hive
      await HiveService.saveData('todoBox', todo.id, todo.toJson());
      _todoList.add(todo);
      _todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Schedule notification if conditions are met
      if (enableNotifications && todo.endTime != null) {
        
        final now = DateTime.now();
        final notificationTime = todo.endTime!.subtract(const Duration(minutes: 1));
        
        
        if (notificationTime.isAfter(now)) {
          try {
            await NotificationService.scheduleTaskNotification(
              id: todo.id,
              title: 'Task Due Soon',
              content: todo.content,
              scheduledTime: todo.endTime!,
            );
            
            // Verify it was scheduled
            final pending = await NotificationService.getPendingNotifications();
            print('   Total pending notifications: ${pending.length}');
          } catch (e) {
            print('   Failed to schedule notification: $e');
          }
        } else {
          print('   Notification time is in the past, skipping');
        }
      } else {
        if (!enableNotifications) {
          print('    Notifications disabled in settings');
        }
        
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateTodo(TodoModel todo, {bool enableNotifications = true}) async {
    try {
      
      await HiveService.saveData('todoBox', todo.id, todo.toJson());
      final index = _todoList.indexWhere((item) => item.id == todo.id);
      if (index != -1) {
        _todoList[index] = todo;
        
        await NotificationService.cancelNotification(todo.id);
        
        // Schedule new notification if conditions are met
        if (enableNotifications && todo.endTime != null && todo.isPending) {
        
          
          final now = DateTime.now();
          final notificationTime = todo.endTime!.subtract(const Duration(minutes: 1));
          
          if (notificationTime.isAfter(now)) {
            try {
              await NotificationService.scheduleTaskNotification(
                id: todo.id,
                title: 'Task Due Soon',
                content: todo.content,
                scheduledTime: todo.endTime!,
              );
            } catch (e) {
              print('   Failed to schedule updated notification: $e');
            }
          } else {
            print('    Notification time is in the past');
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
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
    }
  }
  
  Future<void> markAsPending(String id) async {
    try {
      final index = _todoList.indexWhere((item) => item.id == id);
      if (index != -1) {
        final updatedTodo = _todoList[index].copyWith(status: 'pending');
        
        // Check if notifications are enabled
        final notificationsEnabled = await HiveService.getData('settingsBox', 'notifications') ?? true;
        
        await updateTodo(updatedTodo, enableNotifications: notificationsEnabled);
      }
    } catch (e) {
    }
  }
  
  Future<void> deleteTodo(String id) async {
    try {
      await HiveService.deleteData('todoBox', id);
      await NotificationService.cancelNotification(id);
      _todoList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
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