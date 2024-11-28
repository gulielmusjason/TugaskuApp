import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tugaskuapp/task_menu/task_menu_view.dart';
import 'package:tugaskuapp/services/firebase_service.dart';

import '../submission/submission_page.dart';

class TaskMenuPage extends StatefulWidget {
  final String email;
  const TaskMenuPage({super.key, required this.email});

  @override
  State<TaskMenuPage> createState() => _TaskMenuPageState();
}

class _TaskMenuPageState extends State<TaskMenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _tasks = [];

  Map<DateTime, List<Map<String, dynamic>>> _groupedTasks = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _handleRefresh();
  }

  Future<void> _handleRefresh() async {
    if (!mounted) return;
    final tasks =
        await _firebaseService.getTasksByEmail(email: widget.email).first;
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _groupedTasks = groupTasksByDate(_tasks);
    });
    return Future.delayed(const Duration(milliseconds: 100));
  }

  void _handleTaskTap(Map<String, dynamic> task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmissionPage(
          email: widget.email,
          classCode: task['classCode'],
          task: task,
        ),
      ),
    );

    if (result == 'updated') {
      await _handleRefresh();
    }
  }

  IconData _getIcon(String iconName) {
    final IconData iconData = switch (iconName) {
      'class_' => Icons.class_,
      'calculate' => Icons.calculate,
      'book' => Icons.book,
      'science' => Icons.science,
      'public' => Icons.public,
      'language' => Icons.language,
      'sports_soccer' => Icons.sports_soccer,
      'music_note' => Icons.music_note,
      'palette' => Icons.palette,
      'computer' => Icons.computer,
      _ => Icons.class_
    };

    return iconData;
  }

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

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return '-';

    DateTime date = timestamp.toDate();
    return '${date.day} ${_getMonthName(date.month)} ${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Map<DateTime, List<Map<String, dynamic>>> groupTasksByDate(
      List<Map<String, dynamic>> tasks) {
    final groupedTasks = <DateTime, List<Map<String, dynamic>>>{};

    for (var task in tasks) {
      final taskDeadline = (task['taskDeadline'] as Timestamp).toDate();
      final taskCloseDeadline =
          (task['taskCloseDeadline'] as Timestamp).toDate();
      final dueDate =
          DateTime(taskDeadline.year, taskDeadline.month, taskDeadline.day);

      if (!groupedTasks.containsKey(dueDate)) {
        groupedTasks[dueDate] = [];
      }

      final submissionData = task['submission'];
      final submittedAt =
          submissionData != null && submissionData['submittedAt'] != null
              ? (submissionData['submittedAt'] as Timestamp).toDate()
              : null;

      final taskWithStatus = {
        ...task,
        'taskCloseDeadlineFormatted': taskCloseDeadline,
        'taskDeadlineFormatted': taskDeadline,
        'submittedAtFormatted': submittedAt,
      };

      groupedTasks[dueDate]!.add(taskWithStatus);
    }
    return groupedTasks;
  }

  String getTaskTabStatus(DateTime dueDate, DateTime? submittedAt) {
    final now = DateTime.now();
    if (submittedAt != null) {
      return 'Selesai';
    } else if (now.isAfter(dueDate)) {
      return 'Lewat Jatuh Tempo';
    } else {
      return 'Mendatang';
    }
  }

  String getTaskStatus(DateTime dueDate, DateTime? submittedAt) {
    final now = DateTime.now();
    if (submittedAt != null) {
      return submittedAt.isAfter(dueDate) ? 'Telat' : 'Selesai';
    } else if (now.isAfter(dueDate)) {
      return 'Lewat Jatuh Tempo';
    } else {
      return 'Mendatang';
    }
  }

  void _onTabChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getTasksByEmail(email: widget.email),
      builder: (context, snapshot) {
        if (snapshot.hasData && mounted) {
          _tasks = snapshot.data!;
          _groupedTasks = groupTasksByDate(_tasks);
        }
        return TaskMenuView(
          tabController: _tabController,
          tasks: _tasks,
          groupedTasks: _groupedTasks,
          getTaskStatus: getTaskStatus,
          getTaskTabStatus: getTaskTabStatus,
          onTaskTap: _handleTaskTap,
          currentTabIndex: _tabController.index,
          formatDateTime: _formatDateTime,
          getMonthName: _getMonthName,
          getDayName: _getDayName,
          getClassIcon: _getIcon,
          onRefresh: _handleRefresh,
        );
      },
    );
  }
}
