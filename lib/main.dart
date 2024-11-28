import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tugaskuapp/services/firebase_options.dart';
import 'sign_in/auth_gate.dart';
import 'theme/theme.dart';
import 'theme/theme_manager.dart';
import 'package:workmanager/workmanager.dart';
import 'services/firebase_service.dart';

// Background task handler untuk pengecekan deadline tugas
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final firebaseService = FirebaseService();
      await firebaseService.checkAndSendTaskReminders();
      return true;
    } catch (e) {
      return false;
    }
  });
}

// Kelas untuk menginisialisasi komponen aplikasi
class AppInitializer {
  static Future<void> initialize() async {
    await _initializeCore();
    await _initializeWorkManager();
    await _initializePushNotifications();
  }

  static Future<void> _initializeCore() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<void> _initializeWorkManager() async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      'taskReminderChecker',
      'checkDeadlines',
      frequency: Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> _initializePushNotifications() async {
    await FirebaseMessaging.instance.requestPermission();
  }
}

Future<void> main() async {
  await AppInitializer.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager().themeNotifier,
      builder: (_, ThemeMode themeMode, __) {
        return MaterialApp(
          title: 'Tugasku',
          debugShowCheckedModeBanner: false,
          theme: AppTheme().lightTheme,
          darkTheme: AppTheme().darkTheme,
          themeMode: themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}
