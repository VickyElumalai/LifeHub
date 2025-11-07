import 'package:flutter/material.dart';
import 'package:life_hub/data/models/todo_model.dart';
import 'package:life_hub/data/local/hive_service.dart';

class TodoProvider extends ChangeNotifier {
  List<TodoModel> _todoList = [];
  
  List<TodoModel> get todoList => _todoList;
  
  int get totalTasks => _todoList.length;
  
  int get completedTasks => _todoList
      .where((task) => task.isCompleted)
      .length;
  
  int get remainingTasks => _todoList
      .where((task) => !task.isCompleted)
      .length;
  
  double get completionPercentage {
    if (_todoList.isEmpty) return 0;
    return (completedTasks / totalTasks) * 100;
  }
  
  List<TodoModel> get pendingTodos => _todoList
      .where((task) => !task.isCompleted)
      .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  List<TodoModel> get completedTodos => _todoList
      .where((task) => task.isCompleted)
      .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  TodoProvider() {
    loadTodoData();
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
  
  Future<void> addTodo(TodoModel todo) async {
    try {
      await HiveService.saveData('todoBox', todo.id, todo.toJson());
      _todoList.add(todo);
      _todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    } catch (e) {
      print('Error adding todo: $e');
    }
  }
  
  Future<void> updateTodo(TodoModel todo) async {
    try {
      await HiveService.saveData('todoBox', todo.id, todo.toJson());
      final index = _todoList.indexWhere((item) => item.id == todo.id);
      if (index != -1) {
        _todoList[index] = todo;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating todo: $e');
    }
  }
  
  Future<void> toggleTodoCompletion(String id) async {
    try {
      final index = _todoList.indexWhere((item) => item.id == id);
      if (index != -1) {
        final todo = _todoList[index];
        final updatedTodo = TodoModel(
          id: todo.id,
          title: todo.title,
          isCompleted: !todo.isCompleted,
          category: todo.category,
          priority: todo.priority,
          dueDate: todo.dueDate,
          createdAt: todo.createdAt,
        );
        await updateTodo(updatedTodo);
      }
    } catch (e) {
      print('Error toggling todo: $e');
    }
  }
  
  Future<void> deleteTodo(String id) async {
    try {
      await HiveService.deleteData('todoBox', id);
      _todoList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }
}