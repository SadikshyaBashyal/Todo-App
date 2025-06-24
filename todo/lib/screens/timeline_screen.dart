import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import 'daily_routine_screen.dart';
import '../models/event.dart';

class Routine {
  String title;
  IconData icon;
  Color color;
  String time;
  String duration;
  bool completed;

  Routine({
    required this.title,
    required this.icon,
    required this.color,
    required this.time,
    required this.duration,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'icon': icon.codePoint,
    'color': color.toARGB32(),
    'time': time,
    'duration': duration,
    'completed': completed,
  };

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
    title: json['title'],
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    color: Color(json['color']),
    time: json['time'],
    duration: json['duration'],
    completed: json['completed'] ?? false,
  );
}

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Routine> _routines = [];
  List<dynamic> _todos = [];
  List<dynamic> _events = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('currentUser');
    if (username == null) return;
    // Load routines
    final routinesJson = prefs.getStringList('routines_$username');
    if (routinesJson != null) {
      setState(() {
        _routines = routinesJson.map((json) => Routine.fromJson(jsonDecode(json))).toList();
      });
    }
    // Load todos
    final todosJson = prefs.getStringList('todos_$username');
    if (todosJson != null) {
      setState(() {
        _todos = todosJson.map((json) => jsonDecode(json)).toList();
      });
    }
    // Load events
    final eventsJson = prefs.getStringList('events_$username');
    if (eventsJson != null) {
      setState(() {
        _events = eventsJson.map((json) => jsonDecode(json)).toList();
      });
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter todos for selected date
    final todos = _todos.where((todo) {
      final createdAt = DateTime.parse(todo['createdAt']);
      final dueDate = todo['dueDate'] != null ? DateTime.parse(todo['dueDate']) : createdAt;
      return dueDate.year == _selectedDate.year && dueDate.month == _selectedDate.month && dueDate.day == _selectedDate.day;
    }).toList();
    // Filter events for selected date using recurrence
    final events = _events.map((event) {
      try {
        return CalendarEvent.fromJson(event);
      } catch (_) {
        return null;
      }
    }).where((event) => event != null && event.isDueOn(_selectedDate)).cast<CalendarEvent>().toList();
    final routines = _routines;

    // Build a combined timeline list
    final timelineEntries = <_TimelineEntry>[];
    for (final todo in todos) {
      timelineEntries.add(_TimelineEntry(
        time: todo['dueDate'] != null ? DateTime.parse(todo['dueDate']) : DateTime.parse(todo['createdAt']),
        type: 'Todo',
        title: todo['title'],
        icon: Icons.check_box,
        color: Colors.orange,
        isCompleted: todo['isCompleted'] ?? false,
      ));
    }
    for (final event in events) {
      final eventTime = event.time != null
        ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, event.time!.hour, event.time!.minute)
        : DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
      timelineEntries.add(_TimelineEntry(
        time: eventTime,
        type: 'Event',
        title: event.title,
        icon: event.icon,
        color: event.color,
        isCompleted: event.isCompleted,
      ));
    }
    for (final routine in routines) {
      timelineEntries.add(_TimelineEntry(
        time: _parseRoutineTime(_selectedDate, routine.time),
        type: 'Routine',
        title: routine.title,
        icon: routine.icon,
        color: routine.color,
        isCompleted: routine.completed,
      ));
    }
    // Sort by time
    timelineEntries.sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Timeline'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 23, 199, 52),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 30),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today, color: Color.fromARGB(255, 7, 142, 11), size: 30),
                            // style: IconButton.styleFrom(
                            //   backgroundColor: Colors.green[400],
                            //   foregroundColor: Colors.white,
                            // ),
                            onPressed: _pickDate,
                          ),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 7, 11, 142)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 30),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          Expanded(
            child: timelineEntries.isEmpty
                ? Center(
                    child: Text(
                      'No timeline entries for this day.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    itemCount: timelineEntries.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final entry = timelineEntries[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: entry.color,
                          child: Icon(entry.icon, color: Colors.white),
                        ),
                        title: Text(
                          entry.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: entry.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text('${entry.type} • ${DateFormat('HH:mm').format(entry.time)}'),
                        trailing: entry.isCompleted
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry {
  final DateTime time;
  final String type;
  final String title;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  _TimelineEntry({
    required this.time,
    required this.type,
    required this.title,
    required this.icon,
    required this.color,
    required this.isCompleted,
  });
}

DateTime _parseRoutineTime(DateTime date, String timeStr) {
  try {
    final t = DateFormat.Hm().parse(timeStr);
    return DateTime(date.year, date.month, date.day, t.hour, t.minute);
  } catch (_) {
    try {
      final t = DateFormat.jm().parse(timeStr);
      return DateTime(date.year, date.month, date.day, t.hour, t.minute);
    } catch (_) {
      return DateTime(date.year, date.month, date.day, 0, 0);
    }
  }
} 