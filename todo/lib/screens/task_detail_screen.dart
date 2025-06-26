import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final Todo todo;
  const TaskDetailScreen({super.key, required this.todo});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
    final dueDateStr = widget.todo.dueDate != null
        ? DateFormat('yyyy-MM-dd').format(widget.todo.dueDate!)
        : 'No due date';
    final dueTimeStr = widget.todo.dueTime != null ? ' ${widget.todo.dueTime!.format(context)}' : '';
    final isOverdue = widget.todo.dueDate != null && widget.todo.dueDate!.isBefore(DateTime.now()) && !widget.todo.isCompleted;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: widget.todo.isCompleted ? Colors.green : getPriorityColor(widget.todo.priority),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: Card(
                  elevation: 16,
                  shadowColor: getPriorityColor(widget.todo.priority).withValues(alpha: isDark ? 0.2 : 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: theme.cardColor,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme, isDark),
                        const SizedBox(height: 20),
                        if ((widget.todo.description ?? '').isNotEmpty)
                          _buildDescription(theme, isDark),
                        const SizedBox(height: 20),
                        _buildDueInfo(dueDateStr, dueTimeStr, isOverdue, theme, isDark),
                        const SizedBox(height: 16),
                        _buildPriorityAndRecurring(isDark),
                        if (widget.todo.tags.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildTags(isDark),
                        ],
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.todo.isCompleted 
                ? Colors.green.withValues(alpha: 0.1)
                : getPriorityColor(widget.todo.priority).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            widget.todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: widget.todo.isCompleted ? Colors.green : getPriorityColor(widget.todo.priority),
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            widget.todo.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey.shade900 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.description, color: isDark ? Colors.blue[200] : Colors.blue.shade600, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.todo.description!,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 25, 
                color: isDark ? Colors.white : Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueInfo(String dueDateStr, String dueTimeStr, bool isOverdue, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            color: isOverdue ? (isDark ? Colors.red[100] : Colors.red) : (isDark ? Colors.white : Colors.orange), 
            size: 30
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due: $dueDateStr$dueTimeStr',
                  style: TextStyle(
                    color: isOverdue ? (isDark ? Colors.white : Colors.red) : (isDark ? Colors.white : Colors.orange),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                if (isOverdue) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityAndRecurring(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: getPriorityColor(widget.todo.priority).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: getPriorityColor(widget.todo.priority).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flag, 
                color: isDark ? Colors.red[100] : Colors.red, 
                size: 25
              ),
              const SizedBox(width: 8),
              Text(
                'Priority: ${widget.todo.priorityText}',
                style: TextStyle(
                  color: isDark ? Colors.red[100] : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        if (widget.todo.isRecurring && widget.todo.recurringType != null) ...[
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
                const SizedBox(width: 8),
                Text(
                  'Recurring: ${widget.todo.recurringType!.name}',
                  style: TextStyle(
                    color: isDark ? Colors.purple[100] : Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTags(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.todo.tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.blueGrey.shade800 : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.label, color: isDark ? Colors.blue[200] : Colors.blue, size: 25),
                const SizedBox(width: 6),
                Text(
                  tag,
                  style: TextStyle(
                    color: isDark ? Colors.blue[100] : Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (!widget.todo.isCompleted) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check, size: 30),
          label: const Text(
            'Mark as Completed',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: getPriorityColor(widget.todo.priority),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: getPriorityColor(widget.todo.priority).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();
            Provider.of<TodoProvider>(context, listen: false).toggleTodo(widget.todo.id);
            Navigator.of(context).pop();
          },
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 12),
            Text(
              'Task Completed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }
  }
} 