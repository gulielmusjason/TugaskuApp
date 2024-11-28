import 'package:flutter/material.dart';

class MainAppView extends StatelessWidget {
  final int selectedIndex;
  final List<Widget> widgetOptions;
  final List<String> appBarTitle;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onSettingsTapped;
  final String username;
  final String email;
  final String role;

  const MainAppView({
    super.key,
    required this.selectedIndex,
    required this.widgetOptions,
    required this.appBarTitle,
    required this.onItemTapped,
    required this.onSettingsTapped,
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Center(
        child: widgetOptions[selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      title: Text(appBarTitle[selectedIndex]),
      leading: Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text(
                  username.substring(0, 2).toUpperCase(),
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(username),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text(
                  username.substring(0, 2).toUpperCase(),
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: onSettingsTapped,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.class_), label: "Kelas"),
        if (role == 'Siswa')
          const BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tugas"),
        const BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: "Notifikasi")
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
    );
  }
}
