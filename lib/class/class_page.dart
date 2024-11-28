import 'package:flutter/material.dart';
import 'class_view.dart';
import '../class_setting/class_setting_page.dart';

class ClassPage extends StatefulWidget {
  final String role;
  final String email;
  final String className;
  final String classCode;

  const ClassPage({
    super.key,
    required this.role,
    required this.email,
    required this.className,
    required this.classCode,
  });

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _className;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _className = widget.className;
  }

  Future<void> _onSettingTap() async {
    final newClassName = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ClassSettingPage(
          className: _className,
          classCode: widget.classCode,
        ),
      ),
    );

    if (newClassName != null && mounted && newClassName != _className) {
      setState(() {
        _className = newClassName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClassView(
      role: widget.role,
      email: widget.email,
      className: _className,
      classCode: widget.classCode,
      tabController: _tabController,
      onSettingTap: _onSettingTap,
    );
  }
}
