import 'package:flutter/foundation.dart';
import '../models/cita.dart';
import '../models/usuario.dart';
import '../core/errors/api_exception.dart';
import '../services/cita_service.dart';

class CitasProvider extends ChangeNotifier {
  final CitaService _citaService = CitaService();

  List<Cita> _citas = [];
  List<Usuario> _clientes = [];
  bool _cargando = false;
  String? _error;

  List<Cita> get citas => _citas;
  List<Usuario> get clientes => _clientes;
  bool get cargando => _cargando;
  String? get error => _error;

  List<Cita> get citasProgramadas =>
      _citas.where((c) => c.estado == 'Programada').toList();

  Future<void> cargarMisCitas() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _citas = await _citaService.getMisCitas();
      _citas.sort((a, b) => b.fecha.compareTo(a.fecha));
    } on ApiException catch (e) {
      _error = e.mensaje;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarClientes() async {
    try {
      _clientes = await _citaService.getClientes();
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.mensaje;
      notifyListeners();
    }
  }

  Future<bool> reservarCita({
    required String profesionalId,
    required DateTime fecha,
    required String motivo,
  }) async {
    _error = null;
    try {
      await _citaService.reservarCita(
        profesionalId: profesionalId,
        fecha: fecha.toIso8601String(),
        motivo: motivo,
      );
      await cargarMisCitas();
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      notifyListeners();
      return false;
    }
  }

  Future<bool> crearCitaManual({
    required String clienteId,
    required DateTime fecha,
    required String motivo,
  }) async {
    _error = null;
    try {
      await _citaService.crearCitaManual(
        clienteId: clienteId,
        fecha: fecha.toIso8601String(),
        motivo: motivo,
      );
      await cargarMisCitas();
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelarCita(String citaId) async {
    _error = null;
    try {
      await _citaService.cancelarCita(citaId);
      await cargarMisCitas();
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completarCita(String citaId) async {
    _error = null;
    try {
      await _citaService.completarCita(citaId);
      await cargarMisCitas();
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      notifyListeners();
      return false;
    }
  }
}