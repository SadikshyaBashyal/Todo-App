import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../models/todo.dart';
import '../models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin _notifications = fln.FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification settings keys
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _eventNotificationsKey = 'event_notifications_enabled';
  static const String _taskNotificationsKey = 'task_notifications_enabled';
  static const String _dailyReminderKey = 'daily_reminder_enabled';
  static const String _dailyReminderTimeKey = 'daily_reminder_time';

  // Default settings
  bool _notificationsEnabled = true;
  bool _eventNotificationsEnabled = true;
  bool _taskNotificationsEnabled = true;
  bool _dailyReminderEnabled = true;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 21, minute: 0); // 9:00 PM

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get eventNotificationsEnabled => _eventNotificationsEnabled;
  bool get taskNotificationsEnabled => _taskNotificationsEnabled;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  TimeOfDay get dailyReminderTime => _dailyReminderTime;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Load settings
    await _loadSettings();

    // Initialize notifications
    const fln.AndroidInitializationSettings androidSettings = 
        fln.AndroidInitializationSettings('@mipmap/launcher_icon');
    
    const fln.DarwinInitializationSettings iosSettings = 
        fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const fln.InitializationSettings initSettings = fln.InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _isInitialized = true;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    _eventNotificationsEnabled = prefs.getBool(_eventNotificationsKey) ?? true;
    _taskNotificationsEnabled = prefs.getBool(_taskNotificationsKey) ?? true;
    _dailyReminderEnabled = prefs.getBool(_dailyReminderKey) ?? true;
    
    final reminderTimeString = prefs.getString(_dailyReminderTimeKey);
    if (reminderTimeString != null) {
      final parts = reminderTimeString.split(':');
      _dailyReminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, _notificationsEnabled);
    await prefs.setBool(_eventNotificationsKey, _eventNotificationsEnabled);
    await prefs.setBool(_taskNotificationsKey, _taskNotificationsEnabled);
    await prefs.setBool(_dailyReminderKey, _dailyReminderEnabled);
    await prefs.setString(_dailyReminderTimeKey, 
        '${_dailyReminderTime.hour}:${_dailyReminderTime.minute}');
  }

  Future<void> _requestPermissions() async {
    await _notifications.resolvePlatformSpecificImplementation<
        fln.AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    
    await _notifications.resolvePlatformSpecificImplementation<
        fln.IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onNotificationTapped(fln.NotificationResponse response) {
    developer.log('Notification tapped: [32m${response.payload}[0m');
  }

  // Settings methods
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _saveSettings();
    
    if (!enabled) {
      await cancelAllNotifications();
    } else {
      // Reschedule all notifications
      await _rescheduleAllNotifications();
    }
  }

  Future<void> setEventNotificationsEnabled(bool enabled) async {
    _eventNotificationsEnabled = enabled;
    await _saveSettings();
    
    if (!enabled) {
      await _cancelEventNotifications();
    } else {
      await _rescheduleEventNotifications();
    }
  }

  Future<void> setTaskNotificationsEnabled(bool enabled) async {
    _taskNotificationsEnabled = enabled;
    await _saveSettings();
    
    if (!enabled) {
      await _cancelTaskNotifications();
    } else {
      await _rescheduleTaskNotifications();
    }
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    _dailyReminderEnabled = enabled;
    await _saveSettings();
    
    if (!enabled) {
      await _cancelDailyReminder();
    } else {
      await _scheduleDailyReminder();
    }
  }

  Future<void> setDailyReminderTime(TimeOfDay time) async {
    _dailyReminderTime = time;
    await _saveSettings();
    
    if (_dailyReminderEnabled) {
      await _scheduleDailyReminder();
    }
  }

  // Event notification methods
  Future<void> scheduleEventNotifications(CalendarEvent event) async {
    if (!_notificationsEnabled || !_eventNotificationsEnabled) return;

    final eventDateTime = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
      event.time?.hour ?? 9,
      event.time?.minute ?? 0,
    );

    // Schedule notifications for different times
    await _scheduleEventNotification(
      event,
      eventDateTime.subtract(const Duration(days: 1)),
      '${event.title} tomorrow at ${event.timeString}',
      'Don\'t forget about your event tomorrow!',
      'event_day_before_${event.id}',
    );

    await _scheduleEventNotification(
      event,
      eventDateTime.subtract(const Duration(hours: 1)),
      '${event.title} in 1 hour',
      'Your event starts in 1 hour',
      'event_1hour_${event.id}',
    );

    await _scheduleEventNotification(
      event,
      eventDateTime.subtract(const Duration(minutes: 15)),
      '${event.title} in 15 minutes',
      'Your event starts in 15 minutes',
      'event_15min_${event.id}',
    );
  }

  Future<void> _scheduleEventNotification(
    CalendarEvent event,
    DateTime scheduledTime,
    String title,
    String body,
    String id,
  ) async {
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      _generateNotificationId(id),
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'events_channel',
          'Events',
          channelDescription: 'Event notifications',
          importance: fln.Importance.high,
          priority: fln.Priority.high,
          showWhen: true,
        ),
        iOS: fln.DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({
        'type': 'event',
        'eventId': event.id,
        'title': event.title,
      }),
    );
  }

  Future<void> cancelEventNotifications(String eventId) async {
    await _notifications.cancel(_generateNotificationId('event_day_before_$eventId'));
    await _notifications.cancel(_generateNotificationId('event_1hour_$eventId'));
    await _notifications.cancel(_generateNotificationId('event_15min_$eventId'));
  }

  // Task notification methods
  Future<void> scheduleTaskNotifications(Todo task) async {
    if (!_notificationsEnabled || !_taskNotificationsEnabled) return;
    if (task.dueDate == null) return;

    final dueDateTime = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
      task.dueTime?.hour ?? 23,
      task.dueTime?.minute ?? 59,
    );

    // Schedule notifications for different times
    await _scheduleTaskNotification(
      task,
      dueDateTime.subtract(const Duration(days: 1)),
      '${task.title} due tomorrow',
      'Your task is due tomorrow at ${_formatTimeOfDay(task.dueTime)}',
      'task_day_before_${task.id}',
    );

    await _scheduleTaskNotification(
      task,
      dueDateTime.subtract(const Duration(hours: 1)),
      '${task.title} due in 1 hour',
      'Your task is due in 1 hour',
      'task_1hour_${task.id}',
    );
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '11:59 PM';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _scheduleTaskNotification(
    Todo task,
    DateTime scheduledTime,
    String title,
    String body,
    String id,
  ) async {
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      _generateNotificationId(id),
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'tasks_channel',
          'Tasks',
          channelDescription: 'Task notifications',
          importance: fln.Importance.high,
          priority: fln.Priority.high,
          showWhen: true,
        ),
        iOS: fln.DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({
        'type': 'task',
        'taskId': task.id,
        'title': task.title,
      }),
    );
  }

  Future<void> cancelTaskNotifications(String taskId) async {
    await _notifications.cancel(_generateNotificationId('task_day_before_$taskId'));
    await _notifications.cancel(_generateNotificationId('task_1hour_$taskId'));
  }

  // Daily reminder for urgent tasks
  Future<void> _scheduleDailyReminder() async {
    if (!_notificationsEnabled || !_dailyReminderEnabled) return;

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _dailyReminderTime.hour,
      _dailyReminderTime.minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      _generateNotificationId('daily_reminder'),
      'Daily Task Reminder',
      'Check your urgent tasks for today',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily task reminders',
          importance: fln.Importance.defaultImportance,
          priority: fln.Priority.defaultPriority,
          showWhen: true,
        ),
        iOS: fln.DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: fln.DateTimeComponents.time,
      payload: jsonEncode({
        'type': 'daily_reminder',
      }),
    );
  }

  Future<void> _cancelDailyReminder() async {
    await _notifications.cancel(_generateNotificationId('daily_reminder'));
  }

  // Utility methods
  int _generateNotificationId(String id) {
    return id.hashCode;
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> _cancelEventNotifications() async {
    final pendingNotifications = await _notifications.pendingNotificationRequests();
    for (final notification in pendingNotifications) {
      if (notification.payload != null) {
        final payload = jsonDecode(notification.payload!);
        if (payload['type'] == 'event') {
          await _notifications.cancel(notification.id);
        }
      }
    }
  }

  Future<void> _cancelTaskNotifications() async {
    final pendingNotifications = await _notifications.pendingNotificationRequests();
    for (final notification in pendingNotifications) {
      if (notification.payload != null) {
        final payload = jsonDecode(notification.payload!);
        if (payload['type'] == 'task') {
          await _notifications.cancel(notification.id);
        }
      }
    }
  }

  Future<void> _rescheduleAllNotifications() async {
    // This would be called when notifications are re-enabled
    // You would need to pass the current events and tasks to reschedule them
  }

  Future<void> _rescheduleEventNotifications() async {
    // This would be called when event notifications are re-enabled
  }

  Future<void> _rescheduleTaskNotifications() async {
    // This would be called when task notifications are re-enabled
  }

  // Method to schedule notifications for all existing events and tasks
  Future<void> scheduleAllNotifications(List<CalendarEvent> events, List<Todo> tasks) async {
    if (!_notificationsEnabled) return;

    // Schedule event notifications
    if (_eventNotificationsEnabled) {
      for (final event in events) {
        if (!event.isCompleted) {
          await scheduleEventNotifications(event);
        }
      }
    }

    // Schedule task notifications
    if (_taskNotificationsEnabled) {
      for (final task in tasks) {
        if (!task.isCompleted && task.dueDate != null) {
          await scheduleTaskNotifications(task);
        }
      }
    }

    // Schedule daily reminder
    if (_dailyReminderEnabled) {
      await _scheduleDailyReminder();
    }
  }
} 