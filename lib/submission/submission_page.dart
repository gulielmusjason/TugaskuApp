import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'submission_view.dart';
import '../services/cloudinary_service.dart';
import '../services/firebase_service.dart';
import '../widgets/show_message.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';

class SubmissionPage extends StatefulWidget {
  final String email;
  final String classCode;
  final Map<String, dynamic> task;

  const SubmissionPage({
    super.key,
    required this.email,
    required this.classCode,
    required this.task,
  });

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final ShowMessage _showMessage = ShowMessage();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  PlatformFile? _selectedFile;
  Map<String, dynamic> _task = {};
  bool _isSubmitting = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return '-';

    DateTime date = timestamp.toDate();

    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    return '${date.day} ${monthNames[date.month - 1]} ${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'mp4', 'mkv', 'zip'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
        if (mounted) {
          _showMessage.showMessage(context, 'File berhasil dipilih');
        }
      } else {
        if (mounted) {
          _showMessage.showMessage(context, 'Pemilihan file dibatalkan');
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal memilih file: $e');
      }
    }
  }

  Future<String?> _uploadToCloudinary() async {
    if (_selectedFile == null) return null;

    try {
      return await _cloudinaryService.uploadFile(
        file: _selectedFile!,
        folder:
            '${widget.classCode}/task/${_task['taskName']}/jawaban/${widget.email}',
      );
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal mengunggah file: $e');
      }
      return null;
    }
  }

  Future<void> _handleSave() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? fileUrl;
      if (_selectedFile != null) {
        if (mounted) {
          _showMessage.showMessage(context, 'Mengunggah file...');
        }
        fileUrl = await _uploadToCloudinary();
        if (fileUrl == null) {
          throw Exception('Gagal mengunggah file');
        }
      }

      await _firebaseService.submitTask(
        classCode: widget.classCode,
        taskId: _task['submission']['taskId'],
        email: widget.email,
        attachmentUrl: fileUrl,
      );

      if (mounted) {
        _showMessage.showMessage(context, 'Tugas berhasil dikumpulkan');
      }
      await _handleRefresh();
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal mengumpulkan tugas: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getSelectedFileName() {
    return _selectedFile?.name ?? 'Belum ada file dipilih';
  }

  Future<Map<String, dynamic>> _getTask() async {
    try {
      return await _firebaseService.getTaskById(
        email: widget.email,
        classCode: widget.classCode,
        taskId: widget.task['submission']['taskId'],
      );
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal mengambil tugas: $e');
      }
      rethrow;
    }
  }

  Future<void> _handleRefresh() async {
    try {
      final updatedTask = await _getTask();
      if (mounted) {
        setState(() {
          _task = updatedTask;
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal memperbarui tugas: $e');
      }
    }
  }

  Future<void> _handleCancel() async {
    if (_isCancelling) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      await _firebaseService.undoSubmission(
        classCode: _task['classCode'],
        taskId: _task['submission']['taskId'],
        email: widget.email,
      );

      if (mounted) {
        _showMessage.showMessage(context, 'Pengumpulan tugas dibatalkan');
      }
      await _handleRefresh();
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal membatalkan pengumpulan: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  void _handleBack() {
    Navigator.pop(context, 'updated');
  }

  Future<void> _downloadAndOpenFile(String url) async {
    try {
      final dio = Dio();
      final downloadDir = '/storage/emulated/0/Download/Tugasku';

      final fileName =
          'Tugasku_${DateTime.now().millisecondsSinceEpoch}_${url.split('/').last}';
      final savePath = '$downloadDir/$fileName';

      await dio.download(url, savePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File berhasil diunduh ke folder Download'),
            action: SnackBarAction(
              label: 'Buka',
              onPressed: () => OpenFile.open(savePath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengunduh file')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubmissionView(
      task: _task,
      formatDateTime: _formatDateTime,
      selectedFileName: _getSelectedFileName(),
      onSelectFile: _selectFile,
      onSave: _handleSave,
      onRefresh: _handleRefresh,
      onCancel: _handleCancel,
      onBack: _handleBack,
      isSubmitting: _isSubmitting,
      isCancelling: _isCancelling,
      onDownloadFile: _downloadAndOpenFile,
    );
  }
}
