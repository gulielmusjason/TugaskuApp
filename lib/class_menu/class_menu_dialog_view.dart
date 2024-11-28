import 'package:flutter/material.dart';
import 'class_menu_dialog_widget.dart';

class ClassMenuDialogView extends StatelessWidget {
  final String role;
  final TextEditingController addClassController;
  final List<String> classAvailableIcons;
  final String addClassSelectedIcon;

  final ValueChanged<String?> addClassOnChanged;
  final Future<bool> Function() addClassOnAddPressed;

  final Function(String) validateClassName;
  final Future<bool> Function(String) onJoinClass;
  final Function(String) validateClasscode;

  const ClassMenuDialogView({
    super.key,
    required this.role,
    required this.addClassController,
    required this.classAvailableIcons,
    required this.addClassSelectedIcon,
    required this.addClassOnChanged,
    required this.addClassOnAddPressed,
    required this.onJoinClass,
    required this.validateClassName,
    required this.validateClasscode,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Aksi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (role == 'Guru')
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Tambah Kelas'),
                onTap: () {
                  _showAddClassDialog(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Gabung Kelas'),
              onTap: () {
                _showJoinClassDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddClassPage(
          addClassController: addClassController,
          classAvailableIcons: classAvailableIcons,
          addClassSelectedIcon: addClassSelectedIcon,
          addClassOnChanged: addClassOnChanged,
          addClassOnAddPressed: addClassOnAddPressed,
          validateClassName: validateClassName,
        ),
      ),
    );
  }

  void _showJoinClassDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => JoinClassDialog(
        onJoin: onJoinClass,
        validateClasscode: validateClasscode,
      ),
    );
  }
}
