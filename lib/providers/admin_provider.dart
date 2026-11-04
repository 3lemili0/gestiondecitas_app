import 'package:flutter/foundation.dart';
import '../models/admin_models.dart';
import '../models/cita.dart';
import '../core/errors/api_exception.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  ResumenAdmin? _resumen;
  bool _cargandoResumen = false;
  String? _errorResumen;

  List<UsuarioAdmin> _usuarios = [];
  bool _cargandoUsuarios = false;
  String? _errorUsuarios;

  List<IncidenciaAdmin> _incidencias = [];
  bool _cargandoIncidencias = false;
  String? _errorIncidencias;
  String? _filtroIncidencias;

  List<Cita> _citas = [];
  bool _cargandoCitas = false;
  String? _errorCitas;

  // Errores de acciones puntuales (activar/desactivar, cambiar estado)
  String? _errorAccion;

  ResumenAdmin? get resumen => _resumen;
  bool get cargandoResumen => _cargandoResumen;
  String? get errorResumen => _errorResumen;

  List<UsuarioAdmin> get usuarios => _usuarios;
  bool get cargandoUsuarios => _cargandoUsuarios;
  String? get errorUsuarios => _errorUsuarios;

  List<IncidenciaAdmin> get incidencias => _incidencias;
  bool get cargandoIncidencias => _cargandoIncidencias;
  String? get errorIncidencias => _errorIncidencias;

  List<Cita> get citas => _citas;
  bool get cargandoCitas => _cargandoCitas;
  String? get errorCitas => _errorCitas;

  String? get errorAccion => _errorAccion;

  Future<void> cargarResumen() async {
    _cargandoResumen = true;
    _errorResumen = null;
    notifyListeners();
    try {
      _resumen = await _service.getResumen();
    } on ApiException catch (e) {
      _errorResumen = e.mensaje;
    } finally {
      _cargandoResumen = false;
      notifyListeners();
    }
  }

  Future<void> cargarUsuarios({String? rol, String? buscar}) async {
    _cargandoUsuarios = true;
    _errorUsuarios = null;
    notifyListeners();
    try {
      _usuarios = await _service.getUsuarios(rol: rol, buscar: buscar);
    } on ApiException catch (e) {
      _errorUsuarios = e.mensaje;
    } finally {
      _cargandoUsuarios = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstadoUsuario(String id, bool activo) async {
    _errorAccion = null;
    try {
      await _service.cambiarEstadoUsuario(id, activo);
      final i = _usuarios.indexWhere((u) => u.id == id);
      if (i != -1) _usuarios[i] = _usuarios[i].copyWith(activo: activo);
      notifyListeners();
      cargarResumen();
      return true;
    } on ApiException catch (e) {
      _errorAccion = e.mensaje;
      notifyListeners();
      return false;
    }
  }

  Future<void> cargarIncidencias({String? estado}) async {
    _filtroIncidencias = estado;
    _cargandoIncidencias = true;
    _errorIncidencias = null;
    notifyListeners();
    try {
      _incidencias = await _service.getIncidencias(estado: estado);
    } on ApiException catch (e) {
      _errorIncidencias = e.mensaje;
    } finally {
      _cargandoIncidencias = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstadoIncidencia(String id, String estado) async {
    _errorAccion = null;
    try {
      await _service.cambiarEstadoIncidencia(id, estado);
      await cargarIncidencias(estado: _filtroIncidencias);
      cargarResumen();
      return true;
    } on ApiException catch (e) {
      _errorAccion = e.mensaje;
      notifyListeners();
      return false;
    }
  }

  Future<void> cargarCitas({String? estado}) async {
    _cargandoCitas = true;
    _errorCitas = null;
    notifyListeners();
    try {
      _citas = await _service.getCitas(estado: estado);
    } on ApiException catch (e) {
      _errorCitas = e.mensaje;
    } finally {
      _cargandoCitas = false;
      notifyListeners();
    }
  }
}