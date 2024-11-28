import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../sign_in/sign_in_page.dart';
import '../widgets/error_custom_dialog.dart';
import 'sign_up_view.dart';
import '../widgets/show_message.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Keys & Services
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ErrorCustomDialog _errorCustomDialog = ErrorCustomDialog();
  final FirebaseService _firebaseService = FirebaseService();
  final ShowMessage _showMessage = ShowMessage();
  // State
  String _selectedRole = '';
  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;
  bool _isLoading = false;

  // UI Event Handlers
  void _onRoleChanged({String? role}) {
    _selectedRole = role ?? '';
  }

  void _onPasswordVisibilityToggle() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _onConfirmPasswordVisibilityToggle() {
    setState(() {
      _confirmPasswordVisible = !_confirmPasswordVisible;
    });
  }

  // Validation
  String? _validator({String? value}) {
    // Empty field validation
    if (_isEmptyField(value: value)) {
      return '$value tidak boleh kosong';
    }

    // Email format validation
    if (_isInvalidEmail(value: value)) {
      return 'Format email tidak valid';
    }

    // Password match validation
    if (_isPasswordMismatch(value: value)) {
      return 'Kata Sandi tidak sama';
    }
    return null;
  }

  bool _isEmptyField({String? value}) {
    return (value == "Nama" && _nameController.text.isEmpty) ||
        (value == "Email" && _emailController.text.isEmpty) ||
        (value == "Role" && _selectedRole.isEmpty) ||
        (value == "Kata Sandi" && _passwordController.text.isEmpty) ||
        (value == "Konfirmasi Kata Sandi" &&
            _confirmPasswordController.text.isEmpty);
  }

  bool _isInvalidEmail({String? value}) {
    return value == "Email" &&
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text);
  }

  bool _isPasswordMismatch({String? value}) {
    return value == "Konfirmasi Kata Sandi" &&
        _passwordController.text != _confirmPasswordController.text;
  }

  // Error Handling
  void _showErrorDialog({required String message}) {
    _errorCustomDialog.showError(context, message: message);
  }

  // Authentication
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String result = await _firebaseService.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      username: _nameController.text,
      role: _selectedRole,
    );

    setState(() {
      _isLoading = false;
    });

    _handleSignUpResult(result: result);
  }

  void _handleSignUpResult({required String result}) {
    if (result == 'success') {
      _showMessage.showMessage(context, 'Pendaftaran berhasil');
      _navigateToSignIn();
    } else {
      _showErrorDialog(message: result);
    }
  }

  // Navigation
  void _navigateToSignIn() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  void _onSignUpPressed() {
    _signUp();
  }

  @override
  Widget build(BuildContext context) {
    return SignUpView(
      nameController: _nameController,
      emailController: _emailController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      passwordVisible: _passwordVisible,
      confirmPasswordVisible: _confirmPasswordVisible,
      onPasswordVisibilityToggle: _onPasswordVisibilityToggle,
      validator: (value) => _validator(value: value),
      onConfirmPasswordVisibilityToggle: _onConfirmPasswordVisibilityToggle,
      onSignUpPressed: _onSignUpPressed,
      formKey: _formKey,
      onRoleChanged: (role) => _onRoleChanged(role: role),
      isLoading: _isLoading,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
