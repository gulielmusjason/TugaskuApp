import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> keepLoginInfo({
    required String username,
    required String email,
    required String role,
  }) async {
    final prefs = await _prefs;
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
  }

  Future<Map<String, String?>> getLoginInfo() async {
    final prefs = await _prefs;
    final username = prefs.getString('username');
    final email = prefs.getString('email');
    final role = prefs.getString('role');

    return {
      'username': username,
      'email': email,
      'role': role,
    };
  }
}
