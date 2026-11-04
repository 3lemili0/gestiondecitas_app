import 'package:flutter/foundation.dart';
import '../models/resena.dart';
import '../core/errors/api_exception.dart';
import '../services/resena_service.dart';

class ResenasProvider extends ChangeNotifier {
  final ResenaService _service = ResenaService();

  final Map<String, EstadisticasDoctor> _estadisticasPorDoctor = {};
  final Map<String, bool> _citasConResena = {};
  String? _error;
  bool _enviando = false;

  String? get error => _error;
  bool get enviando => _enviando;

  EstadisticasDoctor? estadisticasDe(String doctorId) => _estadisticasPorDoctor[doctorId];
  bool? citaTieneResena(String citaId) => _citasConResena[citaId];

  Future<void> cargarEstadisticasDoctor(String doctorId) async {
    if (_estadisticasPorDoctor.containsKey(doctorId)) return;
    try {
      final estadisticas = await _service.getEstadisticasDoctor(doctorId);
      _estadisticasPorDoctor[doctorId] = estadisticas;
      notifyListeners();
    } on ApiException {
    }
  }

  Future<void> verificarResena(String citaId) async {
    if (_citasConResena.containsKey(citaId)) return;
    final tiene = await _service.tieneResena(citaId);
    _citasConResena[citaId] = tiene;
    notifyListeners();
  }

  Future<bool> enviarResena({
    required String citaId,
    required int calificacion,
    String? comentario,
  }) async {
    _enviando = true;
    _error = null;
    notifyListeners();

    try {
      await _service.crearResena(
        citaId: citaId,
        calificacion: calificacion,
        comentario: comentario,
      );
      _citasConResena[citaId] = true;
      return true;
    } on ApiException catch (e) {
      _error = e.mensaje;
      return false;
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }
}