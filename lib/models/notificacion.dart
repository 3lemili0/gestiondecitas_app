class Notificacion {
  final String id;
  final String tipo;
  final String mensaje;
  final String? citaId;
  final bool leida;
  final DateTime createdAt;

  Notificacion({
    required this.id,
    required this.tipo,
    required this.mensaje,
    this.citaId,
    required this.leida,
    required this.createdAt,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['_id'] ?? json['id'] ?? '',
      tipo: json['tipo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      citaId: json['cita'] is String ? json['cita'] : json['cita']?['_id'],
      leida: json['leida'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Notificacion copyWith({bool? leida}) {
    return Notificacion(
      id: id,
      tipo: tipo,
      mensaje: mensaje,
      citaId: citaId,
      leida: leida ?? this.leida,
      createdAt: createdAt,
    );
  }
}