import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
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

        final setupState = ref.watch(profileSetupRequirementProvider);
        return setupState.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) {
            if (error is DioException && error.response?.statusCode == 401) {
              authService.signOut();
              return loginBuilder?.call() ?? const LoginScreen();
            }
            return const Scaffold(
              body: Center(child: Text('Preparing your account...')),
            );
          },
          data: (requirement) {
            if (requirement.requiresSetup) {
              return setupBuilder?.call(
                    requirement.requiredFields,
                    requirement.optionalFields,
                  ) ??
                  FirstTimeProfileSetupScreen(
                    requiredFields: requirement.requiredFields,
                    optionalFields: requirement.optionalFields,
                  );
            }
            return homeBuilder?.call() ?? const HomeScreen();
          },
        );
      },
    );
  }
}
