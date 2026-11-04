import 'package:flutter/foundation.dart';
import '../models/notificacion.dart';
import '../core/errors/api_exception.dart';
import '../services/notificacion_service.dart';

class NotificacionesProvider extends ChangeNotifier {
  final NotificacionService _service = NotificacionService();

  List<Notificacion> _notificaciones = [];
  int _noLeidas = 0;
  bool _cargando = false;
  String? _error;

  List<Notificacion> get notificaciones => _notificaciones;
  int get noLeidas => _noLeidas;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarNotificaciones() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _notificaciones = await _service.getMisNotificaciones();
      _noLeidas = _notificaciones.where((n) => !n.leida).length;
    } on ApiException catch (e) {
      _error = e.mensaje;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> actualizarContador() async {
    try {
      _noLeidas = await _service.getContadorNoLeidas();
      notifyListeners();
    } on ApiException {
      // Silencioso: el contador no es crítico, no interrumpimos al usuario
    }
  }

  Future<void> marcarLeida(String id) async {
    try {
      await _service.marcarLeida(id);
      final index = _notificaciones.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notificaciones[index] = _notificaciones[index].copyWith(leida: true);
        _noLeidas = _notificaciones.where((n) => !n.leida).length;
        notifyListeners();
      }
    } on ApiException catch (e) {
      _error = e.mensaje;
      notifyListeners();
    }
  }

  Future<void> marcarTodasLeidas() async {
    try {
      await _service.marcarTodasLeidas();
      _notificaciones = _notificaciones.map((n) => n.copyWith(leida: true)).toList();
      _noLeidas = 0;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.mensaje;
      notifyListeners();
    }
  }
}