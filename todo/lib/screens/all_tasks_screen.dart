import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import 'task_detail_screen.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  Color getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.urgent:
        return Colors.red;
      case Priority.high:
        return Colors.orange;
      case Priority.medium:
        return Colors.blue;
      case Priority.low:
        return Colors.green;
      // default:
      //   return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final todos = todoProvider.todos;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
        backgroundColor: Colors.green,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark ? [const Color(0xFF121212), const Color(0xFF121212)] : [const Color(0xFFE3F0FF), const Color(0xFFF8F8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: todos.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks available.',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first task to get started!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: todos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  final dueDateStr = todo.dueDate != null
                      ? DateFormat('yyyy-MM-dd').format(todo.dueDate!)
                      : 'No due date';
                  final dueTimeStr = todo.dueTime != null ? ' ${todo.dueTime!.format(context)}' : '';
                  final isOverdue = todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted;
                  
                  return _buildTaskCard(context, todo, dueDateStr, dueTimeStr, isOverdue, theme);
                },
              ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Todo todo, String dueDateStr, String dueTimeStr, bool isOverdue, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Add haptic feedback
            HapticFeedback.lightImpact();

            // Navigate with custom transition
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => TaskDetailScreen(todo: todo),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(position: offsetAnimation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOverdue
                    ? (isDark ? Colors.red.shade700 : Colors.red.shade800)
                    : (isDark
                        ? Colors.white
                        : getPriorityColor(todo.priority)),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with completion status, title, and overdue badge
                  Row(
                    children: [
                      // Priority indicator
                      Container(
                        width: 4,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isOverdue ? Colors.red : getPriorityColor(todo.priority),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Completion status icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: todo.isCompleted
                              ? Colors.green.withValues(alpha: 0.1)
                              : getPriorityColor(todo.priority).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: todo.isCompleted ? Colors.green : getPriorityColor(todo.priority),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title
                      Expanded(
                        child: Text(
                          todo.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                            fontSize: 25,
                          ),
                        ),
                      ),

                      // Overdue badge
                      if (isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'OVERDUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Description
                  if ((todo.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.blueGrey.shade900 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.description, color: isDark ? Colors.blue[200] : Colors.blue.shade600, size: 25),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              todo.description!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 18,
                                color: isDark ? Colors.white70 : Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Due date and time
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isOverdue ? (isDark ? Colors.red.shade900 : Colors.red.shade50) : (isDark ? Colors.orange.shade900 : Colors.orange.shade50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOverdue ? (isDark ? Colors.red.shade700 : Colors.red.shade200) : (isDark ? Colors.orange.shade700 : Colors.orange.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: isOverdue ? (isDark ? Colors.white : Colors.red) : (isDark ? Colors.white : Colors.orange),
                          size: 25,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Due: $dueDateStr$dueTimeStr',
                          style: TextStyle(
                            color: isOverdue ? (isDark ? Colors.white : Colors.red) : (isDark ? Colors.white : Colors.orange.shade700),
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Priority and recurring info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: getPriorityColor(todo.priority).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: getPriorityColor(todo.priority).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flag,
                              color: getPriorityColor(todo.priority),
                              size: 25,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Priority: ${todo.priorityText}',
                              style: TextStyle(
                                color: getPriorityColor(todo.priority),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (todo.isRecurring && todo.recurringType != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.purple.shade900 : Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.purple.shade700 : Colors.purple.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.repeat, color: isDark ? Colors.purple[100] : Colors.purple, size: 25),
                              const SizedBox(width: 6),
                              Text(
                                'Recurring: ${todo.recurringType!.name}',
                                style: TextStyle(
                                  color: isDark ? Colors.purple[100] : Colors.purple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Custom recurring days
                  if (todo.isRecurring && todo.recurringType == RecurringType.custom && todo.customDays != null && todo.customDays!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      children: todo.customDays!.map((d) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.purple.shade800 : Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? Colors.purple.shade700 : Colors.purple.shade300),
                        ),
                        child: Text(
                          ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d-1],
                          style: TextStyle(
                            color: isDark ? Colors.purple[100] : Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],

                  // Tags
                  if (todo.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: todo.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.blueGrey.shade800 : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.label, color: isDark ? Colors.blue[200] : Colors.blue, size: 25),
                            const SizedBox(width: 4),
                            Text(
                              tag,
                              style: TextStyle(
                                color: isDark ? Colors.blue[100] : Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ],

                  // // Arrow indicator
                  // const SizedBox(height: 16),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(8),
                  //     decoration: BoxDecoration(
                  //       color: getPriorityColor(todo.priority).withValues(alpha: 0.1),
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Icon(
                  //       Icons.arrow_forward_ios,
                  //       size: 16,
                  //       color: getPriorityColor(todo.priority),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 