import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;
  final String name;
  final String hometownDistrict;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.name,
    required this.hometownDistrict,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Verify Your Email',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'We\'ve sent a verification link to',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                Text(
                  email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}