import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
// import '../models/user.dart';
import 'signup_screen.dart';
// import '../widgets/main_navigation.dart';
import '../styles/app_styles.dart';
// import '../widgets/auth_widgets.dart';
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),  // Beautiful blue-purple
              Color(0xFF764ba2),  // Purple
              Color(0xFFf093fb),  // Pink
              Color(0xFFf5576c),  // Red-pink
            ],
            stops: [0.0, 0.25, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  // App Icon/Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Day Care Title
                const Text(
                  'Day Care',
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Color(0x40000000),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  const Text(
                    'Organize your day, achieve your goals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Login Form Container
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Username Field
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.person, color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                            ),
                            validator: AuthUtils.validateUsername,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                            ),
                            validator: AuthUtils.validatePassword,
                          ),
                          
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.red, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(color: Colors.red, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF667eea),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 30),
                
                // Sign Up Button
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Don\'t have an account? Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
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

  // Widget _buildLichalBreakdown() {
  //   final breakdown = [
  //     {'letter': 'L', 'word': 'Learn'},
  //     {'letter': 'I', 'word': 'Innovate'},
  //     {'letter': 'C', 'word': 'Code'},
  //     {'letter': 'H', 'word': 'Hone'},
  //     {'letter': 'A', 'word': 'Apply'},
  //     {'letter': 'L', 'word': 'Lead'},
  //   ];

  //   return Column(
  //     children: breakdown.map((item) => Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 8),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Container(
  //             width: 40,
  //             height: 40,
  //             decoration: BoxDecoration(
  //               color: AppStyles.white,
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             child: Center(
  //               child: Text(
  //                 item['letter']!,
  //                 style: const TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                   color: AppStyles.primaryBlue,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 15),
  //           Text(
  //             item['word']!,
  //             style: const TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.w500,
  //               color: AppStyles.white,
  //             ),
  //           ),
  //         ],
  //       ),
  //     )).toList(),
  //   );
  // }

  // Widget _buildLoginForm() {
  //   return AuthWidgets.transparentContainer(
  //     child: Form(
  //       key: _formKey,
  //       child: Column(
  //         children: [
  //           AuthWidgets.styledTextFormField(
  //             controller: _usernameController,
  //             labelText: 'Username',
  //             prefixIcon: Icons.person,
  //             validator: AuthUtils.validateUsername,
  //           ),
  //           
  //           AuthWidgets.defaultSpacing,
  //           
  //           AuthWidgets.styledTextFormField(
  //             controller: _passwordController,
  //             labelText: 'Password',
  //             prefixIcon: Icons.lock,
  //             obscureText: true,
  //             validator: AuthUtils.validatePassword,
  //           ),
  //           
  //           if (_error != null) ...[
  //             const SizedBox(height: 12),
  //             Text(_error!, style: const TextStyle(color: Colors.red)),
  //           ],
  //           
  //           AuthWidgets.defaultSpacing,
  //           
  //           AuthWidgets.loadingButton(
  //             onPressed: _login,
  //             text: 'Login',
  //             isLoading: _isLoading,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildSignUpButton() {
  //   return TextButton(
  //     onPressed: () {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(builder: (context) => const SignupScreen()),
  //       );
  //     },
  //     child: const Text(
  //       'Don\'t have an account? Sign Up',
  //       style: TextStyle(
  //         color: AppStyles.white,
  //         fontSize: 16,
  //         decoration: TextDecoration.underline,
  //       ),
  //     ),
  //   );
  // }
} 