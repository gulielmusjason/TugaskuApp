import 'package:flutter/material.dart';

class NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool isAscending;
  final VoidCallback toggleSort;

  const NotificationAppBar({
    super.key,
    required this.isAscending,
    required this.toggleSort,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: ElevatedButton(
        onPressed: toggleSort,
        style: ElevatedButton.styleFrom(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(isAscending ? "Terlama" : "Terbaru"),
          ],
        ),
      ),
    );
  }
}

class NotificationMenuList extends StatelessWidget {
  final String notificationType;

  final String notificationMessage;
  final String notificationTime;
  final VoidCallback onTap;

  const NotificationMenuList({
    super.key,
    required this.notificationType,
    required this.notificationMessage,
    required this.notificationTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        child: Icon(
          _getNotificationIcon(notificationType),
          color: Colors.white,
        ),
      ),
      title: Text(
        notificationType,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        notificationMessage,
        style: theme.textTheme.bodyMedium,
      ),
      trailing: Text(
        notificationTime,
        style: theme.textTheme.bodySmall,
      ),
      onTap: () {},
    );
  }

  IconData _getNotificationIcon(String notificationType) {
    final IconData iconData = switch (notificationType) {
      'Kelas Dibuat' => Icons.school,
      'Anggota Baru' => Icons.person_add,
      'Tugas Baru' => Icons.assignment_turned_in,
      'Tugas Ditugaskan' => Icons.assignment_ind,
      'Tugas Diubah' => Icons.edit,
      'Tugas Dihapus' => Icons.delete,
      'Pengingat Tugas' => Icons.alarm,
      _ => Icons.notifications,
    };
    return iconData;
  }
}

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Terjadi kesalahan saat memuat notifikasi'),
    );
  }
}
