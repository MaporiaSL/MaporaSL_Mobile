import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/config/app_config.dart';
import '../../home/presentation/home_screen.dart';
import '../presentation/login_screen.dart';
import '../presentation/email_verification_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // userChanges() fires on emailVerified, displayName, token refreshes etc.
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          if (kDebugMode && AppConfig.authBypass) {
            return const HomeScreen();
          }
          return const LoginScreen();
        }

        // If user signed up via email/password and hasn't verified yet
        if (!user.emailVerified &&
            user.providerData.any((p) => p.providerId == 'password')) {
          // hometownDistrict is read from local storage inside
          // EmailVerificationScreen — no hardcoded fallback needed.
          return EmailVerificationScreen(
            email: user.email ?? '',
            name: user.displayName ?? '',
          );
        }

        return const HomeScreen();
      },
    );
  }
}
