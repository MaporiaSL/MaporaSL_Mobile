import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/auth_api.dart';
import '../../../core/services/local_prefs.dart';
import '../../../core/constants/app_colors.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String name;
  final String? hometownDistrict;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.name,
    this.hometownDistrict,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  Timer? _pollTimer;
  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startVerificationPolling();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startVerificationPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkVerification();
    });
  }

  Future<void> _checkVerification() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      await _authService.reloadUser();
      if (_authService.isEmailVerified && mounted) {
        _pollTimer?.cancel();

        // Force token refresh so the backend gets a valid token with
        // email_verified=true, and so AuthGate's userChanges() stream fires.
        await _authService.currentUser?.getIdToken(true);

        // Resolve hometown: prefer explicit param, then local storage
        final district =
            widget.hometownDistrict ?? await LocalPrefs.getHometownDistrict();

        // Register user with backend after email verification
        try {
          if (district != null) {
            await AuthApi().registerUser(
              email: widget.email,
              name: widget.name,
              hometownDistrict: district,
            );
            // Clear cached district after successful registration
            await LocalPrefs.clearHometownDistrict();
          }
        } catch (e) {
          debugPrint('Backend register after verification failed: $e');
          // Backend sync will be retried by HomeScreen as fallback
        }
        if (!mounted) return;
        // Pop back to auth gate – userChanges() will pick up the verified user
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (_) {
      // Ignore reload errors
    } finally {
      _isChecking = false;
    }
  }

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendVerification() async {
    try {
      await _authService.sendEmailVerification();
      _startResendCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to resend. Please try again later.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    _pollTimer?.cancel();
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(onPressed: _handleSignOut, child: const Text('Cancel')),
        ],
      ),
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Click the link in the email to verify your account.\nThis page will update automatically.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Waiting for verification...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _checkVerification,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('I\'ve verified my email'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _canResend ? _resendVerification : null,
                  child: Text(
                    _canResend
                        ? 'Resend verification email'
                        : 'Resend in $_resendCountdown s',
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
