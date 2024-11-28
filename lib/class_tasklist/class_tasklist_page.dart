import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tugaskuapp/submission_review/submission_review_page.dart';
import '../services/firebase_service.dart';
import '../submission/submission_page.dart';
import 'class_tasklist_view.dart';

class ClassTaskListPage extends StatefulWidget {
  final String role;
  final String email;
  final String classCode;
  final String className;

  const ClassTaskListPage({
    super.key,
    required this.role,
    required this.email,
    required this.classCode,
    required this.className,
  });

  @override
  State<ClassTaskListPage> createState() => _ClassTaskListPageState();
}

class _ClassTaskListPageState extends State<ClassTaskListPage> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic> updatedTask = {};
  Map<DateTime, List<Map<String, dynamic>>> _groupedTasks = {};
  String _getMonthName(int month) {
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
    return monthNames[month - 1];
  }

  String _getDayName(DateTime date) {
    const dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return dayNames[date.weekday - 1];
  }

  String _formatDateTime(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  DateTime _convertTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    throw Exception('Format timestamp tidak valid: $timestamp');
  }

  Map<DateTime, List<Map<String, dynamic>>> _groupTasksByDate(
      List<Map<String, dynamic>> tasks) {
    final groupedTasks = <DateTime, List<Map<String, dynamic>>>{};

    for (var task in tasks) {
      if (task['taskDeadline'] == null) continue;

      final taskDeadline = task['taskDeadline'];
      final dueDate =
          DateTime(taskDeadline.year, taskDeadline.month, taskDeadline.day);

      if (!groupedTasks.containsKey(dueDate)) {
        groupedTasks[dueDate] = [];
      }

      groupedTasks[dueDate]!.add({
        ...task,
        'dueDate': dueDate,
        'taskDeadline': _formatDateTime(taskDeadline),
      });
    }
    return groupedTasks;
  }

  Stream<List<Map<String, dynamic>>> _getTasks() {
    return _firebaseService.getTasks(classCode: widget.classCode).map((tasks) {
      return tasks.map((task) {
        task['taskDeadline'] = _convertTimestamp(task['taskDeadline']);
        return task;
      }).toList();
    });
  }

  void _onTap(Map<String, dynamic> task) async {
    final taskDetails = await _firebaseService.getTaskDetails(
      classCode: widget.classCode,
      taskId: task['id'],
    );
    if (widget.role == 'Guru') {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmissionReviewPage(
              classCode: widget.classCode,
              className: widget.className,
              email: widget.email,
              role: widget.role,
              taskDetails: taskDetails,
            ),
          ),
        );
      }
    } else if (widget.role == 'Siswa') {
      updatedTask = await _firebaseService.getTaskById(
        email: widget.email,
        classCode: widget.classCode,
        taskId: task['id'],
      );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmissionPage(
              email: widget.email,
              classCode: widget.classCode,
              task: updatedTask,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }

        final tasks = snapshot.data ?? [];
        _groupedTasks = _groupTasksByDate(tasks);

        return ClassTaskListView(
          role: widget.role,
          email: widget.email,
          classCode: widget.classCode,
          className: widget.className,
          tasks: tasks,
          groupedTasks: _groupedTasks,
          getMonthName: _getMonthName,
          getDayName: _getDayName,
          onTap: _onTap,
        );
      },
    );
  }
}
