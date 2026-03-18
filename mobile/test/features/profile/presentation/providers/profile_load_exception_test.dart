import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';

void main() {
  DioException dioWithStatus(int statusCode) {
    return DioException(
      requestOptions: RequestOptions(path: '/api/profile/u1'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/profile/u1'),
        statusCode: statusCode,
      ),
      type: DioExceptionType.badResponse,
    );
  }

  test('maps 401 to expiredToken', () {
    final mapped = ProfileLoadException.fromDio(dioWithStatus(401));
    expect(mapped.type, ProfileLoadErrorType.expiredToken);
  });

  test('maps 403 to forbidden', () {
    final mapped = ProfileLoadException.fromDio(dioWithStatus(403));
    expect(mapped.type, ProfileLoadErrorType.forbidden);
  });

  test('maps 404 to userNotRegistered', () {
    final mapped = ProfileLoadException.fromDio(dioWithStatus(404));
    expect(mapped.type, ProfileLoadErrorType.userNotRegistered);
  });

  test('maps 409 to userNotRegistered', () {
    final mapped = ProfileLoadException.fromDio(dioWithStatus(409));
    expect(mapped.type, ProfileLoadErrorType.userNotRegistered);
  });

  test('maps offline SocketException to offline', () {
    final ex = DioException(
      requestOptions: RequestOptions(path: '/api/profile/u1'),
      type: DioExceptionType.connectionError,
      error: const SocketException('No internet'),
    );

    final mapped = ProfileLoadException.fromDio(ex);
    expect(mapped.type, ProfileLoadErrorType.offline);
  });

  test('maps timeout to offline', () {
    final ex = DioException(
      requestOptions: RequestOptions(path: '/api/profile/u1'),
      type: DioExceptionType.connectionTimeout,
    );

    final mapped = ProfileLoadException.fromDio(ex);
    expect(mapped.type, ProfileLoadErrorType.offline);
  });
}
