// import 'dart:convert';
import 'package:flutter/material.dart';

enum EventRecurringType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
  monthlyNthWeekday, // e.g., First Sunday, Second Monday, etc.
}

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay? time;
  final IconData icon;
  final Color color;
  final EventRecurringType recurringType;
  final int? recurringNth; // 1 for first, 2 for second, etc.
  final int? recurringWeekday; // DateTime.sunday, DateTime.monday, etc.
  final bool isCompleted;
  final DateTime? completedAt;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.time,
    required this.icon,
    required this.color,
    this.recurringType = EventRecurringType.none,
    this.recurringNth,
    this.recurringWeekday,
    this.isCompleted = false,
    this.completedAt,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    IconData? icon,
    Color? color,
    EventRecurringType? recurringType,
    int? recurringNth,
    int? recurringWeekday,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      recurringType: recurringType ?? this.recurringType,
      recurringNth: recurringNth ?? this.recurringNth,
      recurringWeekday: recurringWeekday ?? this.recurringWeekday,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'icon': icon.codePoint,
      'color': color.toARGB32(),
      'recurringType': recurringType.index,
      'recurringNth': recurringNth,
      'recurringWeekday': recurringWeekday,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: json['time'] != null 
          ? TimeOfDay(
              hour: int.parse(json['time'].split(':')[0]),
              minute: int.parse(json['time'].split(':')[1]),
            )
          : null,
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      recurringType: EventRecurringType.values[json['recurringType']],
      recurringNth: json['recurringNth'],
      recurringWeekday: json['recurringWeekday'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  bool isDueOn(DateTime date, {bool ignoreCompleted = false}) {
    if (isCompleted && !ignoreCompleted) return false;
    
    switch (recurringType) {
      case EventRecurringType.none:
        return date.year == this.date.year &&
               date.month == this.date.month &&
               date.day == this.date.day;
      case EventRecurringType.daily:
        return true;
      case EventRecurringType.weekly:
        return date.weekday == this.date.weekday;
      case EventRecurringType.monthly:
        return date.day == this.date.day;
      case EventRecurringType.yearly:
        return date.month == this.date.month &&
               date.day == this.date.day;
      case EventRecurringType.monthlyNthWeekday:
        if (recurringNth == null || recurringWeekday == null) return false;
        // Find the Nth weekday of this month
        int count = 0;
        for (int d = 1; d <= DateTime(date.year, date.month + 1, 0).day; d++) {
          final dt = DateTime(date.year, date.month, d);
          if (dt.weekday == recurringWeekday) {
            count++;
            if (count == recurringNth && dt.day == date.day) {
              return true;
            }
          }
        }
        return false;
    }
  }

  String get timeString {
    if (time == null) return 'All day';
    return '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';
  }

  String get recurringString {
    switch (recurringType) {
      case EventRecurringType.none:
        return 'No repeat';
      case EventRecurringType.daily:
        return 'Every day';
      case EventRecurringType.weekly:
        return 'Every week';
      case EventRecurringType.monthly:
        return 'Every month';
      case EventRecurringType.yearly:
        return 'Every year';
      case EventRecurringType.monthlyNthWeekday:
        if (recurringNth != null && recurringWeekday != null) {
          const nthNames = ['First', 'Second', 'Third', 'Fourth', 'Fifth'];
          const weekdayNames = [
            'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
          ];
          final nth = recurringNth!;
          final weekday = recurringWeekday!;
          return '${nthNames[nth - 1]} ${weekdayNames[weekday - 1]} of the month';
        }
        return 'Nth weekday of the month';
    }
  }
} 