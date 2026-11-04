import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;

  ApiException(this.mensaje, {this.statusCode});

  @override
  String toString() => mensaje;

  /// Traduce un DioException a un ApiException con un mensaje claro para el usuario.
  factory ApiException.fromDioException(DioException e, {String? mensajeDefault}) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'El servidor está iniciando, esto puede tardar unos segundos. Intenta de nuevo.',
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'No hay conexión con el servidor. Verifica tu internet e intenta de nuevo.',
        );
      case DioExceptionType.badResponse:
        final mensajeBackend = e.response?.data is Map
            ? e.response?.data['mensaje']
            : null;
        return ApiException(
          mensajeBackend ?? mensajeDefault ?? 'Ocurrió un error inesperado.',
          statusCode: e.response?.statusCode,
        );
      default:
        return ApiException(mensajeDefault ?? 'Ocurrió un error inesperado.');
    }
  }
}