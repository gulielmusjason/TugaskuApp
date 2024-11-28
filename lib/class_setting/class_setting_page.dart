import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'class_setting_view.dart';
import '../services/firebase_service.dart';

import '../widgets/show_message.dart';

class ClassSettingPage extends StatefulWidget {
  final String className;
  final String classCode;

  const ClassSettingPage({
    super.key,
    required this.className,
    required this.classCode,
  });

  @override
  State<ClassSettingPage> createState() => _ClassSettingPageState();
}

class _ClassSettingPageState extends State<ClassSettingPage> {
  final FirebaseService _firebaseService = FirebaseService();

  final ShowMessage _showMessage = ShowMessage();
  final TextEditingController _controller = TextEditingController();
  bool _isUpdating = false;
  bool _isDeleting = false;
  late String _currentClassName;

  @override
  void initState() {
    super.initState();
    _currentClassName = widget.className;
    _controller.text = widget.className;
  }

  Future<void> _updateClassName() async {
    if (_controller.text.trim().isEmpty) {
      _showMessage.showMessage(context, 'Nama kelas tidak boleh kosong');
      return;
    }

    setState(() => _isUpdating = true);
    try {
      await _firebaseService.updateClassName(
        classCode: widget.classCode,
        newClassName: _controller.text,
      );
      if (!mounted) return;

      setState(() {
        _currentClassName = _controller.text;
      });

      _showMessage.showMessage(context, 'Nama kelas berhasil diubah');
      Navigator.pop(context, _controller.text);
    } catch (e) {
      if (!mounted) return;
      _showMessage.showMessage(context, e.toString());
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _onBack() {
    Navigator.pop(context, _currentClassName);
  }

  void _copyClassCode() {
    Clipboard.setData(ClipboardData(text: widget.classCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kode kelas berhasil disalin')),
    );
  }

  void _deleteClass() async {
    setState(() => _isDeleting = true);
    try {
      await _firebaseService.deleteClass(
        classCode: widget.classCode,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      _showMessage.showMessage(context, 'Kelas berhasil dihapus');
    } catch (e) {
      if (!mounted) return;
      _showMessage.showMessage(context, e.toString());
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClassSettingView(
      className: _currentClassName,
      classCode: widget.classCode,
      onBack: _onBack,
      onUpdateClassName: _updateClassName,
      onCopyClassCode: _copyClassCode,
      onDeleteClass: _deleteClass,
      controller: _controller,
      isUpdating: _isUpdating,
      isDeleting: _isDeleting,
    );
  }
}
