import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

class DailyRoutineScreen extends StatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  State<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  List<Routine> _routines = [];
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndRoutines();
  }

  Future<void> _loadCurrentUserAndRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUsername = prefs.getString('currentUser');
    if (_currentUsername == null) return;
    final routinesJson = prefs.getStringList('routines_${_currentUsername!}');
    if (routinesJson == null) {
      // First login: set default routines
      _routines = _defaultRoutines();
      await _saveRoutines();
    } else {
      _routines = routinesJson.map((json) => Routine.fromJson(jsonDecode(json))).toList();
    }
    // Reset completed status if a new day
    final lastReset = prefs.getString('routine_last_reset_${_currentUsername!}');
    if (lastReset == null || DateTime.parse(lastReset).day != DateTime.now().day) {
      for (var r in _routines) {
        r.completed = false;
      }
      await prefs.setString('routine_last_reset_${_currentUsername!}', DateTime.now().toIso8601String());
      await _saveRoutines();
    }
    setState(() {});
  }

  Future<void> _saveRoutines() async {
    if (_currentUsername == null) return;
    final prefs = await SharedPreferences.getInstance();
    final routinesJson = _routines.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('routines_${_currentUsername!}', routinesJson);
  }

  List<Routine> _defaultRoutines() => [
    Routine(title: 'Morning Exercise', icon: Icons.fitness_center, color: Colors.orange, time: '06:00', duration: '30 min'),
    // Routine(title: 'Breakfast', icon: Icons.restaurant, color: Colors.green, time: '07:00', duration: '30 min'),
    Routine(title: 'Work Session', icon: Icons.work, color: Colors.blue, time: '08:00', duration: '4 hours'),
    // Routine(title: 'Lunch Break', icon: Icons.lunch_dining, color: Colors.purple, time: '12:00', duration: '1 hour'),
    Routine(title: 'Afternoon Work', icon: Icons.work, color: Colors.blue, time: '13:00', duration: '4 hours'),
    // Routine(title: 'Evening Walk', icon: Icons.directions_walk, color: Colors.teal, time: '17:00', duration: '45 min'),
    // Routine(title: 'Dinner', icon: Icons.dinner_dining, color: Colors.indigo, time: '18:30', duration: '1 hour'),
    Routine(title: 'Reading Time', icon: Icons.book, color: Colors.brown, time: '20:00', duration: '1 hour'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(

      body: SingleChildScrollView(
        // backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        child: Column(
        children: [
          // Today's Date
          _buildDateHeader(),

          // Routine List
            _buildRoutineList(isDark),
          ],
          ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[600]!],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        const Spacer(),
        ElevatedButton.icon(
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 2,
          ),
          onPressed: () {
              _showRoutineDialog();
          },
        ),
        ],
      ),
    );
  }

  Widget _buildRoutineList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _routines.length,
      itemBuilder: (context, index) {
        final routine = _routines[index];
        final isCompleted = routine.completed;
        final isCurrentTime = _isCurrentTimeSlot(routine.time);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: isCurrentTime ? 4 : 2,
          color: isCurrentTime ? Colors.blue[50] : null,
          shape: isDark
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.grey, width: 2),
                )
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.grey : routine.color,
                borderRadius: BorderRadius.circular(25),
                border: isDark
                    ? Border.all(color: Colors.grey, width: 2)
                    : null,
              ),
              child: Icon(
                routine.icon,
                color: isDark ? Colors.grey[200] : Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              routine.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${routine.time} • ${routine.duration}',
                  style: TextStyle(
                    color: isDark ? Colors.grey[200] : isCompleted ? Colors.grey : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (isCurrentTime)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
              ],
            ),
            trailing: SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: Checkbox(
                      value: isCompleted,
                      onChanged: (value) async {
                        setState(() {
                          routine.completed = value!;
                        });
                        await _saveRoutines();
                      },
                      activeColor: routine.color,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                        onPressed: () {
                          _showRoutineDialog(routine: routine, editIndex: index);
                        },
                        tooltip: 'Edit',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      ),
                      const SizedBox(width: 0),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                        onPressed: () async {
                          setState(() {
                            _routines.removeAt(index);
                          });
                          await _saveRoutines();
                        },
                        tooltip: 'Delete',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () {
              _showRoutineDetails(context, routine);
            },
          ),
        );
      },
    );
  }

  bool _isCurrentTimeSlot(String timeString) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Simple time comparison - in a real app, you'd want more sophisticated logic
    return currentTime == timeString;
  }

  void _showRoutineDetails(BuildContext context, Routine routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: routine.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                routine.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                routine.title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Time', routine.time),
            _buildDetailRow('Duration', routine.duration),
            _buildDetailRow('Status', routine.completed ? 'Completed' : 'Pending'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                routine.completed = !routine.completed;
              });
              Navigator.of(context).pop();
            },
            child: Text(routine.completed ? 'Mark Incomplete' : 'Mark Complete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showRoutineDialog({Routine? routine, int? editIndex}) {
    final isEdit = routine != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    IconData selectedIcon = isEdit ? routine.icon : Icons.fitness_center;
    Color selectedColor = isEdit ? routine.color : Colors.orange;
    final titleController = TextEditingController(text: isEdit ? routine.title : '');
    TimeOfDay? selectedTime = isEdit && routine.time.isNotEmpty
        ? _parseTimeOfDay(routine.time)
        : null;
    final durationController = TextEditingController(
      text: isEdit && routine.duration.isNotEmpty
        ? RegExp(r'\d+').stringMatch(routine.duration) ?? ''
        : '',
    );
    String durationUnit = isEdit && routine.duration.isNotEmpty
        ? (routine.duration.contains('hour') ? 'hour' : 'min')
        : 'min';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Routine' : 'Add Routine'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon selection
                    Row(
                      children: [
                        const Text('Icon:'),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: isDark ? Colors.grey[400] : Colors.grey[200],
                            elevation: 0,
                          ),
                          onPressed: () async {
                            IconData? pickedIcon = await showDialog<IconData>(
                              context: context,
                              builder: (context) {
                                final icons = [
                                  Icons.fitness_center,
                                  Icons.restaurant,
                                  Icons.work,
                                  Icons.lunch_dining,
                                  Icons.directions_walk,
                                  Icons.dinner_dining,
                                  Icons.book,
                                  Icons.nightlight_round,
                                  Icons.alarm,
                                  Icons.music_note,
                                  Icons.sports_soccer,
                                  Icons.local_cafe,
                                  Icons.computer,
                                  Icons.phone,
                                  Icons.shopping_cart,
                                  Icons.pets,
                                ];
                                return AlertDialog(
                                  title: const Text('Select Icon'),
                                  content: SizedBox(
                                    width: 300,
                                    child: GridView.count(
                                      crossAxisCount: 4,
                                      shrinkWrap: true,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      children: icons.map((icon) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop(icon);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: icon == selectedIcon
                                                  ? Colors.purple[100]
                                                  : Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: icon == selectedIcon
                                                    ? Colors.purple
                                                    : Colors.grey[300]!,
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              icon,
                                              size: 32,
                                              color: icon == selectedIcon
                                                  ? Colors.purple
                                                  : Colors.black54,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            );
                            if (pickedIcon != null) {
                              setStateDialog(() => selectedIcon = pickedIcon);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(selectedIcon, color: Colors.black87),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        // Color selection
                        const Text('Color:'),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: isDark ? Colors.grey[400] : Colors.grey[200],
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final colors = [
                              Colors.orange,
                              Colors.green,
                              Colors.blue,
                              Colors.purple,
                              Colors.teal,
                              Colors.indigo,
                              Colors.brown,
                              Colors.red,
                              Colors.pink,
                              Colors.amber,
                              Colors.cyan,
                              Colors.lime,
                              Colors.deepOrange,
                              Colors.deepPurple,
                              Colors.grey,
                            ];
                            Color? pickedColor = await showDialog<Color>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Select Color'),
                                  content: SizedBox(
                                    width: 300,
                                    child: GridView.count(
                                      crossAxisCount: 5,
                                      shrinkWrap: true,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      children: colors.map((color) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop(color);
                                          },
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: color == selectedColor
                                                    ? Colors.purple
                                                    : Colors.grey[300]!,
                                                width: color == selectedColor ? 3 : 1,
                                              ),
                                            ),
                                            child: color == selectedColor
                                                ? const Icon(Icons.check, color: Colors.white)
                                                : null,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            );
                            if (pickedColor != null) {
                              setStateDialog(() => selectedColor = pickedColor);
                            }
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: selectedColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black12),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Title
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Time
                    Row(
                      children: [
                        const Text('Time:'),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setStateDialog(() => selectedTime = picked);
                            }
                          },
                          child: Text(selectedTime != null
                              ? selectedTime!.format(context)
                              : 'Pick Time'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Duration
                    Row(
                      children: [
                        const Text('Duration:'),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: durationUnit,
                          items: const [
                            DropdownMenuItem(value: 'min', child: Text('min')),
                            DropdownMenuItem(value: 'hour', child: Text('hour')),
                          ],
                          onChanged: (val) {
                            setStateDialog(() => durationUnit = val!);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty || selectedTime == null || durationController.text.trim().isEmpty) return;
                    final routineData = Routine(
                      title: titleController.text.trim(),
                      icon: selectedIcon,
                      color: selectedColor,
                      time: selectedTime!.format(context),
                      duration: '${durationController.text} ${durationUnit == 'hour' ? 'hour' : 'min'}',
                    );
                    setState(() {
                      if (isEdit && editIndex != null) {
                        _routines[editIndex] = routineData;
                      } else {
                        _routines.add(routineData);
                      }
                    });
                    final navigator = Navigator.of(context);
                    await _saveRoutines();
                    if (mounted) {
                      navigator.pop();
                    }
                  },
                  child: Text(isEdit ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      return TimeOfDay.fromDateTime(DateFormat.Hm().parse(timeStr));
    } catch (_) {
      try {
        return TimeOfDay.fromDateTime(DateFormat.jm().parse(timeStr));
      } catch (_) {
        return null;
      }
    }
  }
}