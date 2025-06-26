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
                const SizedBox(height: 20),
                
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: _buildStatsRow(todoProvider),
                ),
                const SizedBox(height: 20),
                
                // Stop Watch
                // _stopWatch(),
                // const SizedBox(height: 20),

                // Today's Tasks
                _buildTodayTasks(context, todoProvider),
                const SizedBox(height: 20),
                
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
                      icon: const Icon(Icons.timeline, color: Colors.white, size: 30,),
                      label: const Text('Timeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '${todoProvider.todos.where((todo) => todo.isCompleted).length}',
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
                fontSize: 14,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Add haptic feedback
              HapticFeedback.lightImpact();
              
              // Navigate with custom transition
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getPriorityColor(todo.priority).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Priority indicator
                  Container(
                    width: 5,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(todo.priority),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Task content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                todo.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
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
                                  fontSize: 15,
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
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.grey[600],
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
                              size: 25,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('HH:mm').format(todo.createdAt),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (todo.dueDate != null) ...[
                              const SizedBox(width: 16),
                              Icon(
                                Icons.calendar_today,
                                size: 25,
                                color: todo.isOverdue ? Colors.red : Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd').format(todo.dueDate!),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: todo.isOverdue ? Colors.red : Colors.grey[500],
                                  fontWeight: todo.isOverdue ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(todo.priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 25,
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

class _StopWatchWidget extends StatefulWidget {
  @override
  State<_StopWatchWidget> createState() => _StopWatchWidgetState();
}

class _StopWatchWidgetState extends State<_StopWatchWidget> {
  late Stopwatch _stopwatch;
  late Duration _elapsed;
  late Ticker _ticker;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _elapsed = Duration.zero;
    _ticker = Ticker(_onTick);
  }

  void _onTick(Duration _) {
    if (_stopwatch.isRunning) {
      setState(() {
        _elapsed = _stopwatch.elapsed;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _start() {
    _stopwatch.start();
    _ticker.start();
    setState(() {
      _isRunning = true;
    });
  }

  void _stop() {
    _stopwatch.stop();
    _ticker.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _reset() {
    _stopwatch.reset();
    setState(() {
      _elapsed = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_elapsed.inHours);
    final minutes = twoDigits(_elapsed.inMinutes.remainder(60));
    final seconds = twoDigits(_elapsed.inSeconds.remainder(60));
    final milliseconds = (_elapsed.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Stop Watch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(
          '$hours:$minutes:$seconds.$milliseconds',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRunning ? null : _start,
              child: const Text('Start'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isRunning ? _stop : null,
              child: const Text('Stop'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _reset,
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}

class Ticker {
  final void Function(Duration) onTick;
  late final Stopwatch _internalStopwatch;
  late final Duration _interval;
  bool _isActive = false;

  Ticker(this.onTick, {Duration interval = const Duration(milliseconds: 30)}) {
    _internalStopwatch = Stopwatch();
    _interval = interval;
  }

  void start() {
    if (_isActive) return;
    _isActive = true;
    _internalStopwatch.start();
    _tick();
  }

  void stop() {
    _isActive = false;
    _internalStopwatch.stop();
  }

  void dispose() {
    _isActive = false;
  }

  void _tick() async {
    while (_isActive) {
      await Future.delayed(_interval);
      if (_isActive) {
        onTick(_internalStopwatch.elapsed);
      }
    }
  }
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

  // Widget _buildRecentActivity(TodoProvider todoProvider) {
  //   final recentTodos = todoProvider.todos.take(5).toList();
    
  //   return Card(
  //     elevation: 2,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Row(
  //             children: [
  //               Icon(Icons.history, color: Colors.blue),
  //               SizedBox(width: 8),
  //               Text(
  //                 'Recent Activity',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //           if (recentTodos.isEmpty)
  //             const Center(
  //               child: Padding(
  //                 padding: EdgeInsets.all(20),
  //                 child: Text(
  //                   'No recent activity',
  //                   style: TextStyle(
  //                     color: Colors.grey,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //               ),
  //             )
  //           else
  //             ...recentTodos.map((todo) => ListTile(
  //               leading: CircleAvatar(
  //                 backgroundColor: todo.isCompleted ? Colors.green : Colors.blue,
  //                 child: Icon(
  //                   todo.isCompleted ? Icons.check : Icons.schedule,
  //                   color: Colors.white,
  //                   size: 16,
  //                 ),
  //               ),
  //               title: Text(
  //                 todo.title,
  //                 style: TextStyle(
  //                   decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
  //                 ),
  //               ),
  //               subtitle: Text(
  //                 DateFormat('MMM dd, HH:mm').format(todo.createdAt),
  //                 style: const TextStyle(fontSize: 12),
  //               ),
  //             )),
  //         ],
  //       ),
  //     ),
  //   );
  // }

