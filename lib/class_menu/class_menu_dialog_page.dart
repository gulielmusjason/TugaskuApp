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
  bool _isLoading = false;
  bool _isAddingClass = false;

  // UI State Management
  void _setLoading(bool value) {
    if (mounted) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  void _setAddingClass(bool value) {
    if (mounted) {
      setState(() {
        _isAddingClass = value;
      });
    }
  }

  void _updateSelectedIcon(String? icon) {
    _selectedIcon = icon ?? 'class_';
  }

  // Generate class code
  String get classCode {
    return const Uuid().v4().substring(0, 6).toUpperCase();
  }

  // Class Operations
  Future<bool> handleAddClass({
    required String className,
    required String? classIconName,
  }) async {
    if (className.isEmpty) {
      _showMessage.showMessage(context, 'Mohon isi nama kelas');
      return false;
    }

    try {
      _setLoading(true);

      await _firebaseService.addClass(
        classCode: classCode,
        className: className,
        classIconName: classIconName,
        email: widget.email,
        role: widget.role,
      );
      if (mounted) {
        _showMessage.showMessage(context, 'Kelas berhasil dibuat');
        _fieldTambahKelas.clear();
      }
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(
            context, 'Gagal membuat kelas: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
    return true;
  }

  Future<void> _handleAddClassOnPressed() async {
    print('handleAddClassOnPressed');

    _setAddingClass(true);

    final isSuccess = await handleAddClass(
      className: _fieldTambahKelas.text,
      classIconName: _selectedIcon,
    );

    if (mounted && isSuccess) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }

    _setAddingClass(false);
  }

  Future<bool> _handleJoinClass({required String classCode}) async {
    if (classCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon masukkan kode kelas')),
      );
      return false;
    }

    try {
      await _firebaseService.joinClass(
        kodeKelas: classCode,
        email: widget.email,
        role: widget.role,
      );

      if (mounted) {
        _showMessage.showMessage(context, 'Berhasil bergabung ke kelas');
        return true;
      }
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Kode kelas tidak ditemukan');
      }
      return false;
    }
    return false;
  }

  Future<void> _handleJoinClassOnPressed(String classCode) async {
    final isSuccess = await _handleJoinClass(classCode: classCode);

    if (mounted && isSuccess) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  void _handleAddClassOnCancelPressed() {
    Navigator.of(context).pop();
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

  void _handleJoinClassOnCancelPressed() {
    Navigator.of(context).pop();
  }

  bool get isLoading => _isLoading || _isAddingClass;

  @override
  Widget build(BuildContext context) {
    return ClassMenuDialogView(
      role: widget.role,
      addClassController: _fieldTambahKelas,
      classAvailableIcons: _availableIcons,
      addClassSelectedIcon: _selectedIcon,
      addClassIsLoading: isLoading,
      addClassOnChanged: _updateSelectedIcon,
      addClassOnAddPressed: _handleAddClassOnPressed,
      addClassOnCancelPressed: _handleAddClassOnCancelPressed,
      onJoinClass: _handleJoinClassOnPressed,
      validateClassName: _validateClassName,
      validateClasscode: _validateClasscode,
      onJoinCancelPressed: _handleJoinClassOnCancelPressed,
    );
  }
}
