import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/show_message.dart';
import 'class_memberlist_add_view.dart';

class MemberListAddPage extends StatefulWidget {
  final String classCode;
  const MemberListAddPage({super.key, required this.classCode});

  @override
  State<MemberListAddPage> createState() => _MemberListAddPageState();
}

class _MemberListAddPageState extends State<MemberListAddPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final ShowMessage _showMessage = ShowMessage();

  List<Map<String, dynamic>> _members = [];
  List<String> _selectedMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNonMembers();
  }

  Future<void> _fetchNonMembers() async {
    _members = await _firebaseService.getNonClassMembers(
      classCode: widget.classCode,
    );
    setState(() {
      _isLoading = false;
    });
  }

  void _onMembersChanged({required List<String> items}) {
    _selectedMembers = items;
  }

  Future<void> _addMembers({required List<Map<String, String>> members}) async {
    await _firebaseService.addMembersToClass(
        classCode: widget.classCode, members: members);
  }

  void _onAdd() {
    for (var member in _selectedMembers) {
      var memberData = _members.firstWhere(
        (m) => '${m['email']} (${m['role']})' == member,
        orElse: () => <String, dynamic>{},
      );
      if (memberData.isNotEmpty) {
        _addMembers(members: [
          {'email': memberData['email'], 'role': memberData['role']}
        ]);
      }
    }

    _showMessage.showMessage(
        context, '$_selectedMembers telah ditambahkan ke kelas');
    _selectedMembers.clear();
    Navigator.of(context).pop();
  }

  void _onCancel() {
    _selectedMembers.clear();
    Navigator.of(context).pop();
  }

  List<String> _getItems() {
    return _members
        .map((member) => '${member['email']} (${member['role']})')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return MemberListAddView(
      items: _getItems(),
      selectedMembers: _selectedMembers,
      onMembersChanged: (items) => _onMembersChanged(items: items),
      onAdd: _onAdd,
      onCancel: _onCancel,
    );
  }
}
