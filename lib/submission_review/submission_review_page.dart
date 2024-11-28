import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:tugaskuapp/class_tasklist/class_tasklist_add_page.dart';
import '../submission_evaluation/submission_evaluation_page.dart';
import 'submission_review_view.dart';
import '../services/firebase_service.dart';
import '../widgets/show_message.dart';

class SubmissionReviewPage extends StatefulWidget {
  final String role;
  final String classCode;
  final String className;
  final String email;
  final Map<String, dynamic> taskDetails;

  const SubmissionReviewPage({
    super.key,
    required this.role,
    required this.classCode,
    required this.className,
    required this.email,
    required this.taskDetails,
  });

  @override
  State<SubmissionReviewPage> createState() => _SubmissionReviewPageState();
}

class _SubmissionReviewPageState extends State<SubmissionReviewPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, String>> members = [];
  late Map<String, dynamic> taskDetails;
  final ShowMessage _showMessage = ShowMessage();
  @override
  void initState() {
    super.initState();
    taskDetails = widget.taskDetails;
  }

  // Memformat tanggal ke string yang mudah dibaca
  String formatDateTime(DateTime date) {
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

  // Menghapus tugas
  Future<void> _deleteTask() async {
    try {
      await _firebaseService.deleteTask(
        classCode: widget.classCode,
        taskId: taskDetails['id'],
      );
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        _showMessage.showMessage(context, 'Tugas berhasil dihapus');
      }
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal menghapus tugas');
      }
    }
  }

  Future<void> _downloadFile(BuildContext context, String url) async {
    try {
      final dio = Dio();
      final downloadDir = '/storage/emulated/0/Download/Tugasku';

      final fileName =
          'Tugasku_${DateTime.now().millisecondsSinceEpoch}_${url.split('/').last}';
      final savePath = '$downloadDir/$fileName';

      await dio.download(url, savePath);

      if (context.mounted) {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengunduh file')),
        );
      }
    }
  }

  void _onTapSubmittedMember(Map<String, dynamic> member) async {
    final submission = await _firebaseService.getSubmissionByEmailAndId(
      email: member['email'],
      taskId: widget.taskDetails['id'],
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubmissionEvaluationPage(
            submission: submission!,
          ),
        ),
      );
    }
  }

  Future<void> _editTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ClassTaskListAddPage(
                classCode: widget.classCode,
                className: widget.className,
                email: widget.email,
                role: widget.role,
                existingTask: taskDetails,
              )),
    );
    if (result == 'updateTask') {
      await _handleRefresh();
    }
  }

  Future<void> _handleRefresh() async {
    final taskDetails = await _firebaseService.getTaskDetails(
      classCode: widget.classCode,
      taskId: widget.taskDetails['id'],
    );
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      this.taskDetails = taskDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getSubmittedTaskMembers(
        classCode: widget.classCode,
        taskId: widget.taskDetails['id'],
      ),
      builder: (context, submittedSnapshot) {
        if (submittedSnapshot.hasError) {
          return Center(child: Text('Error: ${submittedSnapshot.error}'));
        }

        if (!submittedSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final submittedMembers = submittedSnapshot.data ?? [];

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firebaseService.getNotSubmittedTaskMembers(
            classCode: widget.classCode,
            taskId: widget.taskDetails['id'],
          ),
          builder: (context, notSubmittedSnapshot) {
            if (notSubmittedSnapshot.hasError) {
              return Center(
                  child: Text('Error: ${notSubmittedSnapshot.error}'));
            }

            if (!notSubmittedSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final notSubmittedMembers = notSubmittedSnapshot.data ?? [];

            return SubmissionReviewView(
              className: widget.className,
              taskDetails: taskDetails,
              onRefresh: _handleRefresh,
              submittedMembers: submittedMembers,
              notSubmittedMembers: notSubmittedMembers,
              onDeleteTask: _deleteTask,
              formatDateTime: formatDateTime,
              onDownloadFile: (fileName) => _downloadFile(context, fileName),
              onTapSubmittedMember: _onTapSubmittedMember,
              onEditTask: _editTask,
            );
          },
        );
      },
    );
  }
}
