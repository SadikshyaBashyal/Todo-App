import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  // NEW: Helper function to determine the layout type
  bool get _isMobileLayout {
    // This logic mirrors the crossAxisCount check in the grid
    if (kIsWeb || (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return false; // Desktop/Web layout
    }
    return true; // Mobile layout (Android/iOS)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar( ... ),
      body: Column(
        children: [
          // Calendar Header
          _buildCalendarHeader(),

          // NEW: Days of the week header, only for mobile layout
          if (_isMobileLayout) _buildDaysOfWeekHeaderMobile(),
          if (!_isMobileLayout) _buildDaysOfWeekHeaderDesktop(),

          // Calendar Grid
          Expanded(
            child: _buildCalendarGrid(),
          ),

          // Events for Selected Day
          _buildSelectedDayEvents(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    // ... (no changes in this method)
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[400],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 30),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 30),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeekHeaderDesktop() {
    // Using the abbreviations you requested
    final daysOfWeek = ['M', 'T', 'W', 'Th', 'F', 'St', 'S', 'M', 'T', 'W', 'Th', 'F', 'St', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: daysOfWeek
            .map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (day == 'St' || day == 'S') ? Colors.red : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
  
  // NEW: Widget to build the days of the week header (e.g., M, T, W...)
  Widget _buildDaysOfWeekHeaderMobile() {
    // Using the abbreviations you requested
    final daysOfWeek = ['M', 'T', 'W', 'Th', 'F', 'St', 'S'];

    return Padding(
      // Padding to align with the calendar grid's horizontal padding
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        // Use map to create a Text widget for each day and Expanded to space them evenly
        children: daysOfWeek
            .map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (day == 'St' || day == 'S') ? Colors.red : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    
    // In Dart, weekday is 1 for Monday and 7 for Sunday.
    final firstWeekday = firstDayOfMonth.weekday;

    // Determine cross axis count based on platform
    // MODIFIED: Used the new getter `_isMobileLayout` for consistency
    int crossAxisCount = _isMobileLayout ? 7 : 14;

    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      // The grid needs to be large enough for 6 weeks to handle all month layouts
      itemCount: _isMobileLayout ? 42 : 56, // 6*7 for mobile, 4*14 for web/desktop
      itemBuilder: (context, index) {
        // This logic correctly places the first day based on a Monday start
        final dayOffset = index - (firstWeekday - 1);
        final day = dayOffset + 1;

        if (dayOffset < 0 || day > daysInMonth) {
          return Container(); // Empty space for days outside the current month
        }

        final date = DateTime(_focusedDay.year, _focusedDay.month, day);
        final isSelected = date.year == _selectedDay.year &&
            date.month == _selectedDay.month &&
            date.day == _selectedDay.day;
        final isToday = date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = date;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 30, 229, 63)
                  : isToday
                      ? Colors.blue[100]
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isToday ? Colors.blue[300]! : Colors.grey[300]!,
                width: isToday ? 1.5 : 0.5,
              ),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? Colors.blue[700]
                          : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayEvents() {
    // ... (no changes in this method)
    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, MMMM d').format(_selectedDay),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _showAddEventDialog(context);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 4),
                    Text('Add Event'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _getEventsForDay(_selectedDay).isEmpty
                ? const Center(
                    child: Text(
                      'No events for this day',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _getEventsForDay(_selectedDay).length,
                    itemBuilder: (context, index) {
                      final event = _getEventsForDay(_selectedDay)[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: event['color'] as Color,
                            child: Icon(
                              event['icon'] as IconData,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          title: Text(event['title'] as String),
                          subtitle: Text(event['time'] as String),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Delete event
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSelectedDayEventsDesktop() {
  //   return Container(
  //     height: 200,
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[200],
  //       border: Border(
  //         top: BorderSide(color: Colors.grey[300]!),
  //   return Container(); 
  // }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // ... (no changes in this method)
    if (day.day == DateTime.now().day && day.month == DateTime.now().month) {
      return [
        {
          'title': 'Team Meeting',
          'time': '10:00 AM',
          'color': Colors.blue,
          'icon': Icons.meeting_room,
        },
        {
          'title': 'Lunch Break',
          'time': '12:30 PM',
          'color': Colors.orange,
          'icon': Icons.restaurant,
        },
      ];
    }
    return [];
  }

  void _showAddEventDialog(BuildContext context) {
    // ... (no changes in this method)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add, color: Colors.blue),
            SizedBox(width: 8),
            Text('Add Event'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add event logic
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}