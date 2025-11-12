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
      print('Error loading todo data: $e');
    }
  }
  
  Future<void> addTodo(TodoModel todo, {bool enableNotifications = true}) async {
    try {
      await HiveService.saveData('todoBox', todo.id, todo.toJson());
      _todoList.add(todo);
      _todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Schedule notification if enabled and has end time
      if (enableNotifications && todo.endTime != null) {
        await NotificationService.scheduleTaskNotification(
          id: todo.id,
          title: 'Task Due Soon',
          content: todo.content,
          scheduledTime: todo.endTime!,
        );
      }
      
      notifyListeners();
    } catch (e) {
      print('Error adding todo: $e');
    }
  }
  
  Future<void> updateTodo(TodoModel todo, {bool enableNotifications = true}) async {
    try {
      await HiveService.saveData('todoBox', todo.id, todo.toJson());
      final index = _todoList.indexWhere((item) => item.id == todo.id);
      if (index != -1) {
        _todoList[index] = todo;
        
        // Update notification
        await NotificationService.cancelNotification(todo.id);
        if (enableNotifications && todo.endTime != null && todo.isPending) {
          await NotificationService.scheduleTaskNotification(
            id: todo.id,
            title: 'Task Due Soon',
            content: todo.content,
            scheduledTime: todo.endTime!,
          );
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error updating todo: $e');
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
      print('Error marking todo as completed: $e');
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
      print('Error marking todo as skipped: $e');
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
      print('Error marking todo as pending: $e');
    }
  }
  
  Future<void> deleteTodo(String id) async {
    try {
      await HiveService.deleteData('todoBox', id);
      await NotificationService.cancelNotification(id);
      _todoList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting todo: $e');
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