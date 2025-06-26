import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_todo_dialog.dart';
// import 'login_screen.dart';

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
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(todoProvider),
                  _buildFilterChips(todoProvider),
                  todoProvider.filteredTodos.isEmpty
                      ? _buildEmptyState()
                      : _buildTodoListSequential(todoProvider),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        backgroundColor: const Color.fromARGB(255, 223, 85, 197),
        child: const Icon(Icons.add_task, color: Colors.white, size: 35,),
      ),
    );
  }

  Widget _buildHeader(TodoProvider todoProvider) {
    final totalTodos = todoProvider.todos.length;
    final completedTodos = todoProvider.todos.where((todo) => todo.isCompleted).length;
    final overdueTodos = todoProvider.overdueTodos.length;
    final todayTodos = todoProvider.todayTodos.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? const Color.fromARGB(255, 10, 10, 10) : const Color.fromARGB(255, 253, 253, 253),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 140, 139, 139).withValues(alpha: 0.1),
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
          
          const SizedBox(height: 8),
          
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),
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
              fontSize: Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS ? 18 : 24,
              color: color.withValues(alpha: 1),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(TodoProvider todoProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS ? 0 : 8),
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
                  child: const Text('Clear', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 0),
            
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
            
            const SizedBox(height: 8),
            
            // Priority filters
            const Text(
              'Priority:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
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
            
            const SizedBox(height: 8),
            
            // Tag filters
            const Text(
              'Tags:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 18)),
      selected: isSelected,
      onSelected: (selected) {
        Provider.of<TodoProvider>(context, listen: false).setFilter(value);
      },
      backgroundColor: isDark ? const Color.fromARGB(255, 154, 153, 153) : Colors.grey[200],
      selectedColor: const Color.fromARGB(255, 223, 85, 197).withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isSelected ? const Color.fromARGB(255, 223, 85, 197) : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 18,
      ),
    );
  }

  Widget _buildPriorityChip(String label, Priority priority, Priority? selectedPriority) {
    final isSelected = selectedPriority == priority;
    final priorityColor = _getPriorityColor(priority);
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 18)),
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
        fontSize: 18,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FilterChip(
      label: Text(tag, style: const TextStyle(fontSize: 18)),
      selected: isSelected,
      onSelected: (selected) {
        Provider.of<TodoProvider>(context, listen: false)
            .setTagFilter(selected ? tag : null);
      },
      backgroundColor: isDark ? const Color.fromARGB(255, 32, 32, 32) : Colors.blue.withValues(alpha: 0.1),
      selectedColor: isDark ? const Color.fromARGB(255, 151, 57, 134) : Colors.blue.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isDark ? Colors.blue[200] : Colors.blue,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 18,
      ),
      side: isSelected
          ? BorderSide(
              color: isDark ? const Color.fromARGB(255, 151, 57, 134) : Colors.blue,
              width: 2,
            )
          : null,
    );
  }

  Widget _buildTodoListSequential(TodoProvider todoProvider) {
    final todos = todoProvider.filteredTodos;
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        ...todos.map((todo) => TodoItem(todo: todo)),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () async {
              // Delete all completed todos
              final provider = Provider.of<TodoProvider>(context, listen: false);
              await provider.deleteAllCompletedTodos();
            },
            icon: const Icon(Icons.delete_forever, color: Colors.white, size: 32),
            label: const Text('Delete All Completed', style: TextStyle(color: Colors.white, fontSize: 20)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
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
              size: 120,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add a new task to get started',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddTodoDialog(context),
              icon: const Icon(Icons.add_task, size: 32),
              label: const Text('Add Task', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 85, 197),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  // void _navigateToLogin() {
  //   Navigator.of(context).pushAndRemoveUntil(
  //     MaterialPageRoute(builder: (_) => const LoginScreen()),
  //     (route) => false,
  //   );
  // }
} 