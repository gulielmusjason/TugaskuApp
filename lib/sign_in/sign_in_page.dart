import 'package:flutter/material.dart';
import '../main_app/main_app_page.dart';
import '../sign_up/sign_up_page.dart';
import 'sign_in_view.dart';
import '../widgets/error_custom_dialog.dart';
import '../services/firebase_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State
  bool _passwordVisible = true;
  bool _isLoading = false;

  // Keys & Services
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ErrorCustomDialog errorCustomDialog = ErrorCustomDialog();
  final FirebaseService _firebaseService = FirebaseService();

  // UI Event Handlers
  void _onPasswordVisibilityToggle() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _clearFields() {
    setState(() {
      _emailController.clear();
      _passwordController.clear();
      formKey.currentState?.reset();
    });
  }

  // Validation
  String? _validator({String? value}) {
    // Empty field validation
    if (value == "Email" && _emailController.text.isEmpty ||
        value == "Kata Sandi" && _passwordController.text.isEmpty) {
      return '$value tidak boleh kosong';
    }

    // Email format validation
    if (value == "Email" &&
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // Error Handling
  void _showErrorDialog({required String message}) {
    errorCustomDialog.showError(context, message: message);
  }

  // Authentication
  Future<void> _signIn() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _firebaseService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (result['success']) {
          _handleSuccessfulSignIn(result: result);
        } else {
          _showErrorDialog(message: result['message']);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _handleSuccessfulSignIn({required Map<String, dynamic> result}) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainAppPage(
            username: result['username'],
            email: result['email'],
            role: result['role'],
          ),
        ),
      );
    }
  }

  // Navigation
  void _onSignInPressed() {
    _signIn();
  }

  void _onSignUpPressed() {
    _clearFields();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignInView(
      emailController: _emailController,
      passwordController: _passwordController,
      passwordVisible: _passwordVisible,
      onPasswordVisibilityToggle: _onPasswordVisibilityToggle,
      validator: (value) => _validator(value: value),
      onSignInPressed: _onSignInPressed,
      onSignUpPressed: _onSignUpPressed,
      formKey: formKey,
      isLoading: _isLoading,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
