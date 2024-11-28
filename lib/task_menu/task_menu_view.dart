import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskMenuView extends StatelessWidget {
  final TabController tabController;
  final List<Map<String, dynamic>> tasks;
  final Map<DateTime, List<Map<String, dynamic>>> groupedTasks;
  final String Function(DateTime, DateTime?) getTaskStatus;
  final String Function(DateTime, DateTime?) getTaskTabStatus;

  final Function(Map<String, dynamic>) onTaskTap;
  final int currentTabIndex;
  final String Function(Timestamp?) formatDateTime;
  final String Function(int) getMonthName;
  final String Function(DateTime) getDayName;
  final IconData Function(String) getClassIcon;

  final Future<void> Function() onRefresh;

  const TaskMenuView({
    super.key,
    required this.tabController,
    required this.tasks,
    required this.groupedTasks,
    required this.getTaskStatus,
    required this.getTaskTabStatus,
    required this.onTaskTap,
    required this.currentTabIndex,
    required this.formatDateTime,
    required this.getMonthName,
    required this.getDayName,
    required this.getClassIcon,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildRefreshableList(context, 'Mendatang'),
          _buildRefreshableList(context, 'Lewat Jatuh Tempo'),
          _buildRefreshableList(context, 'Selesai'),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: _buildTabButton(context, 'Mendatang', 0)),
            const SizedBox(width: 8),
            Expanded(child: _buildTabButton(context, 'Lewat Jatuh Tempo', 1)),
            const SizedBox(width: 8),
            Expanded(child: _buildTabButton(context, 'Selesai', 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String text, int index) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: tabController.index == index
              ? Theme.of(context).primaryColorDark
              : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(5),
        ),
        onPressed: () {
          tabController.animateTo(index);
        },
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, String status) {
    final sortedDates = groupedTasks.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final tasksForDate = groupedTasks[date]!;
        final filteredTasks = tasksForDate.where((task) {
          final taskStatus = getTaskTabStatus(
            task['taskDeadlineFormatted'],
            task['submittedAtFormatted'],
          );
          return taskStatus == status;
        }).toList();

        if (filteredTasks.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildTaskGroup(context, date, filteredTasks);
      },
    );
  }

  Widget _buildTaskGroup(
      BuildContext context, DateTime date, List<Map<String, dynamic>> tasks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${date.day} ${getMonthName(date.month)} ${getDayName(date)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ...tasks.map((task) => _buildTaskCard(context, task)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task) {
    final hasSubmission = task['submission'] != null;
    final taskStatus = getTaskStatus(
      task['taskDeadlineFormatted'],
      task['submittedAtFormatted'],
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => onTaskTap(task),
        child: ListTile(
          leading: Icon(
            getClassIcon(task['classCode']),
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            task['taskName'],
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task['className'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Jatuh tempo: ${formatDateTime(task['taskDeadline'])}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (hasSubmission && task['submission']['submittedAt'] != null)
                Text(
                  'Disubmit pada: ${formatDateTime(task['submission']['submittedAt'])}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              Text(
                taskStatus,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                  color: taskStatus == 'Telat' ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshableList(BuildContext context, String status) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: _buildTaskList(context, status),
    );
  }
}
