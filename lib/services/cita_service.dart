import 'package:dio/dio.dart';
import '../models/cita.dart';
import '../models/usuario.dart';
import '../core/errors/api_exception.dart';
import 'api_client.dart';

class CitaService {
  final Dio _dio = ApiClient().dio;

  Future<List<Cita>> getMisCitas() async {
    try {
      final response = await _dio.get('/citas/mis-citas');
      return (response.data as List).map((e) => Cita.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener las citas.');
    }
  }

  Future<List<Usuario>> getClientes() async {
    try {
      final response = await _dio.get('/usuarios/clientes');
      return (response.data as List).map((e) => Usuario.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener los clientes.');
    }
  }

  Future<void> reservarCita({
    required String profesionalId,
    required String fecha,
    required String motivo,
  }) async {
    try {
      await _dio.post('/citas/reservar', data: {
        'profesionalId': profesionalId,
        'fecha': fecha,
        'motivo': motivo,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al reservar la cita.');
    }
  }

  Future<void> crearCitaManual({
    required String clienteId,
    required String fecha,
    required String motivo,
  }) async {
    try {
      await _dio.post('/citas/crear-manual', data: {
        'clienteId': clienteId,
        'fecha': fecha,
        'motivo': motivo,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al crear la cita.');
    }
  }

  Future<void> actualizarCita({
    required String citaId,
    required String fecha,
    required String motivo,
  }) async {
    try {
      await _dio.put('/citas/$citaId', data: {
        'fecha': fecha,
        'motivo': motivo,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al actualizar la cita.');
    }
  }

  Future<void> cancelarCita(String citaId) async {
    try {
      await _dio.put('/citas/$citaId/cancelar');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al cancelar la cita.');
    }
  }

  Future<void> completarCita(String citaId) async {
    try {
      await _dio.put('/citas/$citaId/completar');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al completar la cita.');
    }
  }
}