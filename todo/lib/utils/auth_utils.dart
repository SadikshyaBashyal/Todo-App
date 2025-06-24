import 'package:flutter/material.dart';
import '../models/user.dart';
import '../providers/todo_provider.dart';
import '../widgets/main_navigation.dart';

class AuthUtils {
  // Validation functions
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length != 4) {
      return 'Password must be exactly 4 digits';
    }
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'Password must contain only digits';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  // Navigation helper
  static void navigateToMainNavigation(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }

  // Authentication helper
  static Future<bool> authenticateUser(
    TodoProvider provider,
    String username,
    String password,
  ) async {
    try {
      final user = provider.users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      await provider.setCurrentUser(user.username);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if username exists
  static bool isUsernameTaken(TodoProvider provider, String username) {
    return provider.users.any((u) => u.username == username);
  }

  // Create new user
  static Future<AppUser> createUser(
    TodoProvider provider,
    String username,
    String password,
    String name,
  ) async {
    final user = AppUser(
      username: username,
      password: password,
      name: name,
      photoPath: null,
    );
    
    // Add user to the provider
    await provider.addUser(user);
    
    // Refresh the user list to ensure it's updated
    await provider.refreshUsers();
    
    // Set as current user
    await provider.setCurrentUser(username);
    
    return user;
  }
} 