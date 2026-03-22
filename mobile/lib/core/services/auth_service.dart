import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRecentLoginRequiredException implements Exception {
  const AuthRecentLoginRequiredException();
}

class AuthReauthInteractiveRequiredException implements Exception {
  final String message;
  const AuthReauthInteractiveRequiredException(this.message);

  @override
  String toString() => message;
}

class AuthReauthUnsupportedProviderException implements Exception {
  final String message;
  const AuthReauthUnsupportedProviderException(this.message);

  @override
  String toString() => message;
}

class AuthReauthCancelledException implements Exception {
  final String message;
  const AuthReauthCancelledException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  String? get currentUserEmail => _auth.currentUser?.email;

  String? get currentUserDisplayName => _auth.currentUser?.displayName;

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken(forceRefresh);
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
    return credential;
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> requestEmailChange(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user is currently signed in.',
      );
    }
    try {
      await user.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthRecentLoginRequiredException();
      }
      rethrow;
    }
  }

  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user is currently signed in.',
      );
    }
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthRecentLoginRequiredException();
      }
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-cancelled',
        message: 'Google sign-in cancelled',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Re-authenticate the current user (requires recent sign-in).
  /// For Google providers, this re-opens Google sign-in and reauthenticates.
  /// For email/password providers, the caller should route the user through
  /// sign-out/sign-in or a dedicated credentials prompt flow.
  Future<void> reauthenticateUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user is currently signed in.',
      );
    }

    try {
      final providerIds = user.providerData
          .map((item) => item.providerId)
          .toSet();

      if (providerIds.contains(GoogleAuthProvider.PROVIDER_ID)) {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw const AuthReauthCancelledException(
            'Google sign-in was cancelled. Please try again.',
          );
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
        return;
      }

      if (providerIds.contains('password')) {
        throw const AuthReauthInteractiveRequiredException(
          'Please sign out and sign in again to complete this secure action.',
        );
      }

      throw const AuthReauthUnsupportedProviderException(
        'This sign-in provider does not support in-app re-auth here.',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthRecentLoginRequiredException();
      }
      rethrow;
    }
  }
}
