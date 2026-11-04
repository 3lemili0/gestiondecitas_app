import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../core/errors/api_exception.dart';
import '../services/auth_service.dart';

enum AuthStatus { desconocido, autenticado, noAutenticado }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Usuario? _usuario;
  AuthStatus _status = AuthStatus.desconocido;
  String? _error;
  bool _cargando = false;

  Usuario? get usuario => _usuario;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get cargando => _cargando;
  bool get isLoggedIn => _status == AuthStatus.autenticado;

  Future<void> verificarSesion() async {
    final logueado = await _authService.isLoggedIn();
    if (logueado) {
      _usuario = await _authService.obtenerUsuario();
      _status = AuthStatus.autenticado;
    } else {
      _status = AuthStatus.noAutenticado;
    }
    notifyListeners();
  }

  Future<bool> login(String correo, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authService.login(correo, password);
      _usuario = authResponse.usuario;
      _status = AuthStatus.autenticado;
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      _status = AuthStatus.noAutenticado;
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> registrar(Map<String, dynamic> datosUsuario) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.registrar(datosUsuario);
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarPerfil({
    String? nombre,
    String? apellido,
    String? telefono,
    String? profesion,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _usuario = await _authService.actualizarPerfil(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        profesion: profesion,
      );
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _usuario = null;
    _status = AuthStatus.noAutenticado;
    notifyListeners();
  }
}