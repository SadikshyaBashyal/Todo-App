import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_todo_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 28),
            SizedBox(width: 8),
            Text('To Do List'),
          ],
        ),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.filteredTodos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    todoProvider.todos.isEmpty 
                        ? 'No tasks yet!\nTap + to add your first task'
                        : 'No ${todoProvider.filter} tasks',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter tabs
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip(context, 'All', 'all', todoProvider),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Active', 'active', todoProvider),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Completed', 'completed', todoProvider),
                  ],
                ),
              ),
              
              // Stats
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${todoProvider.activeTodosCount} active',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (todoProvider.completedTodosCount > 0)
                      TextButton(
                        onPressed: () => todoProvider.clearCompleted(),
                        child: Text(
                          'Clear completed',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Todo list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: todoProvider.filteredTodos.length,
                  itemBuilder: (context, index) {
                    final todo = todoProvider.filteredTodos[index];
                    return TodoItem(todo: todo);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String filter, TodoProvider provider) {
    final isSelected = provider.filter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          provider.setFilter(filter);
        }
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[600],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue[600] : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );
  }
} 