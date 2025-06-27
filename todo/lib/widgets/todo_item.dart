import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import 'edit_todo_dialog.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      key: ValueKey(todo.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: todo.isOverdue ? Colors.red : isDark ? Colors.grey.shade200 : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showEditDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title, priority, and actions
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Priority indicator
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: todo.priorityColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title and completion status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todo.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  decoration: todo.isCompleted 
                                      ? TextDecoration.lineThrough 
                                      : null,
                                  color: todo.isCompleted 
                                      ? isDark ? Colors.grey[200] : Colors.grey[600] 
                                      : isDark ? Colors.grey[200] : Colors.black,
                                ),
                              ),
                              if (todo.description != null && todo.description!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  todo.description!,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: isDark ? Colors.grey[200] : Colors.grey[600],
                                    decoration: todo.isCompleted 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Priority badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: todo.priorityColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          todo.priorityText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: todo.priorityColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Complete checkbox and delete button side by side
                      Row(
                        children: [
                          Checkbox(
                            value: todo.isCompleted,
                            onChanged: (value) {
                              Provider.of<TodoProvider>(context, listen: false)
                                  .toggleTodo(todo.id);
                            },
                            activeColor: const Color.fromARGB(255, 223, 85, 197),

                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await Provider.of<TodoProvider>(context, listen: false)
                                  .deleteTodo(todo.id);
                              if (!context.mounted) return;
                              _showTopNotification(context, 'Task deleted successfully!');
                            },
                            tooltip: 'Delete Task',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Due date and time
              if (todo.dueDate != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: todo.isOverdue ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(todo.dueDate!),
                      style: TextStyle(
                        fontSize: 16,
                        color: todo.isOverdue ? Colors.red : Colors.grey[600],
                        fontWeight: todo.isOverdue ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (todo.dueTime != null) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: todo.isOverdue ? Colors.red : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        todo.dueTime!.format(context),
                        style: TextStyle(
                          fontSize: 16,
                          color: todo.isOverdue ? Colors.red : Colors.grey[600],
                          fontWeight: todo.isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                    if (todo.isOverdue) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
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
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Tags
              if (todo.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: todo.tags.map((tag) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color.fromARGB(255, 32, 32, 32) : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color.fromARGB(255, 151, 57, 134) : Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.blue[200] : Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
              
              // Recurring info
              if (todo.isRecurring) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.repeat,
                      size: 20,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Recurring: ${todo.recurringText}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (todo.endDate != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'until ${DateFormat('MMM dd, yyyy').format(todo.endDate!)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Created date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${DateFormat('MMM dd, yyyy').format(todo.createdAt)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (todo.isCompleted && todo.completedAt != null)
                    Text(
                      'Completed: ${DateFormat('MMM dd, yyyy').format(todo.completedAt!)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditTodoDialog(todo: todo),
    );
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
                  color: Colors.black.withAlpha(50),
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