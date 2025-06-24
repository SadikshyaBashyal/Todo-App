import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/user.dart';
import 'lichal_front_page.dart';
import '../helpers/image_helper.dart';
import '../styles/app_styles.dart';
// import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoBackupEnabled = true;
  String _selectedTimeFormat = '12-hour';
  String _selectedDateFormat = 'MM/DD/YYYY';
  String _selectedLanguage = 'English';
  
  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout() async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    await provider.logout();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LichalFrontPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Icon(Icons.settings, size: 28),
      //       SizedBox(width: 8),
      //       Text('Settings'),
      //     ],
      //   ),
      // ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          final currentUser = provider.users.firstWhere(
            (user) => user.username == provider.currentUsername,
            orElse: () => AppUser(username: 'unknown', password: '', name: 'Unknown User'),
          );

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Section
                _buildProfileSection(currentUser, provider),
                
                // Date & Time Settings
                _buildDateTimeSettings(),
                
                // App Preferences
                _buildAppPreferences(),
                
                // Data & Backup
                _buildDataBackup(),
                
                // About & Support
                _buildAboutSupport(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(AppUser user, TodoProvider provider) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppStyles.primaryBlue,
              child: ClipOval(
                child: _buildProfileImage(user),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.username,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfileStat('Tasks', '${provider.todos.length}'),
                _buildProfileStat('Completed', '${provider.todos.where((todo) => todo.isCompleted).length}'),
                _buildProfileStat('Pending', '${provider.todos.where((todo) => !todo.isCompleted).length}'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(AppUser user) {
    return ImageHelper.buildImageWidget(
      user.photoPath ?? '',
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      fallbackWidget: const Icon(
        Icons.person,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppStyles.primaryBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSettings() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'Date & Time Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Time Format'),
            subtitle: Text(_selectedTimeFormat),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showTimeFormatDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date Format'),
            subtitle: Text(_selectedDateFormat),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showDateFormatDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showLanguageDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Enable push notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferences() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.tune, color: Colors.green),
                SizedBox(width: 12),
                Text(
                  'App Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Auto-sort Tasks'),
            subtitle: const Text('Sort tasks by priority'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Auto-sort logic
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.vibration),
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate on interactions'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Haptic feedback logic
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataBackup() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.backup, color: Colors.orange),
                SizedBox(width: 12),
                Text(
                  'Data & Backup',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Auto Backup'),
            subtitle: const Text('Backup data to cloud'),
            trailing: Switch(
              value: _autoBackupEnabled,
              onChanged: (value) {
                setState(() {
                  _autoBackupEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Export tasks to file'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Export logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import Data'),
            subtitle: const Text('Import tasks from file'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Import logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all tasks and settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showClearDataDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSupport() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.purple),
                SizedBox(width: 12),
                Text(
                  'About & Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Day Care'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showAboutDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help and contact support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Help logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.rate_review),
            title: const Text('Rate App'),
            subtitle: const Text('Rate us on app store'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Rate app logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            subtitle: const Text('Share with friends'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Share logic
            },
          ),
        ],
      ),
    );
  }

  void _showTimeFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Time Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('12-hour (AM/PM)'),
              value: '12-hour',
              groupValue: _selectedTimeFormat,
              onChanged: (value) {
                setState(() {
                  _selectedTimeFormat = value.toString();
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile(
              title: const Text('24-hour'),
              value: '24-hour',
              groupValue: _selectedTimeFormat,
              onChanged: (value) {
                setState(() {
                  _selectedTimeFormat = value.toString();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDateFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('MM/DD/YYYY'),
              value: 'MM/DD/YYYY',
              groupValue: _selectedDateFormat,
              onChanged: (value) {
                setState(() {
                  _selectedDateFormat = value.toString();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value.toString();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your tasks, routines, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear data logic
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.access_time, color: Colors.blue),
            SizedBox(width: 8),
            Text('Day Care'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A modern todo and time management app'),
            SizedBox(height: 16),
            Text('© 2024 Day Care App'),
            Text('All rights reserved'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 