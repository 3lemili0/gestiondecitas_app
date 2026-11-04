import 'package:flutter/foundation.dart';
import '../models/incidencia.dart';
import '../core/errors/api_exception.dart';
import '../services/incidencia_service.dart';

class IncidenciasProvider extends ChangeNotifier {
  final IncidenciaService _service = IncidenciaService();

  List<Incidencia> _incidencias = [];
  bool _cargando = false;
  String? _error;

  List<Incidencia> get incidencias => _incidencias;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarIncidencias() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _incidencias = await _service.getMisIncidencias();
    } on ApiException catch (e) {
      _error = e.mensaje;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> crearIncidencia({
    required String tipo,
    required String asunto,
    required String descripcion,
    String? citaId,
  }) async {
    _error = null;
    try {
      await _service.crearIncidencia(
        tipo: tipo,
        asunto: asunto,
        descripcion: descripcion,
        citaId: citaId,
      );
      await cargarIncidencias();
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarEstado(String id, String estado) async {
    _error = null;
    try {
      await _service.actualizarEstado(id, estado);
      await cargarIncidencias();
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      notifyListeners();
      return false;
    }
  }
}