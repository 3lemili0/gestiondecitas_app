import 'package:dio/dio.dart';
import '../models/incidencia.dart';
import '../core/errors/api_exception.dart';
import 'api_client.dart';

class IncidenciaService {
  final Dio _dio = ApiClient().dio;

  Future<List<Incidencia>> getMisIncidencias() async {
    try {
      final response = await _dio.get('/incidencias/mis-incidencias');
      return (response.data as List).map((e) => Incidencia.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener las incidencias.');
    }
  }

  Future<Incidencia> crearIncidencia({
    required String tipo,
    required String asunto,
    required String descripcion,
    String? citaId,
  }) async {
    try {
      final response = await _dio.post('/incidencias', data: {
        'tipo': tipo,
        'asunto': asunto,
        'descripcion': descripcion,
        if (citaId != null) 'citaId': citaId,
      });
      return Incidencia.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al crear la incidencia.');
    }
  }

  Future<Incidencia> actualizarEstado(String id, String estado) async {
    try {
      final response = await _dio.put('/incidencias/$id/estado', data: {'estado': estado});
      return Incidencia.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al actualizar el estado.');
    }
  }
}