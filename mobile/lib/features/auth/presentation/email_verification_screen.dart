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
  Timer? _resendTimer;

  bool _canResend = false;
  int _resendCountdown = 60;
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

        await _authService.currentUser?.getIdToken(true);

        final district =
            widget.hometownDistrict ?? await LocalPrefs.getHometownDistrict();

        try {
          if (district != null) {
            await AuthApi().registerUser(
              email: widget.email,
              name: widget.name,
              hometownDistrict: district,
            );

            await LocalPrefs.clearHometownDistrict();
          }
        } catch (_) {}

        if (!mounted) return;

        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (_) {} finally {
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
            content: Text('Verification email resent'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {}
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _handleSignOut,
            child: const Text("Cancel"),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// ICON
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFE9F1FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 56,
                  color: Color(0xFF2D6CDF),
                ),
              ),

              const SizedBox(height: 32),

              /// TITLE
              Text(
                "Verify your email",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              /// DESCRIPTION
              Text(
                "We've sent a verification link to",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
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
                "Click the link in the email to verify your account.\nThis page will update automatically.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              /// LOADING
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),

              const SizedBox(height: 12),

              Text(
                "Waiting for verification...",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 36),

              /// VERIFIED BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6CDF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "I've verified my email",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// RESEND
              TextButton(
                onPressed: _canResend ? _resendVerification : null,
                child: Text(
                  _canResend
                      ? "Resend verification email"
                      : "Resend in $_resendCountdown s",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}