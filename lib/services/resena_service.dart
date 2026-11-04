import 'package:dio/dio.dart';
import '../models/resena.dart';
import '../core/errors/api_exception.dart';
import 'api_client.dart';

class ResenaService {
  final Dio _dio = ApiClient().dio;

  Future<Resena> crearResena({
    required String citaId,
    required int calificacion,
    String? comentario,
  }) async {
    try {
      final response = await _dio.post('/resenas', data: {
        'citaId': citaId,
        'calificacion': calificacion,
        if (comentario != null && comentario.trim().isNotEmpty) 'comentario': comentario.trim(),
      });
      return Resena.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al enviar la calificación.');
    }
  }

  Future<EstadisticasDoctor> getEstadisticasDoctor(String doctorId) async {
    try {
      final response = await _dio.get('/resenas/doctor/$doctorId');
      return EstadisticasDoctor.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener las reseñas.');
    }
  }

  Future<bool> tieneResena(String citaId) async {
    try {
      final response = await _dio.get('/resenas/cita/$citaId');
      return response.data['tieneResena'] ?? false;
    } on DioException {
      return false;
    }
  }
}