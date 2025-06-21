import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  String _filter = 'all'; // 'all', 'active', 'completed'

  List<Todo> get todos => _todos;
  String get filter => _filter;

  List<Todo> get filteredTodos {
    switch (_filter) {
      case 'active':
        return _todos.where((todo) => !todo.isCompleted).toList();
      case 'completed':
        return _todos.where((todo) => todo.isCompleted).toList();
      default:
        return _todos;
    }
  }

  int get activeTodosCount => _todos.where((todo) => !todo.isCompleted).length;
  int get completedTodosCount => _todos.where((todo) => todo.isCompleted).length;

  TodoProvider() {
    _loadTodos();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void addTodo(String title, String description) {
    final todo = Todo(
      title: title,
      description: description,
    );
    _todos.add(todo);
    _saveTodos();
    notifyListeners();
  }

  void toggleTodo(String id) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(
        isCompleted: !_todos[todoIndex].isCompleted,
        completedAt: !_todos[todoIndex].isCompleted ? DateTime.now() : null,
      );
      _saveTodos();
      notifyListeners();
    }
  }

  void updateTodo(String id, String title, String description) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(
        title: title,
        description: description,
      );
      _saveTodos();
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    _saveTodos();
    notifyListeners();
  }

  void clearCompleted() {
    _todos.removeWhere((todo) => todo.isCompleted);
    _saveTodos();
    notifyListeners();
  }

  Future<void> _loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getStringList('todos') ?? [];
      _todos = todosJson
          .map((todoJson) => Todo.fromJson(json.decode(todoJson)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading todos: $e');
    }
  }

  Future<void> _saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = _todos
          .map((todo) => json.encode(todo.toJson()))
          .toList();
      await prefs.setStringList('todos', todosJson);
    } catch (e) {
        debugPrint('Error saving todos: $e');
    }
  }
} 