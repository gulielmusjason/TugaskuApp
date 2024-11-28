import 'package:flutter/material.dart';

class MainSettingView extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onSignOut;
  final bool isDarkMode;
  final VoidCallback onBack;
  final ThemeMode themeMode;
  final String Function(ThemeMode) getThemeText;
  final IconData Function(ThemeMode) getThemeIcon;

  const MainSettingView({
    super.key,
    required this.onToggleTheme,
    required this.onSignOut,
    required this.isDarkMode,
    required this.onBack,
    required this.themeMode,
    required this.getThemeText,
    required this.getThemeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Pengaturan'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Bagian Tampilan
          _buildSectionHeader(context, 'Tampilan'),
          _buildListTile(
            context,
            icon: getThemeIcon(themeMode),
            title: 'Tema',
            subtitle: getThemeText(themeMode),
            onTap: onToggleTheme,
          ),
          const Divider(height: 32),

          // Bagian Akun
          _buildSectionHeader(context, 'Akun'),
          _buildListTile(
            context,
            icon: Icons.logout,
            title: 'Keluar',
            subtitle: 'Keluar dari akun',
            onTap: () => _showSignOutConfirmation(context),
            iconColor: theme.colorScheme.error,
            textColor: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      Color? iconColor,
      Color? textColor,
      Widget? trailing}) {
    final theme = Theme.of(context);
    final defaultIconColor = theme.iconTheme.color;
    final defaultTextColor = theme.textTheme.bodyLarge?.color;

    return ListTile(
      leading: Icon(icon, color: iconColor ?? defaultIconColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? defaultTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color:
              (textColor ?? defaultTextColor)?.withAlpha((0.7 * 255).round()),
          fontSize: 14,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text(
          'Anda yakin ingin keluar dari akun?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              onSignOut();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
