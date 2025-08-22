import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  final cloudName = 'drdhrqd83';
  final uploadPreset = 'cfv_mobile';
  late Dio _dio;
  CloudinaryService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.cloudinary.com/v1_1/$cloudName',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );
  }

  Future<String> uploadImageFromPlatformFile(PlatformFile file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path!, filename: file.name),
      'upload_preset': uploadPreset,
    });

    try {
      final response = await _dio.post('/image/upload', data: formData);
      return response.data['secure_url'];
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return '';
    }
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initializeDio();
  }

  late Dio _dio;

  static const String baseUrl = 'https://cleanfoodapi-a3e7h6fgcuajf7cb.southeastasia-01.azurewebsites.net/api/v1';

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    // Add interceptors for logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, requestHeader: true, responseHeader: false, error: true),
      );
    }

    // Add error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint('API Error: ${error.message}');
          debugPrint('API Error Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  // Remove the separate initialize method since we initialize in constructor
  Dio get dio => _dio;

  // Generic GET request
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Handle Dio errors
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Kết nối timeout. Vui lòng thử lại.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Có lỗi xảy ra';
        return Exception('Lỗi $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Yêu cầu đã bị hủy');
      case DioExceptionType.connectionError:
        return Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
      default:
        return Exception('Có lỗi không xác định xảy ra');
    }
  }

  // Add authorization header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authorization header
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
