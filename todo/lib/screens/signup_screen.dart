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
import '../models/user.dart';
import 'home_screen.dart';

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
    setState(() { _isLoading = true; });
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    // Check for duplicate username
    if (provider.users.any((u) => u.username == username)) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final user = AppUser(
      username: username,
      password: password,
      name: name,
      photoPath: null, // Add photo logic if needed
    );
    await provider.addUser(user);
    await provider.setCurrentUser(username);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
    setState(() { _isLoading = false; });
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
        backgroundColor: const Color.fromARGB(255, 28, 70, 238),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 28, 70, 238),
              Color.fromARGB(255, 51, 135, 208),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                  _buildSignUpButton(),
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
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: _buildImageWidget(),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _getPhotoStatusText(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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

  Widget _buildFormFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              if (value.length < 3) {
                return 'Username must be at least 3 characters';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            maxLength: 4,
            validator: (value) {
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
            },
            decoration: InputDecoration(
              labelText: '4-Digit Password',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            maxLength: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color.fromARGB(255, 28, 70, 238),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
} 