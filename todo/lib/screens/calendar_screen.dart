import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month, size: 28),
            SizedBox(width: 8),
            Text('Calendar'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddEventDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Header
          _buildCalendarHeader(),
          
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
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
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
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

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final dayOffset = index - (firstWeekday - 1);
        final day = dayOffset + 1;
        
        if (dayOffset < 0 || day > daysInMonth) {
          return Container(); // Empty space
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
              color: isSelected ? Colors.blue[600] : 
                     isToday ? Colors.blue[100] : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isToday ? Colors.blue[300]! : Colors.grey[300]!,
                width: isToday ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : 
                         isToday ? Colors.blue[700] : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayEvents() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
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
                child: const Text('Add Event'),
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

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // Mock events - in a real app, this would come from a database
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