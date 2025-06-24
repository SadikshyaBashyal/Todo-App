import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/event.dart';
import '../widgets/event_dialog.dart';

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

  // Helper function to determine the layout type
  bool get _isMobileLayout {
    if (kIsWeb || (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return false; // Desktop/Web layout
    }
    return true; // Mobile layout (Android/iOS)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
        child: Column(
          children: [
            // Calendar Header
            _buildCalendarHeader(),

                // Days of the week header
            if (_isMobileLayout) _buildDaysOfWeekHeaderMobile(),
            if (!_isMobileLayout) _buildDaysOfWeekHeaderDesktop(),

                // Calendar Grid
                _buildCalendarGrid(provider),

            // Events for Selected Day
                _buildSelectedDayEvents(provider),
          ],
        ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarHeader() {
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
          // Group calendar button and title
          Row(
            children: [
          IconButton(
            icon: const Icon(Icons.event, size: 30),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
                onPressed: () async {
                  final now = DateTime.now();
                  final selected = await showMonthPicker(
                    context: context,
                    initialDate: _focusedDay,
                    firstDate: DateTime(now.year - 5, 1),
                    lastDate: DateTime(now.year + 5, 12),
                  );
                  if (selected != null) {
                    setState(() {
                      _focusedDay = DateTime(selected.year, selected.month, 1);
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
            ],
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
  
  Widget _buildDaysOfWeekHeaderMobile() {
    final daysOfWeek = ['M', 'T', 'W', 'Th', 'F', 'St', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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

  Widget _buildCalendarGrid(TodoProvider provider) {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    int crossAxisCount = _isMobileLayout ? 7 : 14;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      crossAxisCount: crossAxisCount,
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: List.generate(_isMobileLayout ? 42 : 56, (index) {
        final dayOffset = index - (firstWeekday - 1);
        final day = dayOffset + 1;

        if (dayOffset < 0 || day > daysInMonth) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
          ); // Empty space for days outside the current month
        }

        final date = DateTime(_focusedDay.year, _focusedDay.month, day);
        final isSelected = date.year == _selectedDay.year &&
            date.month == _selectedDay.month &&
            date.day == _selectedDay.day;
        final isToday = date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;
        final hasEvents = provider.hasEventsOnDay(date);

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
                      : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isToday ? Colors.blue[300]! : Colors.grey[500]!,
                width: isToday ? 1.5 : 0.5,
              ),
            ),
            child: Stack(
              children: [
                Center(
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
                // Green dot for events
                if (hasEvents)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSelectedDayEvents(TodoProvider provider) {
    final events = provider.getEventsForDay(_selectedDay);
    final completedEvents = events.where((e) => e.isCompleted).toList();
    
    return Container(
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
                onPressed: () => _showAddEventDialog(context),
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
          events.isEmpty
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
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                    itemBuilder: (context, index) {
                    final event = events[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                          backgroundColor: event.color,
                            child: Icon(
                            event.icon,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        title: Text(
                          event.title,
                          style: TextStyle(
                            decoration: event.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.description.isNotEmpty)
                              Text(event.description),
                            Text(event.timeString),
                            if (event.recurringType != EventRecurringType.none)
                              Text(
                                event.recurringString,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Check button (only toggles completion)
                            IconButton(
                              icon: Icon(
                                event.isCompleted 
                                    ? Icons.check_circle 
                                    : Icons.check_circle_outline,
                                color: event.isCompleted ? Colors.green : Colors.grey,
                              ),
                              onPressed: () {
                                provider.toggleEventCompletion(event.id);
                              },
                            ),
                            // Edit button
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditEventDialog(context, event),
                            ),
                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteEventDialog(context, event),
                            ),
                          ],
                          ),
                        ),
                      );
                    },
                ),
          // Add Delete All Completed button at the bottom
          if (completedEvents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_sweep, color: Colors.white),
                  label: const Text('Delete All Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    await provider.deleteAllCompletedEventsForDay(_selectedDay);
                  },
                ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    
    final result = await showDialog<CalendarEvent>(
      context: context,
      builder: (context) => EventDialog(selectedDate: _selectedDay),
    );
    
    if (result != null && mounted) {
      await provider.addEvent(result);
    }
  }

  void _showEditEventDialog(BuildContext context, CalendarEvent event) async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    
    final result = await showDialog<CalendarEvent>(
      context: context,
      builder: (context) => EventDialog(
        event: event,
        selectedDate: _selectedDay,
      ),
    );
    
    if (result != null && mounted) {
      await provider.updateEvent(result);
    }
  }

  void _showDeleteEventDialog(BuildContext context, CalendarEvent event) {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteEvent(event.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}