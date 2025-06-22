import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/dashboard_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/daily_routine_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/home_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _is24HourFormat = false;
  late DateTime _currentTime;
  late Timer _timer;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HomeScreen(), // Todo screen
    const CalendarScreen(),
    const DailyRoutineScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _loadTimeFormatPreference();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  Future<void> _loadTimeFormatPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _is24HourFormat = prefs.getString('selectedTimeFormat') == '24-hour';
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 28, color: Colors.white),
            SizedBox(width: 9),
            Text(
              'Day Care',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 85, 223, 108),
        elevation: 2,
        actions: [
          // Time Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.lightBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _is24HourFormat 
                      ? DateFormat('HH:mm:ss').format(_currentTime)
                      : DateFormat('hh:mm:ss a').format(_currentTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Format Toggle Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'toggle_format') {
                setState(() {
                  _is24HourFormat = !_is24HourFormat;
                });
                _saveTimeFormatPreference();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_format',
                child: Row(
                  children: [
                    Icon(
                      _is24HourFormat ? Icons.schedule : Icons.access_time,
                      size: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(_is24HourFormat ? 'Switch to 12h' : 'Switch to 24h'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Refresh time format preference when settings is selected
          if (index == 4) { // Settings tab
            _loadTimeFormatPreference();
          }
        },
        selectedItemColor: const Color.fromARGB(255, 50, 202, 57),
        unselectedItemColor: const Color.fromARGB(255, 94, 93, 93),
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: 32),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt, size: 32),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month, size: 32),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule, size: 32),
            label: 'Routine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 32),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Future<void> _saveTimeFormatPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTimeFormat', _is24HourFormat ? '24-hour' : '12-hour');
  }
} 