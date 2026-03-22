import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({FirebaseAuth? auth, Dio? retryDio})
    : _auth = auth ?? FirebaseAuth.instance,
      _retryDio = retryDio ?? Dio();

  final FirebaseAuth _auth;
  final Dio _retryDio;

  static const String _retryFlag = 'authRetryAttempted';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('>>> [AUTH INTERCEPTOR] Attached token for user: ${user.uid}');
        } else {
          debugPrint('>>> [AUTH INTERCEPTOR] Warning: getIdToken() returned empty/null');
        }
      } catch (e) {
        debugPrint('>>> [AUTH INTERCEPTOR] ERROR getting token: $e');
      }
    } else {
      debugPrint('>>> [AUTH INTERCEPTOR] Warning: No current Firebase user. Request sent without token.');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = requestOptions.extra[_retryFlag] == true;
    final user = _auth.currentUser;

    if (!isUnauthorized || alreadyRetried || user == null) {
      handler.next(err);
      return;
    }

    try {
      final freshToken = await user.getIdToken(true);
      requestOptions.headers['Authorization'] = 'Bearer $freshToken';
      requestOptions.extra[_retryFlag] = true;

      final retryResponse = await _retryDio.fetch<dynamic>(requestOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      handler.next(err);
    }
  }
}
