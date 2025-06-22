import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  List<String> _availableTags = ['daily', 'work', 'personal'];
  String _filter = 'all'; // all, today, week, completed
  String? _selectedTag;
  Priority? _selectedPriority;

  List<Todo> get todos => _todos;
  List<String> get availableTags => _availableTags;
  String get filter => _filter;
  String? get selectedTag => _selectedTag;
  Priority? get selectedPriority => _selectedPriority;

  List<Todo> get filteredTodos {
    List<Todo> filtered = _todos;

    // Apply filter
    switch (_filter) {
      case 'today':
        filtered = filtered.where((todo) => todo.isDueToday).toList();
        break;
      case 'week':
        filtered = filtered.where((todo) => todo.isDueThisWeek).toList();
        break;
      case 'completed':
        filtered = filtered.where((todo) => todo.isCompleted).toList();
        break;
      case 'overdue':
        filtered = filtered.where((todo) => todo.isOverdue).toList();
        break;
      case 'recurring':
        filtered = filtered.where((todo) => todo.isRecurring).toList();
        break;
    }

    // Apply tag filter
    if (_selectedTag != null) {
      filtered = filtered.where((todo) => todo.tags.contains(_selectedTag)).toList();
    }

    // Apply priority filter
    if (_selectedPriority != null) {
      filtered = filtered.where((todo) => todo.priority == _selectedPriority).toList();
    }

    return filtered;
  }

  List<Todo> get todayTodos => _todos.where((todo) => todo.isDueToday).toList();
  List<Todo> get overdueTodos => _todos.where((todo) => todo.isOverdue).toList();
  List<Todo> get recurringTodos => _todos.where((todo) => todo.isRecurring).toList();

  TodoProvider() {
    _loadTodos();
    _loadTags();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getStringList('todos') ?? [];
    _todos = todosJson.map((json) => Todo.fromJson(jsonDecode(json))).toList();
    notifyListeners();
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = _todos.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setStringList('todos', todosJson);
  }

  Future<void> _loadTags() async {
    final prefs = await SharedPreferences.getInstance();
    _availableTags = prefs.getStringList('tags') ?? ['daily', 'work', 'personal'];
    notifyListeners();
  }

  Future<void> _saveTags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tags', _availableTags);
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setTagFilter(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  void setPriorityFilter(Priority? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void clearFilters() {
    _filter = 'all';
    _selectedTag = null;
    _selectedPriority = null;
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
    
    // Add new tags to available tags
    for (String tag in todo.tags) {
      if (!_availableTags.contains(tag)) {
        _availableTags.add(tag);
      }
    }
    
    await _saveTodos();
    await _saveTags();
    notifyListeners();
  }

  Future<void> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      
      // Add new tags to available tags
      for (String tag in todo.tags) {
        if (!_availableTags.contains(tag)) {
          _availableTags.add(tag);
        }
      }
      
      await _saveTodos();
      await _saveTags();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    await _saveTodos();
    notifyListeners();
  }

  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      _todos[index].completedAt = _todos[index].isCompleted ? DateTime.now() : null;
      await _saveTodos();
      notifyListeners();
    }
  }

  Future<void> addTag(String tag) async {
    if (!_availableTags.contains(tag)) {
      _availableTags.add(tag);
      await _saveTags();
      notifyListeners();
    }
  }

  Future<void> removeTag(String tag) async {
    if (_availableTags.contains(tag)) {
      _availableTags.remove(tag);
      // Remove tag from all todos
      for (var todo in _todos) {
        todo.tags.remove(tag);
      }
      await _saveTags();
      await _saveTodos();
      notifyListeners();
    }
  }

  List<Todo> getTodosForDate(DateTime date) {
    return _todos.where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.year == date.year &&
             todo.dueDate!.month == date.month &&
             todo.dueDate!.day == date.day;
    }).toList();
  }

  List<Todo> getRecurringTodosForDate(DateTime date) {
    return _todos.where((todo) {
      if (!todo.isRecurring || todo.recurringType == null) return false;
      
      switch (todo.recurringType!) {
        case RecurringType.todayOnly:
          return todo.isDueToday;
        case RecurringType.weekdays:
          return date.weekday >= 1 && date.weekday <= 5;
        case RecurringType.allDays:
          return true;
        case RecurringType.custom:
          return todo.customDays?.contains(date.weekday) ?? false;
      }
    }).toList();
  }
}