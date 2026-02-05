import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ApiErrorHandler {
  ApiErrorHandler._();

  /// Wraps an async API call with standardized error handling.
  static Future<ApiResult<T>> call<T>(
    Future<T> Function() apiCall, {
    bool showError = true,
    String errorTitle = 'Error',
  }) async {
    try {
      final data = await apiCall();
      return ApiResult.success(data);
    } on DioException catch (e) {
      final message = _parseDioError(e);
      if (showError) {
        _showErrorSnackbar(errorTitle, message);
      }
      return ApiResult.failure(message);
    } catch (e) {
      final message = e.toString();
      if (showError) {
        _showErrorSnackbar(errorTitle, message);
      }
      return ApiResult.failure(message);
    }
  }

  static String resolve(Object error) {
    if (error is DioException) {
      return _parseDioError(error);
    }

    return 'Something went wrong. Please try again.';
  }

  /// Extracts error message from DioException (for manual usage).
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _parseDioError(error);
    }
    return error.toString();
  }

  static String _parseDioError(DioException error) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
        final fallback = data['error']?.toString();
        if (fallback != null && fallback.isNotEmpty) {
          return fallback;
        }
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
    }

    return _getDefaultErrorMessage(error);
  }

  static String _getDefaultErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timed out. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timed out. Please try again.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed.';
      case DioExceptionType.badResponse:
        return _getHttpErrorMessage(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'Network error. Check your connection.';
      case DioExceptionType.unknown:
        return error.message ?? 'Unexpected error. Please try again.';
    }
  }

  static String _getHttpErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Forbidden. You do not have access.';
      case 404:
        return 'Not found.';
      case 409:
        return 'Conflict. Please try again.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Request failed. Please try again.';
    }
  }

  static void _showErrorSnackbar(String title, String message) {
    void showSnackbar() {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => showSnackbar());
  }
}

class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResult._({this.data, this.error, required this.isSuccess});

  factory ApiResult.success(T data) => ApiResult._(data: data, isSuccess: true);

  factory ApiResult.failure(String error) =>
      ApiResult._(error: error, isSuccess: false);

  T dataOr(T fallback) => isSuccess && data != null ? data as T : fallback;
}
