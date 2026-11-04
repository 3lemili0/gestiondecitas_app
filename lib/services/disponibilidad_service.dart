import 'package:dio/dio.dart';
import '../models/disponibilidad.dart';
import '../core/errors/api_exception.dart';
import 'api_client.dart';

class DisponibilidadService {
  final Dio _dio = ApiClient().dio;

  Future<List<Disponibilidad>> getMiDisponibilidad() async {
    try {
      final response = await _dio.get('/disponibilidad');
      return (response.data as List).map((e) => Disponibilidad.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener la disponibilidad.');
    }
  }

  Future<void> guardarDisponibilidad(Disponibilidad disponibilidad) async {
    try {
      await _dio.post('/disponibilidad', data: disponibilidad.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al guardar la disponibilidad.');
    }
  }
}