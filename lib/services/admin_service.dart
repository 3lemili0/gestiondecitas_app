import 'package:dio/dio.dart';
import '../models/admin_models.dart';
import '../models/cita.dart';
import '../core/errors/api_exception.dart';
import 'api_client.dart';

class AdminService {
  final Dio _dio = ApiClient().dio;

  Future<ResumenAdmin> getResumen() async {
    try {
      final response = await _dio.get('/admin/resumen');
      return ResumenAdmin.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener el resumen.');
    }
  }

  Future<List<UsuarioAdmin>> getUsuarios({String? rol, String? buscar}) async {
    try {
      final params = <String, dynamic>{};
      if (rol != null) params['rol'] = rol;
      if (buscar != null && buscar.isNotEmpty) params['buscar'] = buscar;

      final response = await _dio.get('/admin/usuarios', queryParameters: params);
      return (response.data as List).map((e) => UsuarioAdmin.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener los usuarios.');
    }
  }

  Future<void> cambiarEstadoUsuario(String id, bool activo) async {
    try {
      await _dio.put('/admin/usuarios/$id/estado', data: {'activo': activo});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al actualizar el usuario.');
    }
  }

  Future<List<Cita>> getCitas({String? estado}) async {
    try {
      final params = <String, dynamic>{};
      if (estado != null) params['estado'] = estado;

      final response = await _dio.get('/admin/citas', queryParameters: params);
      return (response.data as List).map((e) => Cita.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener las citas.');
    }
  }

  Future<List<IncidenciaAdmin>> getIncidencias({String? estado}) async {
    try {
      final params = <String, dynamic>{};
      if (estado != null) params['estado'] = estado;

      final response = await _dio.get('/admin/incidencias', queryParameters: params);
      return (response.data as List).map((e) => IncidenciaAdmin.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al obtener las incidencias.');
    }
  }

  Future<void> cambiarEstadoIncidencia(String id, String estado) async {
    try {
      await _dio.put('/admin/incidencias/$id/estado', data: {'estado': estado});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al actualizar la incidencia.');
    }
  }
}