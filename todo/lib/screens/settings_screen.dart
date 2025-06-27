import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../providers/theme_provider.dart';
import '../models/user.dart';
import '../services/notification_service.dart';
import 'lichal_front_page.dart';
import '../helpers/image_helper.dart';
import '../styles/app_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'dart:convert';  
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _eventNotificationsEnabled = true;
  bool _taskNotificationsEnabled = true;
  bool _dailyReminderEnabled = true;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 21, minute: 0); // 9:00 PM
  String _selectedDateFormat = 'MM/DD/YYYY';
  String _selectedLanguage = 'English';
  
  late NotificationService _notificationService;
  
  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    await _notificationService.initialize();
    setState(() {
      _notificationsEnabled = _notificationService.notificationsEnabled;
      _eventNotificationsEnabled = _notificationService.eventNotificationsEnabled;
      _taskNotificationsEnabled = _notificationService.taskNotificationsEnabled;
      _dailyReminderEnabled = _notificationService.dailyReminderEnabled;
      _dailyReminderTime = _notificationService.dailyReminderTime;
    });
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
      body: Consumer2<TodoProvider, ThemeProvider>(
        builder: (context, provider, themeProvider, child) {
          final currentUser = provider.users.firstWhere(
            (user) => user.username == provider.currentUsername,
            orElse: () => AppUser(username: 'unknown', password: '', name: 'Unknown User'),
          );

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Section
                _buildProfileSection(currentUser, provider),
                
                // Notification Settings
                _buildNotificationSettings(),
                
                // Date & Time Settings
                _buildDateTimeSettings(),
                
                // App Preferences
                _buildAppPreferences(themeProvider),
                
                // Data & Backup
                _buildDataBackup(),
                
                // About & Support
                _buildAboutSupport(),
                
                // Danger Zone
                _buildDangerZone(currentUser),
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

  Widget _buildNotificationSettings() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.orange),
                SizedBox(width: 12),
                Text(
                  'Notification Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Enable Notifications'),
            subtitle: const Text('Master switch for all notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() {
                  _notificationsEnabled = value;
                });
                await _notificationService.setNotificationsEnabled(value);
              },
            ),
          ),
          if (_notificationsEnabled) ...[
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Event Notifications'),
              subtitle: const Text('Reminders for calendar events'),
              trailing: Switch(
                value: _eventNotificationsEnabled,
                onChanged: (value) async {
                  setState(() {
                    _eventNotificationsEnabled = value;
                  });
                  await _notificationService.setEventNotificationsEnabled(value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Task Notifications'),
              subtitle: const Text('Reminders for todo tasks'),
              trailing: Switch(
                value: _taskNotificationsEnabled,
                onChanged: (value) async {
                  setState(() {
                    _taskNotificationsEnabled = value;
                  });
                  await _notificationService.setTaskNotificationsEnabled(value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Daily Reminder'),
              subtitle: Text('Daily reminder at ${_formatTimeOfDay(_dailyReminderTime)}'),
              trailing: Switch(
                value: _dailyReminderEnabled,
                onChanged: (value) async {
                  setState(() {
                    _dailyReminderEnabled = value;
                  });
                  await _notificationService.setDailyReminderEnabled(value);
                },
              ),
            ),
            if (_dailyReminderEnabled)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Daily Reminder Time'),
                subtitle: Text(_formatTimeOfDay(_dailyReminderTime)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showDailyReminderTimeDialog(),
              ),
          ],
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showDailyReminderTimeDialog() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
    );
    
    if (picked != null) {
      setState(() {
        _dailyReminderTime = picked;
      });
      await _notificationService.setDailyReminderTime(picked);
    }
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
      margin: const EdgeInsets.all(16),
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
        ],
      ),
    );
  }

  Widget _buildAppPreferences(ThemeProvider themeProvider) {
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
            leading: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: themeProvider.isDarkMode ? Colors.amber : Colors.indigo,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(themeProvider.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) async {
                await themeProvider.setDarkMode(value);
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
                  'Backup and Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Export tasks as PDF'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              // Try to export data as PDF
              try {
                final provider = Provider.of<TodoProvider>(context, listen: false);
                final todos = provider.todos;
                final events = provider.events;

                // Dynamically import pdf and printing packages if available
                // If not, show a message that export is not available
                try {
                  // Import these at the top of your file:
                  // import 'package:pdf/widgets.dart' as pw;
                  // import 'package:printing/printing.dart';
                  // import 'package:path_provider/path_provider.dart';
                  // import 'dart:io';

                  final pdf = pw.Document();

                  pdf.addPage(
                    pw.MultiPage(
                      build: (pw.Context context) => [
                        pw.Header(level: 0, child: pw.Text('Day Care App Data Export')),
                        pw.SizedBox(height: 10),
                        pw.Text('Tasks:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ...todos.isEmpty
                            ? [pw.Text('No tasks found.')]
                            : todos.map((t) => pw.Bullet(text: t.title)).toList(),
                        pw.SizedBox(height: 20),
                        pw.Text('Events:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ...events.isEmpty
                            ? [pw.Text('No events found.')]
                            : events.map((e) => pw.Bullet(text: e.title)).toList(),
                      ],
                    ),
                  );

                  Directory? dir;
                  try {
                    dir = await getTemporaryDirectory();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export failed: path_provider not available. Add it to pubspec.yaml.')),
                    );
                    return;
                  }

                  final file = File('${dir.path}/daycare_export.pdf');
                  await file.writeAsBytes(await pdf.save());

                  try {
                    await Share.shareXFiles([XFile(file.path)], text: 'Day Care App Data Export (PDF)');
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export failed: share_plus not available. Add it to pubspec.yaml.')),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PDF export not available. Please add "pdf" and "printing" packages to pubspec.yaml.'),
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Export failed: $e')),
                );
              }
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
            onTap: () => _showHelpDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(AppUser user) {
    return Card(  
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 12),
                Text(
                  'Danger Zone',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera, color: Colors.red),
            title: const Text('Change Photo', style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
            onTap: () => _showChangePhotoDialog(user),
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.red),
            title: const Text('Change Username', style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
            onTap: () => _showChangeUsernameDialog(user),
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.red),
            title: const Text('Change Password', style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
            onTap: () => _showChangePasswordDialog(user),
          ),
        ],
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
            onPressed: () async {
              final provider = Provider.of<TodoProvider>(context, listen: false);
              // Clear todos, events, tags, routines, and settings
              final prefs = await SharedPreferences.getInstance();
              final username = provider.currentUsername;
              if (username != null) {
                await prefs.remove('todos_$username');
                await prefs.remove('tags_$username');
                await prefs.remove('events_$username');
                await prefs.remove('routines_$username');
                await prefs.remove('routine_last_reset_$username');
              }
              await provider.refreshUsers();
              await provider.setCurrentUser(username ?? '');
              await NotificationService().cancelAllNotifications();
              if (!context.mounted) return;
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared.')),
              );
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
            Text('Open source project you can check in Help and Support'),
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('For help or support, contact us at:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final url = Uri.parse('https://www.github.com/SadikshyaBashyal/Todo-App');
                try {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw Exception('Cannot open link');
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Something went wrong. Please try again later.')),
                  );
                }
              },
              child: const Text(
                'https://www.github.com/SadikshyaBashyal/Todo-App',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),

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

  void _showChangePhotoDialog(AppUser user) async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    File? selectedImage;
    Uint8List? webImage;
    bool isLoading = false;

    Future<void> pickImage() async {
      final ImagePicker picker = ImagePicker();
      if (kIsWeb) {
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          webImage = await image.readAsBytes();
        }
      } else {
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          selectedImage = File(image.path);
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Change Photo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      setStateDialog(() => isLoading = true);
                      await pickImage();
                      setStateDialog(() => isLoading = false);
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: kIsWeb
                        ? (webImage != null
                            ? ClipOval(child: Image.memory(webImage!, fit: BoxFit.cover, width: 100, height: 100))
                            : const Icon(Icons.add_a_photo, size: 40))
                        : (selectedImage != null
                            ? ClipOval(child: Image.file(selectedImage!, fit: BoxFit.cover, width: 100, height: 100))
                            : const Icon(Icons.add_a_photo, size: 40)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(ImageHelper.getImagePickerText(kIsWeb ? webImage != null : selectedImage != null)),
                  if (isLoading) const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    String photoPath = '';
                    if (kIsWeb && webImage != null) {
                      photoPath = ImageHelper.encodeImageForStorage(webImage);
                    } else if (selectedImage != null) {
                      photoPath = ImageHelper.encodeImageForStorage(selectedImage);
                    }
                    if (photoPath.isNotEmpty) {
                      await provider.updateUserPhoto(photoPath);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeUsernameDialog(AppUser user) {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final controller = TextEditingController(text: user.username);
    String? errorText;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Change Username'),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'New Username',
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final newUsername = controller.text.trim();
                    if (newUsername.isEmpty) {
                      setStateDialog(() => errorText = 'Username cannot be empty');
                      return;
                    }
                    final result = await provider.updateUsername(newUsername);
                    if (result == null) {
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    } else {
                      setStateDialog(() => errorText = result);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog(AppUser user) {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'New Password'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(errorText ?? '', style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final newPassword = controller.text.trim();
                    final confirmPassword = confirmController.text.trim();
                    if (newPassword.isEmpty || confirmPassword.isEmpty) {
                      setStateDialog(() => errorText = 'Password cannot be empty');
                      return;
                    }
                    if (newPassword != confirmPassword) {
                      setStateDialog(() => errorText = 'Passwords do not match');
                      return;
                    }
                    await provider.updatePassword(newPassword);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 