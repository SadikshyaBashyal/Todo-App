import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import 'timeline_screen.dart';
import 'all_tasks_screen.dart';
import 'task_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Icon(Icons.dashboard, size: 32, color: Colors.white),
      //     ],
      //   ),
      // ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeCard(),
                const SizedBox(height: 5),
                
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: _buildStatsRow(todoProvider),
                ),
                const SizedBox(height: 5),
                
                // Stop Watch
                // _stopWatch(),
                // const SizedBox(height: 20),

                // Today's Tasks
                _buildTodayTasks(context, todoProvider),
                const SizedBox(height: 5),
                
                // Quick Actions
                // _buildQuickActions(context),
                // const SizedBox(height: 20),
                
                // Recent Activity
                // _buildRecentActivity(todoProvider),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.timeline, color: Colors.white, size: 25,),
                      label: const Text('Timeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TimelineScreen()),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 28, 70, 238), Color.fromARGB(255, 51, 135, 208)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(now),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Day Care',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(TodoProvider todoProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Tasks',
            '${todoProvider.todos.where((todo) => !todo.isCompleted).length}',
            Icons.task_alt,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '${todoProvider.todos.where((todo) => todo.isCompleted).length}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Total',
            '${todoProvider.todos.length}',
            Icons.list_alt,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTodayTasks(BuildContext context, TodoProvider todoProvider) {
    final ongoingTodos = todoProvider.todos.where((todo) => !todo.isCompleted).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  "Ongoing Tasks",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '	${ongoingTodos.length} tasks',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (ongoingTodos.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No tasks for today',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ...ongoingTodos.take(2).map((todo) => _buildTaskCard(context, todo)),
            if (ongoingTodos.length > 2)
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AllTasksScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Set the button background color
                  ),
                  child: const Text('View All', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                ),
              ),
          ],
        ),
      ),
      
    );
  }

  Widget _buildTaskCard(BuildContext context, Todo todo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
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
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getPriorityColor(todo.priority).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(todo.priority),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                todo.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(todo.priority).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                todo.priorityText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _getPriorityColor(todo.priority),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (todo.description != null && todo.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            todo.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: isDark ? Colors.white54 : Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('HH:mm').format(todo.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 16,
                                color: isDark ? Colors.white54 : Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (todo.dueDate != null) ...[
                              const SizedBox(width: 16),
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: todo.isOverdue ? Colors.red : (isDark ? Colors.white54 : Colors.grey[500]),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd').format(todo.dueDate!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 16,
                                  color: todo.isOverdue ? Colors.red : (isDark ? Colors.white54 : Colors.grey[500]),
                                  fontWeight: todo.isOverdue ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(todo.priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: _getPriorityColor(todo.priority),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
      // default:
      //   return Colors.grey;
    }
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
