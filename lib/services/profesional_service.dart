import 'package:dio/dio.dart';
import '../models/usuario.dart';
import '../core/errors/api_exception.dart';
import 'api_client.dart';

class ProfesionalService {
  final Dio _dio = ApiClient().dio;

  Future<List<Usuario>> getProfesionales() async {
    try {
      final response = await _dio.get('/profesionales');
      return (response.data as List).map((e) => Usuario.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener los profesionales.');
    }
  }

  Future<List<String>> getDisponibilidad(String profesionalId, String fecha) async {
    try {
      final response = await _dio.get(
        '/profesionales/$profesionalId/disponibilidad',
        queryParameters: {'fecha': fecha},
      );
      return List<String>.from(response.data['horariosDisponibles'] ?? []);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener la disponibilidad.');
    }
  }
}