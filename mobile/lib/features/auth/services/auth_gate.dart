import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../home/presentation/home_screen.dart';
import '../presentation/login_screen.dart';
import '../presentation/email_verification_screen.dart';
import '../../profile/presentation/first_time_profile_setup_screen.dart';
import '../../profile/presentation/providers/profile_providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

        final setupState = ref.watch(profileSetupRequirementProvider);
        return setupState.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) {
            if (error is DioException && error.response?.statusCode == 401) {
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }
            return const Scaffold(
              body: Center(child: Text('Preparing your account...')),
            );
          },
          data: (requirement) {
            if (requirement.requiresSetup) {
              return FirstTimeProfileSetupScreen(
                requiredFields: requirement.requiredFields,
                optionalFields: requirement.optionalFields,
              );
            }
            return const HomeScreen();
          },
        );
      },
    );
  }
}
