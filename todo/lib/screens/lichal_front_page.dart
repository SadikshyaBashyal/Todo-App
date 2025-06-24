import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
// import '../models/user.dart';
import 'signup_screen.dart';
// import '../widgets/main_navigation.dart';
import '../styles/app_styles.dart';
import '../widgets/auth_widgets.dart';
import '../utils/auth_utils.dart';

class LichalFrontPage extends StatefulWidget {
  const LichalFrontPage({super.key});

  @override
  State<LichalFrontPage> createState() => _LichalFrontPageState();
}

class _LichalFrontPageState extends State<LichalFrontPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkIfUserExists();
  }

  void _checkIfUserExists() {
    // Check if there are any users in the system
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TodoProvider>(context, listen: false);
      if (provider.users.isEmpty) {
        // No users exist, show signup option
        setState(() {});
      }
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<TodoProvider>(context, listen: false);
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
    } catch (e) {
      setState(() {
        _error = 'Login failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // void _showSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(message)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppStyles.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // LICHAL Title
                const Text(
                  'LICHAL',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.white,
                    letterSpacing: 8,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // LICHAL Breakdown
                _buildLichalBreakdown(),
                
                const SizedBox(height: 60),
                
                // Day Care Subtitle
                const Text(
                  'Day Care',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppStyles.white,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Login Form
                _buildLoginForm(),
                
                const SizedBox(height: 30),
                
                // Sign Up Button
                _buildSignUpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLichalBreakdown() {
    final breakdown = [
      {'letter': 'L', 'word': 'Learn'},
      {'letter': 'I', 'word': 'Innovate'},
      {'letter': 'C', 'word': 'Code'},
      {'letter': 'H', 'word': 'Hone'},
      {'letter': 'A', 'word': 'Apply'},
      {'letter': 'L', 'word': 'Lead'},
    ];

    return Column(
      children: breakdown.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppStyles.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  item['letter']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              item['word']!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppStyles.white,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildLoginForm() {
    return AuthWidgets.transparentContainer(
      child: Form(
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
            
            AuthWidgets.defaultSpacing,
            
            AuthWidgets.loadingButton(
              onPressed: _login,
              text: 'Login',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
      },
      child: const Text(
        'Don\'t have an account? Sign Up',
        style: TextStyle(
          color: AppStyles.white,
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
} 