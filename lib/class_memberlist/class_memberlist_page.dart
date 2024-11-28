import 'package:flutter/material.dart';
import 'class_memberlist_view.dart';
import '../services/firebase_service.dart';

class MemberListPage extends StatefulWidget {
  final String role;
  final String classCode;
  final String className;

  const MemberListPage({
    super.key,
    required this.role,
    required this.classCode,
    required this.className,
  });

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _deleteMember({required String email}) async {
    await _firebaseService.removeMemberFromClass(
        classCode: widget.classCode, email: email);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getClassMembers(classCode: widget.classCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }

        final members = snapshot.data ?? [];

        return MemberListView(
          role: widget.role,
          classCode: widget.classCode,
          className: widget.className,
          members: members,
          deleteMember: (email) => _deleteMember(email: email),
        );
      },
    );
  }
}
