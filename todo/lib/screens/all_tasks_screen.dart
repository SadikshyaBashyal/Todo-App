import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import 'task_detail_screen.dart';
import 'package:intl/intl.dart';

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final todos = todoProvider.todos;
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
      ),
      body: ListView.separated(
        itemCount: todos.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            leading: Icon(
              todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: todo.isCompleted ? Colors.green : Colors.grey,
            ),
            title: Text(todo.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((todo.description ?? '').isNotEmpty) Text(todo.description!),
                Text('Due: ${todo.dueDate != null ? DateFormat('yyyy-MM-dd').format(todo.dueDate!) : 'No due date'}${todo.dueTime != null ? ' ${todo.dueTime!.format(context)}' : ''}'),
                Text('Priority: ${todo.priorityText}'),
                if (todo.isRecurring && todo.recurringType != null)
                  Text('Recurring: ${todo.recurringType!.name}${todo.customDays != null && todo.customDays!.isNotEmpty ? ' (${todo.customDays!.map((d) => ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d-1]).join(', ')})' : ''}'),
                if (todo.tags.isNotEmpty) Text('Tags: ${todo.tags.join(", ")}'),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(todo: todo),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 