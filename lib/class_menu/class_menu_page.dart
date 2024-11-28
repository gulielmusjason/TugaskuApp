import 'package:flutter/material.dart';
import '../class/class_page.dart';
import 'class_menu_view.dart';
import '../services/firebase_service.dart';

class ClassMenuPage extends StatefulWidget {
  final String username;
  final String email;
  final String role;

  const ClassMenuPage({
    super.key,
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  State<ClassMenuPage> createState() => _ClassMenuPageState();
}

class _ClassMenuPageState extends State<ClassMenuPage> {
  // Services

  final FirebaseService _firebaseService = FirebaseService();

  // Navigation
  void _navigateToClass(
      {required String classCode, required String className}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ClassPage(
              classCode: classCode,
              className: className,
              role: widget.role,
              email: widget.email,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getAllClasses(email: widget.email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center();
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }

        final classes = snapshot.data ?? [];

        return ClassMenuView(
          userEmail: widget.email,
          onTapClass: (classCode, className) =>
              _navigateToClass(classCode: classCode, className: className),
          classes: classes,
          role: widget.role,
        );
      },
    );
  }
}
