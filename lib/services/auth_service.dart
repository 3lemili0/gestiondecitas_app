import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario.dart';
import '../core/errors/api_exception.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<AuthResponse> login(String correo, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'correo': correo,
        'password': password,
      });
      final authResponse = AuthResponse.fromJson(response.data);
      await _guardarSesion(authResponse);
      return authResponse;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al iniciar sesión.');
    }
  }

  Future<String> registrar(Map<String, dynamic> datosUsuario) async {
    try {
      final response = await _dio.post('/auth/registro', data: datosUsuario);
      return response.data['mensaje'] ?? 'Usuario registrado exitosamente.';
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al registrar usuario.');
    }
  }

  Future<Usuario> actualizarPerfil({
    String? nombre,
    String? apellido,
    String? telefono,
    String? profesion,
  }) async {
    try {
      final response = await _dio.put('/usuarios/perfil', data: {
        if (nombre != null) 'nombre': nombre,
        if (apellido != null) 'apellido': apellido,
        if (telefono != null) 'telefono': telefono,
        if (profesion != null) 'profesion': profesion,
      });
      final usuarioActualizado = Usuario.fromJson(response.data['usuario']);
      await _actualizarUsuarioGuardado(usuarioActualizado);
      return usuarioActualizado;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, mensajeDefault: 'Error al actualizar el perfil.');
    }
  }

  Future<void> _guardarSesion(AuthResponse authResponse) async {
    await _storage.write(key: 'authToken', value: authResponse.token);
    await _storage.write(
      key: 'usuario',
      value: jsonEncode(authResponse.usuario.toJson()),
    );
  }

  Future<void> _actualizarUsuarioGuardado(Usuario usuario) async {
    await _storage.write(key: 'usuario', value: jsonEncode(usuario.toJson()));
  }

  Future<String?> obtenerToken() async {
    return await _storage.read(key: 'authToken');
  }

  Future<Usuario?> obtenerUsuario() async {
    final usuarioJson = await _storage.read(key: 'usuario');
    if (usuarioJson == null) return null;
    return Usuario.fromJson(jsonDecode(usuarioJson));
  }

  Future<bool> isLoggedIn() async {
    final token = await obtenerToken();
    return token != null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'authToken');
    await _storage.delete(key: 'usuario');
  }
}