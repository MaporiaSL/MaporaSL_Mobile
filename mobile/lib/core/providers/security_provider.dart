import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';

final securityProvider =
    StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
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
  final ApiClient _apiClient = ApiClient();
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

  // --- Backend Integration ---

  Future<void> fetchSessions() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.get('/api/security/sessions');
      final data = response.data as Map<String, dynamic>;
      final sessions = (data['sessions'] as List<dynamic>).map((s) {
        // Normalise the session document fields for display
        return {
          'id': s['_id']?.toString() ?? '',
          'device': s['device'] ?? 'Unknown Device',
          'ip': s['ipAddress'] ?? s['ip'] ?? 'Unknown IP',
          'lastUsed': _formatDate(s['lastUsedAt']?.toString()),
        };
      }).toList();
      state = state.copyWith(activeSessions: sessions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logoutAllDevices() async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiClient.post('/api/security/sessions/logout-all');
      state = state.copyWith(activeSessions: [], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>?> setup2FA() async {
    try {
      final response = await _apiClient.post('/api/security/2fa/setup');
      final data = response.data as Map<String, dynamic>;
      return {
        'secret': data['secret'],
        'qrCode': data['qrCode'],
      };
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> verifyAndEnable2FA(String token) async {
    try {
      await _apiClient.post('/api/security/2fa/verify', data: {'token': token});
      state = state.copyWith(is2FAEnabled: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> disable2FA() async {
    try {
      await _apiClient.post('/api/security/2fa/disable');
      state = state.copyWith(is2FAEnabled: false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // --- Helpers ---

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'Unknown';
    }
  }
}
