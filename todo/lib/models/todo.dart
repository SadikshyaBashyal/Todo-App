import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

enum Priority { urgent, high, medium, low }
enum RecurringType { todayOnly, weekdays, allDays, custom }

class Todo {
  final String id;
  String title;
  String? description;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  Priority priority;
  List<String> tags;
  bool isRecurring;
  RecurringType? recurringType;
  List<int>? customDays; // 1=Monday, 2=Tuesday, etc.
  DateTime? endDate;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;

  Todo({
    String? id,
    required this.title,
    this.description,
    this.dueDate,
    this.dueTime,
    this.priority = Priority.medium,
    List<String>? tags,
    this.isRecurring = false,
    this.recurringType,
    this.customDays,
    this.endDate,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    tags = tags ?? [],
    createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    Priority? priority,
    List<String>? tags,
    bool? isRecurring,
    RecurringType? recurringType,
    List<int>? customDays,
    DateTime? endDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      customDays: customDays ?? this.customDays,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime != null ? '${dueTime!.hour}:${dueTime!.minute}' : null,
      'priority': priority.name,
      'tags': tags,
      'isRecurring': isRecurring,
      'recurringType': recurringType?.name,
      'customDays': customDays,
      'endDate': endDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      dueTime: json['dueTime'] != null 
          ? _parseTimeOfDay(json['dueTime'])
          : null,
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      isRecurring: json['isRecurring'] ?? false,
      recurringType: json['recurringType'] != null 
          ? RecurringType.values.firstWhere(
              (e) => e.name == json['recurringType'],
              orElse: () => RecurringType.todayOnly,
            )
          : null,
      customDays: json['customDays'] != null 
          ? List<int>.from(json['customDays'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String get priorityText {
    switch (priority) {
      case Priority.urgent:
        return 'Urgent';
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case Priority.urgent:
        return Colors.red;
      case Priority.high:
        return Colors.orange;
      case Priority.medium:
        return Colors.blue;
      case Priority.low:
        return Colors.green;
    }
  }

  String get recurringText {
    if (!isRecurring) return 'No';
    switch (recurringType) {
      case RecurringType.todayOnly:
        return 'Today Only';
      case RecurringType.weekdays:
        return 'Weekdays';
      case RecurringType.allDays:
        return 'All Days';
      case RecurringType.custom:
        return 'Custom';
      default:
        return 'No';
    }
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final dueDateTime = DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
      dueTime?.hour ?? 23,
      dueTime?.minute ?? 59,
    );
    return now.isAfter(dueDateTime) && !isCompleted;
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
           dueDate!.month == now.month &&
           dueDate!.day == now.day;
  }

  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return dueDate!.isAfter(weekStart.subtract(const Duration(days: 1))) &&
           dueDate!.isBefore(weekEnd.add(const Duration(days: 1)));
  }
} 