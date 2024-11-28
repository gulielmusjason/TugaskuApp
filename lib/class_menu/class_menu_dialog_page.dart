import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'class_menu_dialog_view.dart';
import '../services/firebase_service.dart';
import '../widgets/show_message.dart';

class ClassMenuDialogPage extends StatefulWidget {
  final String email;
  final String role;

  const ClassMenuDialogPage({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  State<ClassMenuDialogPage> createState() => _ClassMenuDialogPageState();
}

class _ClassMenuDialogPageState extends State<ClassMenuDialogPage> {
  // Services
  final ShowMessage _showMessage = ShowMessage();
  final FirebaseService _firebaseService = FirebaseService();

  // Controllers
  final TextEditingController _fieldTambahKelas = TextEditingController();

  // Constants
  static const List<String> _availableIcons = [
    'class_',
    'calculate',
    'book',
    'science',
    'public',
    'language',
    'sports_soccer',
    'music_note',
    'palette',
    'computer',
  ];

  // State variables
  String _selectedIcon = 'class_';

  void _updateSelectedIcon(String? icon) {
    _selectedIcon = icon ?? 'class_';
  }

  // Generate class code
  String get classCode {
    return const Uuid().v4().substring(0, 6).toUpperCase();
  }

  // Class Operations
  Future<bool> _handleAddClassOnPressed() async {
    try {
      await _firebaseService.addClass(
        classCode: classCode,
        className: _fieldTambahKelas.text,
        classIconName: _selectedIcon,
        email: widget.email,
        role: widget.role,
      );
      if (mounted) {
        _showMessage.showMessage(context, 'Kelas berhasil dibuat');
        _fieldTambahKelas.clear();
      }
      return true;
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(
            context, 'Gagal membuat kelas: ${e.toString()}');
      }
      return false;
    }
  }

  Future<bool> _handleJoinClassOnPressed(String classCode) async {
    try {
      await _firebaseService.joinClass(
        kodeKelas: classCode,
        email: widget.email,
        role: widget.role,
      );

      if (!mounted) return false;

      _showMessage.showMessage(context, 'Berhasil bergabung ke kelas');
      return true;
    } catch (e) {
      if (!mounted) return false;

      _showMessage.showMessage(context, 'Kode kelas tidak ditemukan');
      return false;
    }
  }

  String? _validateClassName(String value) {
    if (value.isEmpty) {
      return 'Nama kelas tidak boleh kosong';
    }
    return null;
  }

  String? _validateClasscode(String value) {
    if (value.isEmpty) {
      return 'Kode kelas tidak boleh kosong';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ClassMenuDialogView(
      role: widget.role,
      addClassController: _fieldTambahKelas,
      classAvailableIcons: _availableIcons,
      addClassSelectedIcon: _selectedIcon,
      addClassOnChanged: _updateSelectedIcon,
      addClassOnAddPressed: _handleAddClassOnPressed,
      onJoinClass: _handleJoinClassOnPressed,
      validateClassName: _validateClassName,
      validateClasscode: _validateClasscode,
    );
  }
}
