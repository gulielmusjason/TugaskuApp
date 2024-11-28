import 'package:flutter/material.dart';
import 'package:tugaskuapp/class_menu/class_menu_dialog_page.dart';
import 'package:tugaskuapp/class_menu/class_menu_widget.dart';

class ClassMenuView extends StatelessWidget {
  final String userEmail;
  final Function(String, String) onTapClass;
  final List<Map<String, dynamic>> classes;
  final String role;

  const ClassMenuView({
    super.key,
    required this.userEmail,
    required this.onTapClass,
    required this.classes,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 6),
        child: classes.isEmpty
            ? const Center(child: Text('Tidak ada kelas'))
            : _buildClassList(),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildClassList() {
    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classMenu = classes[index];
        return ClassMenuCard(
          classIconName: classMenu['classIconName'],
          className: classMenu['className'],
          onTap: () => onTapClass(
            classMenu['classCode'],
            classMenu['className'],
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ClassMenuDialogPage(
              email: userEmail,
              role: role,
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
