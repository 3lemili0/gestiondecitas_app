import 'package:flutter/foundation.dart';
import '../models/disponibilidad.dart';
import '../core/errors/api_exception.dart';
import '../services/disponibilidad_service.dart';

class DisponibilidadProvider extends ChangeNotifier {
  final DisponibilidadService _disponibilidadService = DisponibilidadService();

  List<Disponibilidad> _disponibilidad = [];
  bool _cargando = false;
  String? _error;

  List<Disponibilidad> get disponibilidad => _disponibilidad;
  bool get cargando => _cargando;
  String? get error => _error;

  Disponibilidad? paraDia(int diaSemana) {
    try {
      return _disponibilidad.firstWhere((d) => d.diaSemana == diaSemana);
    } catch (_) {
      return null;
    }
  }

  Future<void> cargarMiDisponibilidad() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _disponibilidad = await _disponibilidadService.getMiDisponibilidad();
    } on ApiException catch (e) {
      _error = e.mensaje;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> guardar(Disponibilidad disponibilidad) async {
    _error = null;
    try {
      await _disponibilidadService.guardarDisponibilidad(disponibilidad);
      await cargarMiDisponibilidad();
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      notifyListeners();
      return false;
    }
  }
}