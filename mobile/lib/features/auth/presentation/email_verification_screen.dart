import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
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
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {

  final _authService = AuthService();

  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    await _authService.sendEmailVerification();
    _startResendCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(widget.email),

            const SizedBox(height: 20),

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
    );
  }
}