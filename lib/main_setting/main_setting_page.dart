import 'package:flutter/material.dart';
import '../sign_in/sign_in_page.dart';
import 'main_setting_view.dart';
import '../services/firebase_service.dart';
import '../theme/theme_manager.dart';

class MainSettingPage extends StatefulWidget {
  final String username;
  final String email;

  const MainSettingPage({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  State<MainSettingPage> createState() => _MainSettingPageState();
}

class _MainSettingPageState extends State<MainSettingPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final ThemeManager _themeManager = ThemeManager();

  bool get _isDarkMode => _themeManager.isDarkMode;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleTheme() async {
    await _themeManager.toggleTheme();
    setState(() {});
  }

  void _onBack() {
    Navigator.pop(context);
  }

  Future<void> _signOut() async {
    await _firebaseService.signOutUser(email: widget.email);
    _navigateToSignIn();
  }

  void _navigateToSignIn() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInPage(),
      ),
    );
  }

  String getThemeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'Mengikuti Sistem';
      case ThemeMode.light:
        return 'Mode Terang';
      case ThemeMode.dark:
        return 'Mode Gelap';
    }
  }

  IconData getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = _themeManager.currentThemeMode;

    return MainSettingView(
      onBack: _onBack,
      onToggleTheme: _toggleTheme,
      onSignOut: _signOut,
      isDarkMode: _isDarkMode,
      themeMode: themeMode,
      getThemeText: getThemeText,
      getThemeIcon: getThemeIcon,
    );
  }
}
