import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';

class EventDialog extends StatefulWidget {
  final CalendarEvent? event;
  final DateTime selectedDate;

  const EventDialog({
    super.key,
    this.event,
    required this.selectedDate,
  });

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  IconData _selectedIcon = Icons.event;
  Color _selectedColor = Colors.blue;
  EventRecurringType _recurringType = EventRecurringType.none;
  int? _recurringNth;
  int? _recurringWeekday;

  final List<IconData> _availableIcons = [
    Icons.event,
    Icons.cake,
    Icons.celebration,
    Icons.work,
    Icons.school,
    Icons.medical_services,
    Icons.sports_soccer,
    Icons.music_note,
    Icons.restaurant,
    Icons.flight,
    Icons.hotel,
    Icons.shopping_cart,
    Icons.favorite,
    Icons.family_restroom,
    Icons.pets,
    Icons.local_hospital,
    Icons.meeting_room,
    Icons.business,
    Icons.sports,
    Icons.fitness_center,
    Icons.home,
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.brown,
    Colors.grey,
    Colors.deepOrange,
    Colors.deepPurple,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      // Editing existing event
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _selectedDate = widget.event!.date;
      _selectedTime = widget.event!.time;
      _selectedIcon = widget.event!.icon;
      _selectedColor = widget.event!.color;
      _recurringType = widget.event!.recurringType;
      _recurringNth = widget.event!.recurringNth;
      _recurringWeekday = widget.event!.recurringWeekday;
    } else {
      // Creating new event
      _selectedDate = widget.selectedDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.event != null ? Icons.edit : Icons.add,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Text(widget.event != null ? 'Edit Event' : 'Add Event'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Icon Selection
                _buildIconSelection(),
                const SizedBox(height: 16),
                
                // Color Selection
                _buildColorSelection(),
                const SizedBox(height: 16),
                
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // Date Selection
                _buildDateSelection(),
                const SizedBox(height: 16),
                
                // Time Selection
                _buildTimeSelection(),
                const SizedBox(height: 16),
                
                // Recurring Selection
                _buildRecurringSelection(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveEvent,
          child: Text(widget.event != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Widget _buildIconSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Icon',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final icon = _availableIcons[index];
              final isSelected = icon == _selectedIcon;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? _selectedColor.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: isSelected 
                        ? Border.all(color: _selectedColor, width: 2)
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? _selectedColor : Colors.grey[600],
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Color',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((color) {
            final isSelected = color == _selectedColor;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected 
                      ? Border.all(color: Colors.black, width: 3)
                      : null,
                ),
                child: isSelected 
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    return Row(
      children: [
        const Icon(Icons.calendar_today),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Date',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
            ),
            controller: TextEditingController(
              text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Row(
      children: [
        const Icon(Icons.access_time),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Time (Optional)',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.schedule),
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
              ),
            ),
            controller: TextEditingController(
              text: _selectedTime != null 
                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                  : 'All day',
            ),
          ),
        ),
        if (_selectedTime != null)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _selectedTime = null;
              });
            },
          ),
      ],
    );
  }

  Widget _buildRecurringSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recurring',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<EventRecurringType>(
          value: _recurringType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.repeat),
          ),
          items: EventRecurringType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getRecurringText(type)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _recurringType = value!;
            });
          },
        ),
        if (_recurringType == EventRecurringType.monthlyNthWeekday) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              // Nth dropdown
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _recurringNth,
                  decoration: const InputDecoration(
                    labelText: 'Which',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(5, (i) => i + 1).map((n) {
                    return DropdownMenuItem(
                      value: n,
                      child: Text(['First', 'Second', 'Third', 'Fourth', 'Fifth'][n - 1]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _recurringNth = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Weekday dropdown
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _recurringWeekday,
                  decoration: const InputDecoration(
                    labelText: 'Day',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DateTime.monday,
                    DateTime.tuesday,
                    DateTime.wednesday,
                    DateTime.thursday,
                    DateTime.friday,
                    DateTime.saturday,
                    DateTime.sunday,
                  ].map((w) {
                    return DropdownMenuItem(
                      value: w,
                      child: Text([
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                        'Saturday',
                        'Sunday',
                      ][w - 1]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _recurringWeekday = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _getRecurringText(EventRecurringType type) {
    switch (type) {
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
      // case EventRecurringType.monthlySunday:
      //   return 'Every Sunday of the month';
      case EventRecurringType.monthlyNthWeekday:
        return 'Every Nth weekday';
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final event = CalendarEvent(
        id: widget.event?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        time: _selectedTime,
        icon: _selectedIcon,
        color: _selectedColor,
        recurringType: _recurringType,
        recurringNth: _recurringType == EventRecurringType.monthlyNthWeekday ? _recurringNth : null,
        recurringWeekday: _recurringType == EventRecurringType.monthlyNthWeekday ? _recurringWeekday : null,
        isCompleted: widget.event?.isCompleted ?? false,
        completedAt: widget.event?.completedAt,
      );
      
      Navigator.of(context).pop(event);
    }
  }
} 