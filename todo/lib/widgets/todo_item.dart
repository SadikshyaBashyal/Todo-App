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
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        Provider.of<TodoProvider>(context, listen: false).deleteTodo(todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed:  () {
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (value) {
              Provider.of<TodoProvider>(context, listen: false).toggleTodo(todo.id);
            },
            activeColor: Colors.blue[600],
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted ? Colors.grey[600] : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description.isNotEmpty)
                Text(
                  todo.description,
                  style: TextStyle(
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    color: todo.isCompleted ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'Created: ${DateFormat('MMM dd, yyyy').format(todo.createdAt)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
              if (todo.completedAt != null)
                Text(
                  'Completed: ${DateFormat('MMM dd, yyyy').format(todo.completedAt!)}',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(context);
              } else if (value == 'delete') {
                Provider.of<TodoProvider>(context, listen: false).deleteTodo(todo.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
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
} 