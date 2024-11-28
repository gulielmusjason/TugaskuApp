import 'package:flutter/material.dart';

class ClassSettingView extends StatelessWidget {
  final String className;
  final String classCode;
  final VoidCallback onCopyClassCode;
  final VoidCallback onUpdateClassName;
  final VoidCallback onDeleteClass;
  final TextEditingController controller;
  final bool isUpdating;
  final bool isDeleting;
  final VoidCallback onBack;

  const ClassSettingView({
    super.key,
    required this.className,
    required this.classCode,
    required this.onCopyClassCode,
    required this.onUpdateClassName,
    required this.onDeleteClass,
    required this.controller,
    required this.isUpdating,
    required this.isDeleting,
    required this.onBack,
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

          // Bagian Informasi Kelas
          _buildSectionHeader(context, 'Informasi Kelas'),
          _buildListTile(
            context,
            icon: Icons.edit,
            title: 'Nama Kelas',
            subtitle: className,
            onTap: () => _showEditClassNameDialog(context),
          ),
          _buildListTile(
            context,
            icon: Icons.key,
            title: 'Kode Kelas',
            subtitle: classCode,
            onTap: onCopyClassCode,
            trailing: Icon(Icons.copy, size: 20, color: theme.iconTheme.color),
          ),
          const Divider(height: 32),

          // Bagian Tindakan
          _buildSectionHeader(context, 'Tindakan'),
          _buildListTile(
            context,
            icon: Icons.delete_outline,
            title: 'Hapus Kelas',
            subtitle: 'Tindakan ini tidak dapat dibatalkan',
            onTap: () => _showDeleteConfirmation(context),
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

  void _showEditClassNameDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama Kelas'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama Kelas Baru',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: isUpdating ? null : onUpdateClassName,
            child: isUpdating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary),
                    ),
                  )
                : const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kelas'),
        content: const Text(
          'Anda yakin ingin menghapus kelas ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: isDeleting
                ? null
                : () {
                    onDeleteClass();
                    Navigator.pop(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: isDeleting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onError),
                    ),
                  )
                : const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
