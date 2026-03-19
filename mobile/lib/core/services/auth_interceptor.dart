import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  final Dio _retryDio = Dio();

  static const String _retryFlag = 'authRetryAttempted';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      options.headers['Authorization'] = 'Bearer $token';
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
