import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/core/services/auth_interceptor.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockDio extends Mock implements Dio {}

class CaptureRequestHandler extends RequestInterceptorHandler {
  RequestOptions? captured;

  @override
  void next(RequestOptions requestOptions) {
    captured = requestOptions;
  }
}

class CaptureErrorHandler extends ErrorInterceptorHandler {
  DioException? forwarded;
  Response<dynamic>? resolved;

  @override
  void next(DioException err) {
    forwarded = err;
  }

  @override
  void resolve(Response<dynamic> response) {
    resolved = response;
  }
}

void main() {
  late MockFirebaseAuth auth;
  late MockUser user;
  late MockDio retryDio;

  setUp(() {
    auth = MockFirebaseAuth();
    user = MockUser();
    retryDio = MockDio();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken()).thenAnswer((_) async => 'access-token');
    when(
      () => user.getIdToken(true),
    ).thenAnswer((_) async => 'refreshed-token');
  });

  test('adds auth header in onRequest', () async {
    final interceptor = AuthInterceptor(auth: auth);
    final requestOptions = RequestOptions(path: '/api/profile/me');
    final handler = CaptureRequestHandler();

    interceptor.onRequest(requestOptions, handler);
    await Future<void>.delayed(Duration.zero);

    expect(handler.captured, isNotNull);
    expect(handler.captured!.headers['Authorization'], 'Bearer access-token');
  });

  test('retries once and resolves response for 401', () async {
    final interceptor = AuthInterceptor(auth: auth, retryDio: retryDio);
    final requestOptions = RequestOptions(path: '/api/profile/me');
    when(() => retryDio.fetch<dynamic>(any())).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 200,
        data: {'ok': true},
      ),
    );

    final error = DioException(
      requestOptions: requestOptions,
      response: Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );
    final handler = CaptureErrorHandler();

    interceptor.onError(error, handler);
    await Future<void>.delayed(Duration.zero);

    verify(() => user.getIdToken(true)).called(1);
    expect(requestOptions.extra['authRetryAttempted'], isTrue);
    expect(handler.resolved?.statusCode, 200);
    expect(handler.forwarded, isNull);
  });

  test('does not retry when request already retried', () async {
    final interceptor = AuthInterceptor(auth: auth);
    final requestOptions = RequestOptions(
      path: '/api/profile/me',
      extra: {'authRetryAttempted': true},
    );
    final error = DioException(
      requestOptions: requestOptions,
      response: Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );
    final handler = CaptureErrorHandler();

    interceptor.onError(error, handler);
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => user.getIdToken(true));
    expect(handler.forwarded, same(error));
    expect(handler.resolved, isNull);
  });

  test('fails gracefully when token refresh fails', () async {
    when(() => user.getIdToken(true)).thenThrow(Exception('refresh failed'));

    final interceptor = AuthInterceptor(auth: auth);
    final requestOptions = RequestOptions(path: '/api/profile/me');
    final error = DioException(
      requestOptions: requestOptions,
      response: Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );
    final handler = CaptureErrorHandler();

    interceptor.onError(error, handler);
    await Future<void>.delayed(Duration.zero);

    verify(() => user.getIdToken(true)).called(1);
    expect(handler.forwarded, same(error));
    expect(handler.resolved, isNull);
  });

  test('avoids retry loop when retry request also fails with 401', () async {
    final interceptor = AuthInterceptor(auth: auth, retryDio: retryDio);
    final requestOptions = RequestOptions(path: '/api/profile/me');
    when(() => retryDio.fetch<dynamic>(any())).thenThrow(
      DioException(
        requestOptions: requestOptions,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      ),
    );

    final error = DioException(
      requestOptions: requestOptions,
      response: Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );
    final handler = CaptureErrorHandler();

    interceptor.onError(error, handler);
    await Future<void>.delayed(const Duration(milliseconds: 1));

    verify(() => user.getIdToken(true)).called(1);
    expect(requestOptions.extra['authRetryAttempted'], isTrue);
    expect(handler.forwarded, same(error));
    expect(handler.resolved, isNull);
  });
}
