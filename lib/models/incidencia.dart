class Incidencia {
  final String id;
  final String tipo;
  final String? citaId;
  final String asunto;
  final String descripcion;
  final String estado;
  final DateTime createdAt;

  Incidencia({
    required this.id,
    required this.tipo,
    this.citaId,
    required this.asunto,
    required this.descripcion,
    required this.estado,
    required this.createdAt,
  });

  factory Incidencia.fromJson(Map<String, dynamic> json) {
    return Incidencia(
      id: json['_id'] ?? json['id'] ?? '',
      tipo: json['tipo'] ?? 'general',
      citaId: json['cita'] is String ? json['cita'] : json['cita']?['_id'],
      asunto: json['asunto'] ?? '',
      descripcion: json['descripcion'] ?? '',
      estado: json['estado'] ?? 'Abierta',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  bool get esGeneral => tipo == 'general';
}