import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatelessWidget {
  final Todo todo;
  const TaskDetailScreen({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    // final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: todo.isCompleted ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    todo.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if ((todo.description ?? '').isNotEmpty)
              Text(todo.description!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('Due: ${todo.dueDate != null ? DateFormat('yyyy-MM-dd').format(todo.dueDate!) : 'No due date'}${todo.dueTime != null ? ' ${todo.dueTime!.format(context)}' : ''}'),
            const SizedBox(height: 8),
            Text('Priority: ${todo.priorityText}'),
            if (todo.isRecurring && todo.recurringType != null) ...[
              const SizedBox(height: 8),
              Text('Recurring: ${todo.recurringType!.name}${todo.customDays != null && todo.customDays!.isNotEmpty ? ' (${todo.customDays!.map((d) => ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d-1]).join(', ')})' : ''}'),
            ],
            if (todo.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Tags: ${todo.tags.join(", ")}'),
            ],
            const Spacer(),
            if (!todo.isCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as Completed'),
                  onPressed: () {
                    Provider.of<TodoProvider>(context, listen: false).toggleTodo(todo.id);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            if (todo.isCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Completed'),
                  onPressed: null,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 