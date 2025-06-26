import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({super.key});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Priority _priority = Priority.medium;
  final List<String> _selectedTags = [];
  bool _isRecurring = false;
  RecurringType _recurringType = RecurringType.todayOnly;
  final List<int> _customDays = [];
  DateTime? _endDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Task',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 223, 85, 197),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildTextField(
                        controller: _titleController,
                        label: 'Task Title *',
                        hint: 'Enter task title',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description (Optional)',
                        hint: 'Enter task description',
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Due Date & Time
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePicker(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimePicker(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Priority
                      _buildPrioritySelector(),
                      
                      const SizedBox(height: 16),
                      
                      // Tags
                      _buildTagSelector(),
                      
                      const SizedBox(height: 16),
                      
                      // Recurring
                      _buildRecurringSection(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTodo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 223, 85, 197),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Add Task', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Due Date (Optional)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select Date',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Due Time (Optional)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
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
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'Select Time',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: Priority.values.map((priority) {
            final isSelected = _priority == priority;
            final priorityColor = _getPriorityColor(priority);
            return ChoiceChip(
              label: Text(priority.name.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _priority = priority;
                  });
                }
              },
              backgroundColor: isDark ? const Color.fromARGB(255, 32, 32, 32) : Colors.grey[200],
              selectedColor: priorityColor.withValues(alpha: 0.3),
              labelStyle: TextStyle(
                color: isSelected ? priorityColor : isDark ? Colors.grey[200] : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 17,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getPriorityColor(Priority priority) {
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

  Widget _buildTagSelector() {
    final provider = Provider.of<TodoProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Available tags
        Wrap(
          spacing: 8,
          children: provider.availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: isDark ? const Color.fromARGB(255, 151, 57, 134) : Colors.grey[200], 
              labelStyle: const TextStyle(fontSize: 17),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Add new tag
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Add new tag',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_tagController.text.trim().isNotEmpty) {
                  final newTag = _tagController.text.trim();
                  provider.addTag(newTag);
                  setState(() {
                    _selectedTags.add(newTag);
                  });
                  _tagController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecurringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value ?? false;
                });
              },
            ),
            const Text(
              'Recurring Task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        if (_isRecurring) ...[
          const SizedBox(height: 12),
          
          // Recurring type
          const Text(
            'Repeat on:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          Column(
            children: [
              RadioListTile<RecurringType>(
                title: const Text('Today Only'),
                value: RecurringType.todayOnly,
                groupValue: _recurringType,
                onChanged: (value) {
                  setState(() {
                    _recurringType = value!;
                  });
                },
              ),
              RadioListTile<RecurringType>(
                title: const Text('Weekdays (Mon-Fri)'),
                value: RecurringType.weekdays,
                groupValue: _recurringType,
                onChanged: (value) {
                  setState(() {
                    _recurringType = value!;
                  });
                },
              ),
              RadioListTile<RecurringType>(
                title: const Text('All Days'),
                value: RecurringType.allDays,
                groupValue: _recurringType,
                onChanged: (value) {
                  setState(() {
                    _recurringType = value!;
                  });
                },
              ),
              RadioListTile<RecurringType>(
                title: const Text('Custom'),
                value: RecurringType.custom,
                groupValue: _recurringType,
                onChanged: (value) {
                  setState(() {
                    _recurringType = value!;
                  });
                },
              ),
            ],
          ),
          
          if (_recurringType == RecurringType.custom) ...[
            const SizedBox(height: 12),
            const Text(
              'Select Days:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildDayChip('M', 1),
                _buildDayChip('T', 2),
                _buildDayChip('W', 3),
                _buildDayChip('T', 4),
                _buildDayChip('F', 5),
                _buildDayChip('S', 6),
                _buildDayChip('S', 7),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          
          // End date
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _endDate = date;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_busy),
                  const SizedBox(width: 8),
                  Text(
                    _endDate != null
                        ? 'End Date: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Set End Date (Optional)',
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDayChip(String label, int dayNumber) {
    final isSelected = _customDays.contains(dayNumber);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const pinkColor = Color.fromARGB(255, 223, 85, 197); // Same as tag pink

    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 17)),
      selected: isSelected,
      selectedColor: isDark ? pinkColor.withValues(alpha: 0.18) : theme.colorScheme.primary.withValues(alpha: 0.12),
      backgroundColor: isDark ? Colors.grey[800] : null,
      labelStyle: TextStyle(
        color: isSelected
            ? (isDark ? pinkColor : theme.colorScheme.primary)
            : (isDark ? Colors.white : Colors.black),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: isSelected
          ? BorderSide(
              color: isDark ? pinkColor : theme.colorScheme.primary,
              width: 2,
            )
          : null,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _customDays.add(dayNumber);
          } else {
            _customDays.remove(dayNumber);
          }
        });
      },
    );
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final todo = Todo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        dueDate: _selectedDate,
        dueTime: _selectedTime,
        priority: _priority,
        tags: _selectedTags,
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : null,
        customDays: _isRecurring && _recurringType == RecurringType.custom 
            ? _customDays 
            : null,
        endDate: _endDate,
      );

      Provider.of<TodoProvider>(context, listen: false).addTodo(todo);
      Navigator.of(context).pop();
      
      // Show success message at top
      _showTopNotification(context, 'Task created successfully!');
    }
  }

  void _showTopNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        right: 10,
        left: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => overlayEntry.remove(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
} 