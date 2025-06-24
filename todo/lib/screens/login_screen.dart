import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/user.dart';
// import 'home_screen.dart';
import 'signup_screen.dart';
// import 'dashboard_screen.dart';
// import '../widgets/main_navigation.dart';
import '../styles/app_styles.dart';
import '../widgets/auth_widgets.dart';
import '../utils/auth_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(TodoProvider provider) async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      
      final success = await AuthUtils.authenticateUser(provider, username, password);
      
      if (success && mounted) {
        AuthUtils.navigateToMainNavigation(context);
      } else {
        setState(() {
          _error = 'Invalid username or password';
        });
      }
    }
  }

  void _quickLogin(TodoProvider provider, AppUser user) async {
    await provider.setCurrentUser(user.username);
    if (mounted) {
      AuthUtils.navigateToMainNavigation(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppStyles.primaryGradient),
        child: SafeArea(
          child: Consumer<TodoProvider>(
            builder: (context, provider, child) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppStyles.defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome to Todo App',
                        style: AppStyles.titleStyle,
                      ),
                      AuthWidgets.largeSpacing,
                      
                      // Quick Login Section
                      if (provider.users.isNotEmpty) ...[
                        const Text('Quick Login:', style: AppStyles.subtitleStyle),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: provider.users.map((user) {
                            return AuthWidgets.quickLoginButton(
                              onPressed: () => _quickLogin(provider, user),
                              label: user.name,
                            );
                          }).toList(),
                        ),
                        AuthWidgets.largeSpacing,
                      ],
                      
                      // Login Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AuthWidgets.styledTextFormField(
                              controller: _usernameController,
                              labelText: 'Username',
                              prefixIcon: Icons.person,
                              validator: AuthUtils.validateUsername,
                            ),
                            AuthWidgets.defaultSpacing,
                            AuthWidgets.styledTextFormField(
                              controller: _passwordController,
                              labelText: 'Password',
                              prefixIcon: Icons.lock,
                              obscureText: true,
                              validator: AuthUtils.validatePassword,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(_error!, style: const TextStyle(color: Colors.red)),
                            ],
                            const SizedBox(height: 24),
                            AuthWidgets.loadingButton(
                              onPressed: () => _login(provider),
                              text: 'Login',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          'Create a new account',
                          style: TextStyle(color: AppStyles.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 