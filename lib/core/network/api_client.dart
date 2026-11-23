import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/config/app_config.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return ApiClient(storage: storage);
});

class ApiClient {
  final SecureStorageService _storage;
  late final Dio _dio;

  ApiClient({required SecureStorageService storage, Dio? customDio})
      : _storage = storage {
    _dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: AppConfig.current.apiBaseUrl,
            connectTimeout: Duration(milliseconds: AppConfig.current.connectTimeoutMs),
            receiveTimeout: Duration(milliseconds: AppConfig.current.receiveTimeoutMs),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'X-Client-Platform': Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Other'),
            },
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach stored token if available
          final token = await _storage.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Attach stored CodeIgniter session cookies
          final cookies = await _storage.getSessionCookies();
          if (cookies != null && cookies.isNotEmpty) {
            options.headers['Cookie'] = cookies;
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          // Extract and persist Set-Cookie from server response
          final setCookies = response.headers['set-cookie'];
          if (setCookies != null && setCookies.isNotEmpty) {
            final cookieHeader = setCookies.map((c) => c.split(';').first).join('; ');
            await _storage.saveSessionCookies(cookieHeader);

            for (final c in setCookies) {
              if (c.contains('ci_session=')) {
                final match = RegExp(r'ci_session=([^;]+)').firstMatch(c);
                if (match != null) {
                  await _storage.saveCiSession(match.group(1)!);
                }
              }
            }
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          final appException = _handleDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: appException,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  Dio get rawDio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw (e.error is AppException) ? e.error as AppException : _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw (e.error is AppException) ? e.error as AppException : _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw (e.error is AppException) ? e.error as AppException : _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw (e.error is AppException) ? e.error as AppException : _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException('Connection to WINCO servers timed out. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String errorMessage = 'A server error occurred. Please try again.';

        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'].toString();
        }

        if (statusCode == 401) {
          return UnauthorizedException(errorMessage);
        } else if (statusCode == 403) {
          return ForbiddenException(errorMessage);
        } else if (statusCode == 404) {
          return NotFoundException(errorMessage);
        } else if (statusCode == 422) {
          return ValidationException(errorMessage);
        } else {
          return ServerException(errorMessage, statusCode);
        }
      case DioExceptionType.cancel:
        return AppException('Request was cancelled.');
      default:
        return AppException('An unexpected network error occurred.');
    }
  }
}

