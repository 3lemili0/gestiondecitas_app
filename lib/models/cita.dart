import 'usuario.dart';

class Cita {
  final String id;
  final dynamic profesional;
  final dynamic cliente;
  final DateTime fecha;
  final String motivo;
  final String estado;
  final String origen;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cita({
    required this.id,
    required this.profesional,
    required this.cliente,
    required this.fecha,
    required this.motivo,
    required this.estado,
    required this.origen,
    this.createdAt,
    this.updatedAt,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['_id'] ?? json['id'] ?? '',
      profesional: json['profesional'] is Map
          ? Usuario.fromJson(json['profesional'])
          : json['profesional'],
      cliente: json['cliente'] is Map
          ? Usuario.fromJson(json['cliente'])
          : json['cliente'],
      fecha: DateTime.parse(json['fecha']),
      motivo: json['motivo'] ?? '',
      estado: json['estado'] ?? 'Programada',
      origen: json['origen'] ?? 'plataforma',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  String get profesionalId => profesional is Usuario ? profesional.id : profesional as String;
  String get clienteId => cliente is Usuario ? cliente.id : cliente as String;
  String? get profesionalNombre => profesional is Usuario ? (profesional as Usuario).nombreCompleto : null;
  String? get clienteNombre => cliente is Usuario ? (cliente as Usuario).nombreCompleto : null;

  bool get estaCancelada => estado == 'Cancelada';
  bool get esProgramada => estado == 'Programada';
  bool get esCompletada => estado == 'Completada';
}