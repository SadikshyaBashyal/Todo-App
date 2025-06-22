import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_todo_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<TodoProvider>(
          builder: (context, todoProvider, child) {
            return Column(
              children: [
                // Header with stats and filters
                _buildHeader(todoProvider),
                
                // Filter chips
                Flexible(
                  child: _buildFilterChips(todoProvider),
                ),
                
                // Todo list
                Expanded(
                  child: todoProvider.filteredTodos.isEmpty
                      ? _buildEmptyState()
                      : _buildTodoList(todoProvider),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        backgroundColor: const Color.fromARGB(255, 223, 85, 197),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(TodoProvider todoProvider) {
    final totalTodos = todoProvider.todos.length;
    final completedTodos = todoProvider.todos.where((todo) => todo.isCompleted).length;
    final overdueTodos = todoProvider.overdueTodos.length;
    final todayTodos = todoProvider.todayTodos.length;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title and add button
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     IconButton(
          //       onPressed: () => _showAddTodoDialog(context),
          //       icon: const Icon(Icons.add_task),
          //       style: IconButton.styleFrom(
          //         backgroundColor: const Color.fromARGB(255, 223, 85, 197),
          //         foregroundColor: Colors.white,
          //       ),
          //     ),
          //   ],
          // ),
          
          const SizedBox(height: 20),
          
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  totalTodos.toString(),
                  Icons.task_alt,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  completedTodos.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Today',
                  todayTodos.toString(),
                  Icons.today,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Overdue',
                  overdueTodos.toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(TodoProvider todoProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter options
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => todoProvider.clearFilters(),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Status filters
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('All', 'all', todoProvider.filter),
                _buildFilterChip('Today', 'today', todoProvider.filter),
                _buildFilterChip('This Week', 'week', todoProvider.filter),
                _buildFilterChip('Overdue', 'overdue', todoProvider.filter),
                _buildFilterChip('Completed', 'completed', todoProvider.filter),
                _buildFilterChip('Recurring', 'recurring', todoProvider.filter),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Priority filters
            const Text(
              'Priority:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPriorityChip('Urgent', Priority.urgent, todoProvider.selectedPriority),
                _buildPriorityChip('High', Priority.high, todoProvider.selectedPriority),
                _buildPriorityChip('Medium', Priority.medium, todoProvider.selectedPriority),
                _buildPriorityChip('Low', Priority.low, todoProvider.selectedPriority),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Tag filters
            const Text(
              'Tags:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: todoProvider.availableTags.map((tag) {
                return _buildTagChip(tag, todoProvider.selectedTag);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentFilter) {
    final isSelected = currentFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        Provider.of<TodoProvider>(context, listen: false).setFilter(value);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: const Color.fromARGB(255, 223, 85, 197).withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isSelected ? const Color.fromARGB(255, 223, 85, 197) : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildPriorityChip(String label, Priority priority, Priority? selectedPriority) {
    final isSelected = selectedPriority == priority;
    final priorityColor = _getPriorityColor(priority);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        Provider.of<TodoProvider>(context, listen: false)
            .setPriorityFilter(selected ? priority : null);
      },
      backgroundColor: priorityColor.withValues(alpha: 0.1),
      selectedColor: priorityColor.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: priorityColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
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

  Widget _buildTagChip(String tag, String? selectedTag) {
    final isSelected = selectedTag == tag;
    return FilterChip(
      label: Text(tag),
      selected: isSelected,
      onSelected: (selected) {
        Provider.of<TodoProvider>(context, listen: false)
            .setTagFilter(selected ? tag : null);
      },
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      selectedColor: Colors.blue.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: Colors.blue,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTodoList(TodoProvider todoProvider) {
    final todos = todoProvider.filteredTodos;
    
    // Sort todos by priority and due date
    todos.sort((a, b) {
      // First by completion status
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Then by priority
      final priorityOrder = {Priority.urgent: 0, Priority.high: 1, Priority.medium: 2, Priority.low: 3};
      final priorityDiff = priorityOrder[a.priority]! - priorityOrder[b.priority]!;
      if (priorityDiff != 0) return priorityDiff;
      // Then by due date
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      return 0;
    });

    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.width > 600 ? 140 : 120, // Account for FAB + bottom nav
        left: 16,
        right: 16,
        top: 8,
      ),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(todos[index].id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            todoProvider.deleteTodo(todos[index].id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Task deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    // Note: In a real app, you'd implement undo functionality
                  },
                ),
              ),
            );
          },
          child: TodoItem(todo: todos[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
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
              'No tasks found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new task to get started',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddTodoDialog(context),
              icon: const Icon(Icons.add_task),
              label: const Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 85, 197),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
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