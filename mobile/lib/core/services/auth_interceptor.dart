import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken();
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('✅ Auth token added to request');
      } catch (e) {
        debugPrint('❌ Error fetching Firebase token: $e');
      }
    } else {
      debugPrint(
        '⚠️ No Firebase user logged in - request will be unauthenticated',
      );
    }
    return handler.next(options);
  }
}
