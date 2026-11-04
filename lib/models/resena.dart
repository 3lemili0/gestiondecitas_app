class Resena {
  final String id;
  final String citaId;
  final String pacienteId;
  final String? pacienteNombre;
  final String doctorId;
  final int calificacion;
  final String? comentario;
  final DateTime createdAt;

  Resena({
    required this.id,
    required this.citaId,
    required this.pacienteId,
    this.pacienteNombre,
    required this.doctorId,
    required this.calificacion,
    this.comentario,
    required this.createdAt,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    final pacienteRaw = json['paciente'];
    return Resena(
      id: json['_id'] ?? json['id'] ?? '',
      citaId: json['cita'] is String ? json['cita'] : json['cita']?['_id'] ?? '',
      pacienteId: pacienteRaw is Map ? pacienteRaw['_id'] : pacienteRaw ?? '',
      pacienteNombre: pacienteRaw is Map
          ? '${pacienteRaw['nombre'] ?? ''} ${pacienteRaw['apellido'] ?? ''}'.trim()
          : null,
      doctorId: json['doctor'] is String ? json['doctor'] : json['doctor']?['_id'] ?? '',
      calificacion: json['calificacion'] ?? 0,
      comentario: json['comentario'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class EstadisticasDoctor {
  final double promedio;
  final int total;
  final List<Resena> resenas;

  EstadisticasDoctor({
    required this.promedio,
    required this.total,
    required this.resenas,
  });

  factory EstadisticasDoctor.fromJson(Map<String, dynamic> json) {
    return EstadisticasDoctor(
      promedio: (json['promedio'] ?? 0).toDouble(),
      total: json['total'] ?? 0,
      resenas: (json['resenas'] as List? ?? [])
          .map((e) => Resena.fromJson(e))
          .toList(),
    );
  }
}