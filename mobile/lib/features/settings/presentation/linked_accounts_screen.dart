import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LinkedAccountsScreen extends StatefulWidget {
  const LinkedAccountsScreen({super.key});

  @override
  State<LinkedAccountsScreen> createState() => _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends State<LinkedAccountsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get _isGoogleLinked {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((provider) => provider.providerId == 'google.com');
  }

  void _clearMessages() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _handleLinkGoogle() async {
    _clearMessages();
    setState(() => _isLoading = true);

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User cancelled
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = _auth.currentUser;
      if (user != null) {
        await user.linkWithCredential(credential);
        setState(() {
          _successMessage = 'Google account linked successfully!';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        setState(() => _errorMessage = 'This Google account is already linked to another user.');
      } else {
        setState(() => _errorMessage = 'Failed to link Google account: ${e.message}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'An error occurred linking Google account: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUnlinkGoogle() async {
    _clearMessages();
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Prevent unlinking if it's the only provider (to avoid locking user out)
        if (user.providerData.length <= 1) {
          throw Exception('Cannot unlink the only sign-in method.');
        }

        await user.unlink('google.com');
        await _googleSignIn.signOut();
        setState(() {
          _successMessage = 'Google account unlinked successfully!';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to unlink Google account: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Linked Accounts'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),

              const Text(
                'Sign in Methods',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Link a social account to easily log in to your MaporiaSL account.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: SvgPicture.asset('assets/images/google_logo.svg', width: 24, height: 24),
                  ),
                  title: const Text('Google', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    _isGoogleLinked ? 'Linked' : 'Not linked',
                    style: TextStyle(
                      color: _isGoogleLinked ? Colors.green : Colors.grey,
                    ),
                  ),
                  trailing: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : OutlinedButton(
                          onPressed: _isGoogleLinked ? _handleUnlinkGoogle : _handleLinkGoogle,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _isGoogleLinked ? Colors.red : Colors.blue,
                            side: BorderSide(color: _isGoogleLinked ? Colors.red : Colors.blue),
                          ),
                          child: Text(_isGoogleLinked ? 'Unlink' : 'Link'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
