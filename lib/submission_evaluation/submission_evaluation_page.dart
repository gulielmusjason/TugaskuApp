import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/show_message.dart';
import 'submission_evaluation_view.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';

class SubmissionEvaluationPage extends StatefulWidget {
  final Map<String, dynamic> submission;

  const SubmissionEvaluationPage({
    super.key,
    required this.submission,
  });

  @override
  State<SubmissionEvaluationPage> createState() =>
      _SubmissionEvaluationPageState();
}

class _SubmissionEvaluationPageState extends State<SubmissionEvaluationPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final ShowMessage _showMessage = ShowMessage();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  bool _isSaving = false;
  Map<String, dynamic> _submission = {};

  @override
  void initState() {
    super.initState();
    _submission = widget.submission;

    if (_submission['score'] != null) {
      _scoreController.text = _submission['score'].toString();
    }
    if (_submission['feedback'] != null) {
      _feedbackController.text = _submission['feedback'];
    }
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

  Future<void> _handleSave() async {
    if (_isSaving) return;

    if (_scoreController.text.isEmpty) {
      _showMessage.showMessage(context, 'Nilai harus diisi');
      return;
    }

    final scoreNum = int.tryParse(_scoreController.text);
    if (scoreNum == null || scoreNum < 0 || scoreNum > 100) {
      _showMessage.showMessage(context, 'Nilai harus berupa angka 0-100');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _firebaseService.updateSubmissionEvaluation(
        taskId: _submission['taskId'],
        email: _submission['email'],
        score: int.tryParse(_scoreController.text) ?? 0,
        feedback: _feedbackController.text,
      );

      if (mounted) {
        _showMessage.showMessage(context, 'Penilaian berhasil disimpan');
        _handleRefresh();
      }
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal menyimpan penilaian: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleCancel() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firebaseService.cancelSubmissionEvaluation(
        taskId: _submission['taskId'],
        email: _submission['email'],
      );

      if (mounted) {
        _showMessage.showMessage(context, 'Penilaian berhasil dibatalkan');
        _handleRefresh();
      }
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal membatalkan penilaian: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _downloadAndOpenFile(String url) async {
    try {
      final dio = Dio();
      final downloadDir = '/storage/emulated/0/Download/Tugasku';

      final fileName =
          'Tugasku_${DateTime.now().millisecondsSinceEpoch}_${url.split('/').last}';
      final savePath = '$downloadDir/$fileName';

      await dio.download(
        url,
        savePath,
      );

      await OpenFile.open(savePath);
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal mengunduh file');
      }
    }
  }

  void _onBack() {
    Navigator.pop(context);
  }

  Future<void> _handleRefresh() async {
    try {
      final updatedSubmission =
          await _firebaseService.getSubmissionByEmailAndId(
        taskId: _submission['taskId'],
        email: _submission['email'],
      );
      if (mounted) {
        setState(() {
          _submission = updatedSubmission!;
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal memperbarui penilaian: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubmissionEvaluationView(
      onRefresh: _handleRefresh,
      submission: _submission,
      formatDateTime: _formatDateTime,
      onDownloadFile: _downloadAndOpenFile,
      onSave: _handleSave,
      onCancel: _handleCancel,
      onBack: _onBack,
      isSaving: _isSaving,
      scoreController: _scoreController,
      feedbackController: _feedbackController,
    );
  }
}
