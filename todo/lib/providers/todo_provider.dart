import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../services/notification_service.dart';
//  import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';


class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  List<String> _availableTags = ['daily', 'work', 'personal'];
  String _filter = 'all'; // all, today, week, completed
  String? _selectedTag;
  Priority? _selectedPriority;

  // Multi-account support
  String? _currentUsername;
  List<AppUser> _users = [];

  // Calendar events support
  List<CalendarEvent> _events = [];

  // Notification service
  final NotificationService _notificationService = NotificationService();

  // For Firebase (commented out)
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Todo> get todos => _todos;
  List<String> get availableTags => _availableTags;
  String get filter => _filter;
  String? get selectedTag => _selectedTag;
  Priority? get selectedPriority => _selectedPriority;
  String? get currentUsername => _currentUsername;
  List<AppUser> get users => _users;
  List<CalendarEvent> get events => _events;

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
    _loadUsers();
    _loadCurrentUser();
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    await _notificationService.initialize();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('users') ?? [];
    _users = usersJson.map((json) => AppUser.fromJson(jsonDecode(json))).toList();
    notifyListeners();
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = _users.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList('users', usersJson);
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUsername = prefs.getString('currentUser');
    if (_currentUsername != null) {
      await _loadTodos();
      await _loadTags();
      await _loadEvents();
    }
    notifyListeners();
  }

  Future<void> setCurrentUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _currentUsername = username;
    await prefs.setString('currentUser', username);
    await _loadTodos();
    await _loadTags();
    await _loadEvents();
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUsername = null;
    _todos = [];
    _availableTags = ['daily', 'work', 'personal'];
    _events = [];
    await prefs.remove('currentUser');
    notifyListeners();
  }

  Future<void> addUser(AppUser user) async {
    _users.add(user);
    await _saveUsers();
    notifyListeners();
  }

  Future<void> refreshUsers() async {
    await _loadUsers();
  }

  // LOCAL: Store todos as a map from username to list of todos
  Future<void> _loadTodos() async {
    if (_currentUsername == null) return;
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getStringList('todos_${_currentUsername!}') ?? [];
    _todos = todosJson.map((json) => Todo.fromJson(jsonDecode(json))).toList();
    notifyListeners();
  }

  Future<void> _saveTodos() async {
    if (_currentUsername == null) return;
    final prefs = await SharedPreferences.getInstance();
    final todosJson = _todos.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setStringList('todos_${_currentUsername!}', todosJson);
  }

  // LOCAL: Store tags per user
  Future<void> _loadTags() async {
    if (_currentUsername == null) return;
    final prefs = await SharedPreferences.getInstance();
    _availableTags = prefs.getStringList('tags_${_currentUsername!}') ?? ['daily', 'work', 'personal'];
    notifyListeners();
  }

  Future<void> _saveTags() async {
    if (_currentUsername == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tags_${_currentUsername!}', _availableTags);
  }

  // LOCAL: Store events per user
  Future<void> _loadEvents() async {
    if (_currentUsername == null) return;
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getStringList('events_${_currentUsername!}') ?? [];
    _events = eventsJson.map((json) => CalendarEvent.fromJson(jsonDecode(json))).toList();
    notifyListeners();
  }

  Future<void> _saveEvents() async {
    if (_currentUsername == null) return;
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = _events.map((event) => jsonEncode(event.toJson())).toList();
    await prefs.setStringList('events_${_currentUsername!}', eventsJson);
  }

  // Event management methods
  Future<void> addEvent(CalendarEvent event) async {
    _events.add(event);
    await _saveEvents();
    
    // Schedule notifications for the new event
    await _notificationService.scheduleEventNotifications(event);
    
    notifyListeners();
  }

  Future<void> updateEvent(CalendarEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      // Cancel existing notifications for this event
      await _notificationService.cancelEventNotifications(event.id);
      
      _events[index] = event;
      await _saveEvents();
      
      // Schedule new notifications for the updated event
      await _notificationService.scheduleEventNotifications(event);
      
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    // Cancel notifications for this event
    await _notificationService.cancelEventNotifications(eventId);
    
    _events.removeWhere((event) => event.id == eventId);
    await _saveEvents();
    notifyListeners();
  }

  Future<void> toggleEventCompletion(String eventId) async {
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      final event = _events[index];
      final updatedEvent = event.copyWith(
        isCompleted: !event.isCompleted,
        completedAt: !event.isCompleted ? DateTime.now() : null,
      );
      _events[index] = updatedEvent;
      await _saveEvents();
      notifyListeners();
    }
  }

  List<CalendarEvent> getEventsForDay(DateTime date) {
    return _events.where((event) =>
      event.isDueOn(date) ||
      (event.isCompleted && event.isDueOn(date, ignoreCompleted: true))
    ).toList();
  }

  // bool _isSameDay(DateTime a, DateTime b) =>
  //     a.year == b.year && a.month == b.month && a.day == b.day;

  bool hasEventsOnDay(DateTime date) {
    return _events.any((event) => event.isDueOn(date));
  }

  List<CalendarEvent> getCompletedEvents() {
    return _events.where((event) => event.isCompleted).toList();
  }

  List<CalendarEvent> getPendingEvents() {
    return _events.where((event) => !event.isCompleted).toList();
  }

  // --- Firebase logic (commented out) ---
  // Future<void> loadTodosFromFirebase() async {
  //   final user = _auth.currentUser;
  //   if (user == null) return;
  //   final snapshot = await _firestore.collection('todos').doc(user.uid).get();
  //   if (snapshot.exists) {
  //     final todosData = snapshot.data()?['todos'] as List<dynamic>;
  //     _todos = todosData.map((json) => Todo.fromJson(json)).toList();
  //     notifyListeners();
  //   }
  // }
  //
  // Future<void> saveTodosToFirebase() async {
  //   final user = _auth.currentUser;
  //   if (user == null) return;
  //   await _firestore.collection('todos').doc(user.uid).set({
  //     'todos': _todos.map((todo) => todo.toJson()).toList(),
  //   });
  // }

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
    
    // Schedule notifications for the new todo
    await _notificationService.scheduleTaskNotifications(todo);
    
    notifyListeners();
  }

  Future<void> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      // Cancel existing notifications for this todo
      await _notificationService.cancelTaskNotifications(todo.id);
      
      _todos[index] = todo;
      
      // Add new tags to available tags
      for (String tag in todo.tags) {
        if (!_availableTags.contains(tag)) {
          _availableTags.add(tag);
        }
      }
      
      await _saveTodos();
      await _saveTags();
      
      // Schedule new notifications for the updated todo
      await _notificationService.scheduleTaskNotifications(todo);
      
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    // Cancel notifications for this todo
    await _notificationService.cancelTaskNotifications(id);
    
    _todos.removeWhere((todo) => todo.id == id);
    await _saveTodos();
    notifyListeners();
  }

  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      _todos[index].completedAt = _todos[index].isCompleted ? DateTime.now() : null;
      
      // If todo is completed, cancel its notifications
      if (_todos[index].isCompleted) {
        await _notificationService.cancelTaskNotifications(id);
      } else {
        // If todo is uncompleted, reschedule its notifications
        await _notificationService.scheduleTaskNotifications(_todos[index]);
      }
      
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

  Future<void> deleteAllCompletedTodos() async {
    _todos.removeWhere((todo) => todo.isCompleted);
    await _saveTodos();
    notifyListeners();
  }

  Future<void> deleteAllCompletedEventsForDay(DateTime date) async {
    _events.removeWhere((event) =>
      event.isCompleted &&
      (
        // For non-recurring, match the original date
        (event.recurringType == EventRecurringType.none && event.date.year == date.year && event.date.month == date.month && event.date.day == date.day)
        // For recurring, match if the event would have appeared on this day
        || (event.recurringType != EventRecurringType.none && event.isDueOn(date, ignoreCompleted: true))
      )
    );
    await _saveEvents();
    notifyListeners();
  }

  // Method to reschedule all notifications (useful when app starts or settings change)
  Future<void> rescheduleAllNotifications() async {
    await _notificationService.scheduleAllNotifications(_events, _todos);
  }

  Future<void> updateUserPhoto(String photoPath) async {
    if (_currentUsername == null) return;
    final index = _users.indexWhere((u) => u.username == _currentUsername);
    if (index != -1) {
      final user = _users[index];
      _users[index] = AppUser(
        username: user.username,
        password: user.password,
        name: user.name,
        photoPath: photoPath,
      );
      await _saveUsers();
      notifyListeners();
    }
  }

  Future<String?> updateUsername(String newUsername) async {
    if (_currentUsername == null) return 'No user logged in';
    if (_users.any((u) => u.username == newUsername)) {
      return 'Username already exists';
    }
    final index = _users.indexWhere((u) => u.username == _currentUsername);
    if (index != -1) {
      final user = _users[index];
      _users[index] = AppUser(
        username: newUsername,
        password: user.password,
        name: user.name,
        photoPath: user.photoPath,
      );
      _currentUsername = newUsername;
      await _saveUsers();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', newUsername);
      notifyListeners();
      return null;
    }
    return 'User not found';
  }

  Future<void> updatePassword(String newPassword) async {
    if (_currentUsername == null) return;
    final index = _users.indexWhere((u) => u.username == _currentUsername);
    if (index != -1) {
      final user = _users[index];
      _users[index] = AppUser(
        username: user.username,
        password: newPassword,
        name: user.name,
        photoPath: user.photoPath,
      );
      await _saveUsers();
      notifyListeners();
    }
  }
} 