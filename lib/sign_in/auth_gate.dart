import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main_app/main_app_page.dart';
import 'sign_in_page.dart';
import '../widgets/loading_indicator_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Map<String, String>> _getUserData(String email) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(email).get();
      if (userDoc.exists) {
        String role = userDoc['role'] ?? 'user';
        String username = userDoc['username'] ?? 'User';
        return {'role': role, 'username': username};
      } else {
        return {'role': 'user', 'username': 'User'};
      }
    } catch (e) {
      return {'role': 'user', 'username': 'User'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicatorPage();
        } else if (snapshot.hasData) {
          User? user = snapshot.data;
          return FutureBuilder<Map<String, String>>(
            future: _getUserData(user!.email!),
            builder: (context, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicatorPage();
              } else if (dataSnapshot.hasError) {
                return const SignInPage();
              } else if (dataSnapshot.hasData) {
                return MainAppPage(
                  username: dataSnapshot.data!['username']!,
                  email: user.email ?? '',
                  role: dataSnapshot.data!['role']!,
                );
              } else {
                return const SignInPage();
              }
            },
          );
        } else {
          return const SignInPage();
        }
      },
    );
  }
}
