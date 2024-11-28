import 'package:flutter/material.dart';

import 'class_tasklist_add_page.dart';

class ClassTaskListView extends StatelessWidget {
  final String role;
  final String email;
  final String classCode;
  final String className;
  final List<Map<String, dynamic>> tasks;
  final Map<DateTime, List<Map<String, dynamic>>> groupedTasks;
  final Function(Map<String, dynamic>) onTap;
  final String Function(int) getMonthName;
  final String Function(DateTime) getDayName;

  const ClassTaskListView({
    super.key,
    required this.role,
    required this.email,
    required this.classCode,
    required this.className,
    required this.tasks,
    required this.groupedTasks,
    required this.onTap,
    required this.getMonthName,
    required this.getDayName,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: _buildListTask(context),
        ),
        if (role == 'Guru') _buildAddTaskButton(context),
      ],
    );
  }

  Widget _buildListTask(BuildContext context) {
    final sortedDates = groupedTasks.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final tasksForDate = groupedTasks[date]!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${date.day} ${getMonthName(date.month)} ${getDayName(date)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...tasksForDate.map(
                (task) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: () => onTap(task),
                    child: ListTile(
                      title: Text(
                        task['taskName'],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jatuh tempo: ${task['taskDeadline']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassTaskListAddPage(
              role: role,
              classCode: classCode,
              className: className,
              email: email,
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
