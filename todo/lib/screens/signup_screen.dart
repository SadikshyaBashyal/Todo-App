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
// import '../widgets/lichal_front_page.dart';
import '../styles/app_styles.dart';
import '../widgets/auth_widgets.dart';
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
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
          _showSnackBar('Photo selected successfully!');
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
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
          });
          _showSnackBar('Photo selected successfully!');
        }
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      if (!ImageHelper.supportsCamera()) {
        // Web doesn't support camera directly, show message
        _showSnackBar('Camera not supported on web. Please use gallery.');
        return;
      }
      
      // Mobile/Desktop implementation
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _webImage = null;
        });
        _showSnackBar('Photo taken successfully!');
      }
    } catch (e) {
      _showSnackBar('Error taking photo: $e');
    }
  }

  void _showImageSourceDialog() {
    if (!ImageHelper.supportsCamera()) {
      // On web, only show gallery option
      _pickImage();
      return;
    }
    
    // On mobile/desktop, show both options
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

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _isLoading = true; });
    
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    
    // Check for duplicate username
    if (AuthUtils.isUsernameTaken(provider, username)) {
      _showSnackBar('Username already exists. Please choose a different one.');
      setState(() { _isLoading = false; });
      return;
    }
    
    try {
      await AuthUtils.createUser(provider, username, password, name);
      
      if (mounted) {
        // Navigate directly to MainNavigation after successful signup
        AuthUtils.navigateToMainNavigation(context);
      }
    } catch (e) {
      _showSnackBar('Signup failed: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: AppStyles.primaryBlue,
        foregroundColor: AppStyles.white,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppStyles.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Photo Upload Section
                  _buildPhotoSection(),
                  
                  const SizedBox(height: 30),
                  
                  // Form Fields
                  _buildFormFields(),
                  
                  const SizedBox(height: 30),
                  
                  // Sign Up Button
                  AuthWidgets.loadingButton(
                    onPressed: _signup,
                    text: 'Sign Up',
                    isLoading: _isLoading,
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
              color: AppStyles.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: AppStyles.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: _buildImageWidget(),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _getPhotoStatusText(),
          style: AppStyles.bodyStyle,
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
      color: AppStyles.white,
    );
  }

  String _getPhotoStatusText() {
    if (kIsWeb) {
      return ImageHelper.getImagePickerText(_webImage != null);
    } else {
      return ImageHelper.getImagePickerText(_selectedImage != null);
    }
  }

  Widget _buildFormFields() {
    return AuthWidgets.transparentContainer(
      child: Column(
        children: [
          AuthWidgets.styledTextFormField(
            controller: _nameController,
            labelText: 'Full Name',
            validator: AuthUtils.validateName,
          ),
          
          AuthWidgets.defaultSpacing,
          
          AuthWidgets.styledTextFormField(
            controller: _usernameController,
            labelText: 'Username',
            validator: AuthUtils.validateUsername,
          ),
          
          AuthWidgets.defaultSpacing,
          
          AuthWidgets.styledTextFormField(
            controller: _passwordController,
            labelText: '4-Digit Password',
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            validator: AuthUtils.validatePassword,
          ),
          
          AuthWidgets.defaultSpacing,
          
          AuthWidgets.styledTextFormField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            validator: (value) => AuthUtils.validateConfirmPassword(
              value, 
              _passwordController.text,
            ),
          ),
        ],
      ),
    );
  }
} 