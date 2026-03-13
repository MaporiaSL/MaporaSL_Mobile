import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier();
});

class SecurityState {
  final bool isAppLockEnabled;
  final bool is2FAEnabled;
  final List<dynamic> activeSessions;
  final bool isLoading;
  final String? error;

  SecurityState({
    this.isAppLockEnabled = false,
    this.is2FAEnabled = false,
    this.activeSessions = const [],
    this.isLoading = false,
    this.error,
  });

  SecurityState copyWith({
    bool? isAppLockEnabled,
    bool? is2FAEnabled,
    List<dynamic>? activeSessions,
    bool? isLoading,
    String? error,
  }) {
    return SecurityState(
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
      activeSessions: activeSessions ?? this.activeSessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  final LocalAuthentication _auth = LocalAuthentication();
  late SharedPreferences _prefs;

  SecurityNotifier() : super(SecurityState()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final isAppLock = _prefs.getBool('security_app_lock_enabled') ?? false;
    state = state.copyWith(isAppLockEnabled: isAppLock);
  }

  Future<bool> checkBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock the app',
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleAppLock(bool value) async {
    if (value) {
      final authenticated = await authenticate();
      if (!authenticated) return;
    }
    
    await _prefs.setBool('security_app_lock_enabled', value);
    state = state.copyWith(isAppLockEnabled: value);
  }

  // --- Backend Integration (Placeholders for now) ---
  
  Future<void> fetchSessions() async {
    state = state.copyWith(isLoading: true);
    try {
      // Logic to call GET /api/security/sessions
      // Using placeholder data for initial UI implementation
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(
        activeSessions: [
          {'id': '1', 'device': 'iPhone 13', 'ip': '192.168.1.1', 'lastUsed': 'Just now'},
          {'id': '2', 'device': 'Samsung S22', 'ip': '10.0.0.5', 'lastUsed': '2 hours ago'},
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logoutAllDevices() async {
    state = state.copyWith(isLoading: true);
    try {
      // Logic to call POST /api/security/sessions/logout-all
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(activeSessions: [], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>?> setup2FA() async {
    try {
      // Logic to call POST /api/security/2fa/setup
      // Returns {qrCode, secret}
      return {
        'secret': 'JBSWY3DPEHPK3PXP',
        'qrCode': 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=otpauth://totp/Maporia:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Maporia'
      };
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> verifyAndEnable2FA(String token) async {
    try {
      // Logic to call POST /api/security/2fa/verify
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(is2FAEnabled: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> disable2FA() async {
    try {
      // Logic to call POST /api/security/2fa/disable
      state = state.copyWith(is2FAEnabled: false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
