import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugaskuapp/notification_menu/notification_menu_view.dart';
import 'notification_menu_widget.dart';
import '../services/firebase_service.dart';

class NotificationMenuPage extends StatefulWidget {
  final String username;
  final String email;
  final String role;

  const NotificationMenuPage({
    super.key,
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  State<NotificationMenuPage> createState() => _NotificationMenuPageState();
}

class _NotificationMenuPageState extends State<NotificationMenuPage> {
  bool isAscending = false;
  final FirebaseService _firebaseService = FirebaseService();

  void toggleSort() {
    setState(() {
      isAscending = !isAscending;
    });
  }

  String _formatTimestamp({required DateTime timestamp}) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes} menit yang lalu';
    }

    if (difference.inHours < 24 && now.day == timestamp.day) {
      return 'Hari ini ${DateFormat('HH:mm').format(timestamp)}';
    }

    if (difference.inDays < 2) {
      return 'Kemarin ${DateFormat('HH:mm').format(timestamp)}';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    }

    return DateFormat('dd MMM yyyy, HH:mm').format(timestamp);
  }

  List<Map<String, dynamic>> _processNotifications(
      List<Map<String, dynamic>> snapshot) {
    return snapshot.where((doc) {
      final data = doc;
      data['formattedTimestamp'] =
          _formatTimestamp(timestamp: data['createdAt'].toDate());
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NotificationAppBar(
        isAscending: isAscending,
        toggleSort: toggleSort,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firebaseService.getAllNotifications(
            ascending: isAscending, email: widget.email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ErrorMessage();
          }

          final notifications = _processNotifications(snapshot.data ?? []);

          return NotificationMenuView(
            notifications: notifications,
          );
        },
      ),
    );
  }
}
