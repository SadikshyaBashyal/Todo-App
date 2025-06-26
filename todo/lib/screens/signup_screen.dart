import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
// import 'dart:convert';
import '../helpers/image_helper.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
// import '../models/user.dart';
// import 'home_screen.dart';
// import 'lichal_front_page.dart';
// import '../widgets/lichal_front_page.dart';hen cl
import '../styles/app_styles.dart';
// import '../widgets/auth_widgets.dart';
import '../utils/auth_utils.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        // Web implementation
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
        );
        
        if (image != null) {
          final bytes = await image.readAsBytes();
          if (!mounted) return;
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
          _showSnackBar('Photo selected successfully!', isSuccess: true);
        }
      } else {
        // Mobile/Desktop implementation
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
        );
        
        if (image != null) {
          if (!mounted) return;
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
          });
          _showSnackBar('Photo selected successfully!', isSuccess: true);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error picking image: $e', isSuccess: false);
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Check if we're on desktop platform
      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        // On desktop, show a dialog explaining camera limitations
        if (!mounted) return;
        _showDesktopCameraDialog();
        return;
      }

      // Camera is supported on mobile and web platforms
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (!mounted) return;
        
        if (kIsWeb) {
          // Web implementation - convert to bytes
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          // Mobile implementation
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
          });
        }
        _showSnackBar('Photo taken successfully!', isSuccess: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error taking photo: $e', isSuccess: false);
    }
  }

  void _showDesktopCameraDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Not Available'),
        content: const Text(
          'Camera capture is not available on desktop platforms. '
          'Please use the Gallery option to select a photo from your files.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImage(); // Automatically open gallery
            },
            child: const Text('Open Gallery'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    // Check if we're on desktop platform
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      // On desktop, only show gallery option
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Photo'),
          content: const Text(
            'Camera capture is not available on desktop platforms. '
            'Please select a photo from your gallery.',
          ),
          actions: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage();
              },
            ),
          ],
        ),
      );
    } else {
      // On mobile and web, show both options
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _isLoading = true; });
    
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    
    // Check for duplicate username
    if (AuthUtils.isUsernameTaken(provider, username)) {
      _showSnackBar('Username already exists. Please choose a different one.', isSuccess: false);
      setState(() { _isLoading = false; });
      return;
    }
    
    try {
      await AuthUtils.createUser(provider, username, password, name);
      
      if (mounted) {
        _showSnackBar('Account created successfully!', isSuccess: true);
        // Navigate directly to MainNavigation after successful signup
        AuthUtils.navigateToMainNavigation(context);
      }
    } catch (e) {
      _showSnackBar('Signup failed: $e', isSuccess: false);
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    _showTopNotification(context, message, isSuccess: isSuccess);
  }

  void _showTopNotification(BuildContext context, String message, {bool isSuccess = true}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        right: 10,
        left: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green[600] : Colors.red[600],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => overlayEntry.remove(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
              Color(0xFFf5576c),
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
                  // Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
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
                    'Join Day Care and start organizing your life',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Photo Upload Section
                  _buildPhotoSection(),
                  
                  const SizedBox(height: 40),
                  
                  // Form Container
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
                          // Full Name Field
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
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
                            validator: AuthUtils.validateName,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Username Field
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.account_circle, color: Colors.white70),
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
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: '4-Digit Password',
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
                              counterText: '',
                            ),
                            validator: AuthUtils.validatePassword,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
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
                              counterText: '',
                            ),
                            validator: (value) => AuthUtils.validateConfirmPassword(
                              value, 
                              _passwordController.text,
                            ),
                          ),
                  
                  const SizedBox(height: 30),
                  
                  // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signup,
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
                                      'Sign Up',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
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
            child: _buildImageWidget(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getPhotoStatusText(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    if (kIsWeb) {
      if (_webImage != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(58),
          child: Image.memory(
            _webImage!,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
          ),
        );
      }
    } else {
      if (_selectedImage != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(58),
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
          ),
        );
      }
    }
    
    return const Icon(
      Icons.add_a_photo,
      size: 50,
      color: Colors.white,
    );
  }

  String _getPhotoStatusText() {
    if (kIsWeb) {
      return ImageHelper.getImagePickerText(_webImage != null);
    } else {
      return ImageHelper.getImagePickerText(_selectedImage != null);
    }
  }
} 