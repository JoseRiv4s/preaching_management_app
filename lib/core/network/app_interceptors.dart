import 'package:dio/dio.dart';
import '../error/app_exception.dart';

/// Loguea cada request y response en consola
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('➡️  [${options.method}] ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ [${response.statusCode}] ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ [${err.response?.statusCode}] ${err.requestOptions.uri}');
    handler.next(err);
  }
}

/// Transforma DioException en AppException tipada
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        const AppException('Tiempo de conexión agotado'),

      DioExceptionType.connectionError =>
        const AppException('Sin conexión a internet'),

      DioExceptionType.badResponse => AppException(
          _extractMessage(err.response),
          statusCode: err.response?.statusCode,
        ),

      _ => const AppException('Error inesperado'),
    };

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  String _extractMessage(Response? response) {
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ??
               data['error'] as String? ??
               'Error del servidor';
      }
    } catch (_) {}
    return 'Error del servidor (${response?.statusCode})';
  }
}