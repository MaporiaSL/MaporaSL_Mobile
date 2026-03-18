import 'package:flutter/material.dart';
<<<<<<< Updated upstream
<<<<<<< Updated upstream
import 'package:flutter/foundation.dart';
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/config/app_config.dart';
import '../../home/presentation/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
          if (kDebugMode && AppConfig.authBypass) {
=======
          if (AppConfig.authBypass) {
>>>>>>> Stashed changes
=======
          if (AppConfig.authBypass) {
>>>>>>> Stashed changes
            return const HomeScreen();
          }
          return const LoginScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
