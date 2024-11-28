import 'package:flutter/material.dart';
import '../class_menu/class_menu_page.dart';
import '../main_setting/main_setting_page.dart';
import '../notification_menu/notification_menu_page.dart';
import '../task_menu/task_menu_page.dart';
import 'main_app_view.dart';

class MainAppPage extends StatefulWidget {
  final String username;
  final String email;
  final String role;

  const MainAppPage({
    super.key,
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  late List<String> _appBarTitles;

  @override
  void initState() {
    super.initState();
    _initializeWidgets();
  }

  void _initializeWidgets() {
    if (widget.role == 'Guru') {
      _initTeacherWidgets();
    } else {
      _initStudentWidgets();
    }
  }

  void _initTeacherWidgets() {
    _widgetOptions = [
      _buildClassMenuPage(),
      _buildNotificationPage(),
    ];
    _appBarTitles = ['Kelas', 'Notifikasi'];
  }

  void _initStudentWidgets() {
    _widgetOptions = [
      _buildClassMenuPage(),
      TaskMenuPage(email: widget.email),
      _buildNotificationPage(),
    ];
    _appBarTitles = ['Kelas', 'Tugas', 'Notifikasi'];
  }

  Widget _buildClassMenuPage() {
    return ClassMenuPage(
        username: widget.username, email: widget.email, role: widget.role);
  }

  Widget _buildNotificationPage() {
    return NotificationMenuPage(
        username: widget.username, email: widget.email, role: widget.role);
  }

  void _onItemTapped({required int index}) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSettingsTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainSettingPage(
          username: widget.username,
          email: widget.email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainAppView(
      selectedIndex: _selectedIndex,
      widgetOptions: _widgetOptions,
      appBarTitle: _appBarTitles,
      onItemTapped: (index) => _onItemTapped(index: index),
      onSettingsTapped: _onSettingsTapped,
      username: widget.username,
      email: widget.email,
      role: widget.role,
    );
  }
}
