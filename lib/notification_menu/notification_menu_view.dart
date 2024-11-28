import 'package:flutter/material.dart';
import 'notification_menu_widget.dart';

class NotificationMenuView extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  const NotificationMenuView({
    super.key,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return _buildNotificationList(context);
  }

  Widget _buildNotificationList(BuildContext context) {
    return notifications.isEmpty
        ? const Center(child: Text('Belum ada notifikasi'))
        : ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return NotificationMenuList(
                notificationType: notification['type'],
                notificationMessage: notification['message'],
                notificationTime: notification['formattedTimestamp'],
                onTap: () {},
              );
            },
          );
  }
}
