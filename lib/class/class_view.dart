import 'package:flutter/material.dart';
import '../class_memberlist/class_memberlist_page.dart';
import '../class_tasklist/class_tasklist_page.dart';

class ClassView extends StatefulWidget {
  final String role;
  final String email;
  final String classCode;
  final String className;
  final TabController tabController;
  final VoidCallback onSettingTap;

  const ClassView({
    super.key,
    required this.role,
    required this.email,
    required this.classCode,
    required this.className,
    required this.tabController,
    required this.onSettingTap,
  });

  @override
  State<ClassView> createState() => _ClassViewState();
}

class _ClassViewState extends State<ClassView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildTabBarView(context),
      backgroundColor: theme.scaffoldBackgroundColor,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        widget.className,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: theme.appBarTheme.titleTextStyle?.color,
        ),
      ),
      elevation: 2,
      backgroundColor: theme.appBarTheme.backgroundColor,
      actions: widget.role == 'Guru'
          ? [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                onSelected: (value) {
                  if (value == 'settings') {
                    widget.onSettingTap();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings,
                            color: theme.iconTheme.color, size: 20),
                        const SizedBox(width: 8),
                        Text('Pengaturan',
                            style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color)),
                      ],
                    ),
                  ),
                ],
              ),
            ]
          : [],
      bottom: TabBar(
        controller: _tabController,
        labelColor: theme.tabBarTheme.labelColor,
        unselectedLabelColor: theme.tabBarTheme.unselectedLabelColor,
        indicatorColor: theme.tabBarTheme.indicatorColor,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.assignment),
            text: 'Tugas',
          ),
          Tab(
            icon: Icon(Icons.people),
            text: 'Anggota',
          ),
        ],
      ),
    );
  }

  TabBarView _buildTabBarView(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        ClassTaskListPage(
          role: widget.role,
          email: widget.email,
          classCode: widget.classCode,
          className: widget.className,
        ),
        MemberListPage(
          role: widget.role,
          classCode: widget.classCode,
          className: widget.className,
        ),
      ],
    );
  }
}
