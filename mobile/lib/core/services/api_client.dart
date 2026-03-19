import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient({Dio? dio})
    : dio =
          dio ??
                Dio(
                  BaseOptions(
                    baseUrl: AppConfig.apiBaseUrl,
                    connectTimeout: const Duration(seconds: 10),
                    receiveTimeout: const Duration(seconds: 10),
                  ),
                )
            ..interceptors.add(AuthInterceptor())
            ..interceptors.add(InterceptorsWrapper(
              onRequest: (options, handler) {
                debugPrint('>>> [API CLIENT DIO] REQUEST TO: ${options.uri.toString()}');
                return handler.next(options);
              },
              onResponse: (response, handler) {
                debugPrint('>>> [API CLIENT DIO] RESPONSE: ${response.statusCode}');
                return handler.next(response);
              },
              onError: (DioException e, handler) {
                debugPrint('>>> [API CLIENT DIO] ERROR: ${e.response?.statusCode} AT ${e.requestOptions.uri.toString()}');
                debugPrint('>>> [API CLIENT DIO] ERROR DATA: ${e.response?.data}');
                return handler.next(e);
              }
            ));

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

