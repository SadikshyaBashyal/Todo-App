import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyRoutineScreen extends StatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  State<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  final List<Map<String, dynamic>> _routines = [
    {
      'title': 'Morning Exercise',
      'time': '06:00',
      'duration': '30 min',
      'icon': Icons.fitness_center,
      'color': Colors.orange,
      'completed': false,
    },
    {
      'title': 'Breakfast',
      'time': '07:00',
      'duration': '30 min',
      'icon': Icons.restaurant,
      'color': Colors.green,
      'completed': false,
    },
    {
      'title': 'Work Session',
      'time': '08:00',
      'duration': '4 hours',
      'icon': Icons.work,
      'color': Colors.blue,
      'completed': false,
    },
    {
      'title': 'Lunch Break',
      'time': '12:00',
      'duration': '1 hour',
      'icon': Icons.lunch_dining,
      'color': Colors.purple,
      'completed': false,
    },
    {
      'title': 'Afternoon Work',
      'time': '13:00',
      'duration': '4 hours',
      'icon': Icons.work,
      'color': Colors.blue,
      'completed': false,
    },
    {
      'title': 'Evening Walk',
      'time': '17:00',
      'duration': '45 min',
      'icon': Icons.directions_walk,
      'color': Colors.teal,
      'completed': false,
    },
    {
      'title': 'Dinner',
      'time': '18:30',
      'duration': '1 hour',
      'icon': Icons.dinner_dining,
      'color': Colors.indigo,
      'completed': false,
    },
    {
      'title': 'Reading Time',
      'time': '20:00',
      'duration': '1 hour',
      'icon': Icons.book,
      'color': Colors.brown,
      'completed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 28),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddRoutineDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Today's Date
          _buildDateHeader(),
          
          // Progress Summary
          _buildProgressSummary(),
          
          // Routine List
          Expanded(
            child: _buildRoutineList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[600]!],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 24),
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
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    final completedCount = _routines.where((routine) => routine['completed']).length;
    final totalCount = _routines.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedCount/$totalCount completed',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? Colors.green : Colors.purple[400]!,
                ),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _routines.length,
      itemBuilder: (context, index) {
        final routine = _routines[index];
        final isCompleted = routine['completed'] as bool;
        final isCurrentTime = _isCurrentTimeSlot(routine['time']);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isCurrentTime ? 4 : 2,
          color: isCurrentTime ? Colors.blue[50] : null,
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.grey : routine['color'],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                routine['icon'],
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              routine['title'],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${routine['time']} • ${routine['duration']}',
                  style: TextStyle(
                    color: isCompleted ? Colors.grey : Colors.grey[600],
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
                    child: Text(
                      'Current',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Checkbox(
              value: isCompleted,
              onChanged: (value) {
                setState(() {
                  routine['completed'] = value;
                });
              },
              activeColor: routine['color'],
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

  void _showRoutineDetails(BuildContext context, Map<String, dynamic> routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: routine['color'],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                routine['icon'],
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                routine['title'],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Time', routine['time']),
            _buildDetailRow('Duration', routine['duration']),
            _buildDetailRow('Status', routine['completed'] ? 'Completed' : 'Pending'),
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
                routine['completed'] = !routine['completed'];
              });
              Navigator.of(context).pop();
            },
            child: Text(routine['completed'] ? 'Mark Incomplete' : 'Mark Complete'),
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

  void _showAddRoutineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add, color: Colors.purple),
            SizedBox(width: 8),
            Text('Add Routine'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Activity Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Time (HH:MM)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Duration',
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
              // Add routine logic
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
} 