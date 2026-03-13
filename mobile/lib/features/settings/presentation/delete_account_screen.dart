import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/api_client.dart';
import '../../auth/presentation/login_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _authService = AuthService();
  final _apiClient = ApiClient();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDeleteAccount() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('No authenticated user found.');

      // 1. Delete user from Backend MongoDB API
      final response = await _apiClient.delete('/api/users/${user.uid}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete data from backend: ${response.data}');
      }

      // 2. Delete user from Firebase Auth
      await user.delete();
      await _authService.signOut();

      if (mounted) {
        // Navigate all the way back to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        setState(() => _errorMessage = 'For security reasons, please log out and log back in before deleting your account.');
      } else {
        setState(() => _errorMessage = 'Failed to delete account. $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Final Confirmation', style: TextStyle(color: Colors.red)),
          content: const Text(
            'This action is IRREVERSIBLE. All your gameplay stats, visits, and photos will be permanently deleted and cannot be recovered.\n\nAre you absolutely sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleDeleteAccount();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes, Delete Everything', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.red),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'We\'re sorry to see you go',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'If you delete your account, your data will be permanently erased. This includes:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Card(
                elevation: 0,
                color: Color(0xFFFFF0F0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Your profile information and avatar', style: TextStyle(color: Colors.redAccent)),
                      SizedBox(height: 8),
                      Text('• Game progress, unlocked districts, and XP', style: TextStyle(color: Colors.redAccent)),
                      SizedBox(height: 8),
                      Text('• All recorded visits and photos', style: TextStyle(color: Colors.redAccent)),
                      SizedBox(height: 8),
                      Text('• Linked Google authentication', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _showDeleteConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.delete_forever, color: Colors.white),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Delete My Account',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 55,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Cancel, keep my account', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
