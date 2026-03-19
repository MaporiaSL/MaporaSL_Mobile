import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../home/presentation/home_screen.dart';
import '../presentation/login_screen.dart';
import '../presentation/email_verification_screen.dart';
import '../../profile/presentation/first_time_profile_setup_screen.dart';
import '../../profile/presentation/providers/profile_providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({
    super.key,
    this.loginBuilder,
    this.homeBuilder,
    this.setupBuilder,
  });

  final Widget Function()? loginBuilder;
  final Widget Function()? homeBuilder;
  final Widget Function(
    List<String> requiredFields,
    List<String> optionalFields,
  )?
  setupBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          if (kDebugMode && AppConfig.authBypass) {
            return homeBuilder?.call() ?? const HomeScreen();
          }
          return loginBuilder?.call() ?? const LoginScreen();
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

        final guardState = ref.watch(coreNavigationGuardProvider);
        return guardState.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, __) {
            return const Scaffold(body: Center(child: Text('Preparing your account...')));
          },
          data: (guard) {
            if (guard.requiresSignIn) {
              authService.signOut();
              return loginBuilder?.call() ?? const LoginScreen();
            }

            if (guard.requiresSetup) {
              return setupBuilder?.call(
                    guard.requiredFields,
                    guard.optionalFields,
                  ) ??
                  FirstTimeProfileSetupScreen(
                    requiredFields: guard.requiredFields,
                    optionalFields: guard.optionalFields,
                  );
            }

            if (!guard.isAllowed) {
              return Scaffold(
                body: Center(
                  child: Text(guard.message ?? 'Preparing your account...'),
                ),
              );
            }

            return homeBuilder?.call() ?? const HomeScreen();
          },
        );
      },
    );
  }
}
