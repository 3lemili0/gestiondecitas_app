import 'package:dio/dio.dart';
import '../models/notificacion.dart';
import '../core/errors/api_exception.dart';
import 'api_client.dart';

class NotificacionService {
  final Dio _dio = ApiClient().dio;

  Future<List<Notificacion>> getMisNotificaciones() async {
    try {
      final response = await _dio.get('/notificaciones/mis-notificaciones');
      return (response.data as List).map((e) => Notificacion.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener las notificaciones.');
    }
  }

  Future<int> getContadorNoLeidas() async {
    try {
      final response = await _dio.get('/notificaciones/contador');
      return response.data['cantidad'] ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener el contador.');
    }
  }

  Future<void> marcarLeida(String id) async {
    try {
      await _dio.put('/notificaciones/$id/leer');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al marcar como leída.');
    }
  }

  Future<void> marcarTodasLeidas() async {
    try {
      await _dio.put('/notificaciones/marcar-todas-leidas');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al marcar todas como leídas.');
    }
  }
}