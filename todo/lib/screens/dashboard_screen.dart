import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard, size: 32, color: Colors.white),
            SizedBox(width: 9),
            Text('Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeCard(),
                const SizedBox(height: 20),
                
                // Quick Stats
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildStatsRow(todoProvider),
                ),
                const SizedBox(height: 20),
                
                // Today's Tasks
                _buildTodayTasks(todoProvider),
                const SizedBox(height: 20),
                
                // Quick Actions
                // _buildQuickActions(context),
                // const SizedBox(height: 20),
                
                // Recent Activity
                _buildRecentActivity(todoProvider),
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
            '${todoProvider.activeTodosCount}',
            Icons.task_alt,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '${todoProvider.completedTodosCount}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
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
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTasks(TodoProvider todoProvider) {
    final todayTodos = todoProvider.todos.where((todo) {
      final today = DateTime.now();
      final todoDate = DateTime(todo.createdAt.year, todo.createdAt.month, todo.createdAt.day);
      final todayDate = DateTime(today.year, today.month, today.day);
      return todoDate.isAtSameMomentAs(todayDate);
    }).toList();

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
                  "Today's Tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${todayTodos.length} tasks',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (todayTodos.isEmpty)
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
              ...todayTodos.take(3).map((todo) => ListTile(
                leading: Icon(
                  todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: todo.isCompleted ? Colors.green : Colors.grey,
                ),
                title: Text(
                  todo.title,
                  style: TextStyle(
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  DateFormat('HH:mm').format(todo.createdAt),
                  style: const TextStyle(fontSize: 12),
                ),
              )),
            if (todayTodos.length > 3)
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to todo screen
                  },
                  child: const Text('View All'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget _buildQuickActions(BuildContext context) {
  //   return Card(
  //     elevation: 2,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Row(
  //             children: [
  //               Icon(Icons.flash_on, color: Colors.orange),
  //               SizedBox(width: 8),
  //               Text(
  //                 'Quick Actions',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: _buildActionButton(
  //                   'Add Task',
  //                   Icons.add_task,
  //                   Colors.blue,
  //                   () {
  //                     // Navigate to add task
  //                   },
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: _buildActionButton(
  //                   'View Calendar',
  //                   Icons.calendar_month,
  //                   Colors.green,
  //                   () {
  //                     // Navigate to calendar
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: _buildActionButton(
  //                   'Daily Routine',
  //                   Icons.schedule,
  //                   Colors.purple,
  //                   () {
  //                     // Navigate to routine
  //                   },
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: _buildActionButton(
  //                   'Settings',
  //                   Icons.settings,
  //                   Colors.grey,
  //                   () {
  //                     // Navigate to settings
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
  //   return InkWell(
  //     onTap: onTap,
  //     borderRadius: BorderRadius.circular(8),
  //     child: Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         border: Border.all(color: color.withValues(alpha: 0.3)),
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Column(
  //         children: [
  //           Icon(icon, color: color, size: 24),
  //           const SizedBox(height: 8),
  //           Text(
  //             title,
  //             style: TextStyle(
  //               color: color,
  //               fontSize: 12,
  //               fontWeight: FontWeight.w500,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildRecentActivity(TodoProvider todoProvider) {
    final recentTodos = todoProvider.todos.take(5).toList();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentTodos.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No recent activity',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ...recentTodos.map((todo) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: todo.isCompleted ? Colors.green : Colors.blue,
                  child: Icon(
                    todo.isCompleted ? Icons.check : Icons.schedule,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                title: Text(
                  todo.title,
                  style: TextStyle(
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MMM dd, HH:mm').format(todo.createdAt),
                  style: const TextStyle(fontSize: 12),
                ),
              )),
          ],
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
} 