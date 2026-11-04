import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../core/errors/api_exception.dart';
import '../services/profesional_service.dart';

class ProfesionalesProvider extends ChangeNotifier {
  final ProfesionalService _profesionalService = ProfesionalService();

  List<Usuario> _profesionales = [];
  bool _cargando = false;
  String? _error;

  List<Usuario> get profesionales => _profesionales;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarProfesionales() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _profesionales = await _profesionalService.getProfesionales();
    } on ApiException catch (e) {
      _error = e.mensaje;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<List<String>> obtenerHorarios(String profesionalId, String fecha) async {
    try {
      return await _profesionalService.getDisponibilidad(profesionalId, fecha);
    } on ApiException catch (e) {
      _error = e.mensaje;
      notifyListeners();
      return [];
    }
  }
}