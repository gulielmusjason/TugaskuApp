import 'package:flutter/material.dart';
import 'class_menu_dialog_widget.dart';

class ClassMenuDialogView extends StatelessWidget {
  final String role;
  final TextEditingController addClassController;
  final List<String> classAvailableIcons;
  final String addClassSelectedIcon;
  final bool addClassIsLoading;
  final ValueChanged<String?> addClassOnChanged;
  final Future<void> Function() addClassOnAddPressed;
  final Function(String) onJoinClass;

  const ClassMenuDialogView({
    super.key,
    required this.role,
    required this.addClassController,
    required this.classAvailableIcons,
    required this.addClassSelectedIcon,
    required this.addClassIsLoading,
    required this.addClassOnChanged,
    required this.addClassOnAddPressed,
    required this.onJoinClass,
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddClassPage(
          addClassController: addClassController,
          classAvailableIcons: classAvailableIcons,
          addClassSelectedIcon: addClassSelectedIcon,
          addClassIsLoading: addClassIsLoading,
          addClassOnChanged: addClassOnChanged,
          addClassOnAddPressed: addClassOnAddPressed,
        ),
      ),
    );
  }

  void _showJoinClassDialog(BuildContext context) {
    Navigator.of(context).pop();
    JoinClassDialog(
      onJoin: onJoinClass,
    ).show(context);
  }
}
