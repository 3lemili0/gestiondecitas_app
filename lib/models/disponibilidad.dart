class Disponibilidad {
  final String? id;
  final String? profesional;
  final int diaSemana; // 0=Domingo ... 6=Sábado
  final String horaInicio; // "HH:MM"
  final String horaFin;    // "HH:MM"
  final int duracionCita;  // minutos
  final bool? activo;

  Disponibilidad({
    this.id,
    this.profesional,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.duracionCita,
    this.activo,
  });

  factory Disponibilidad.fromJson(Map<String, dynamic> json) {
    return Disponibilidad(
      id: json['_id'] ?? json['id'],
      profesional: json['profesional'] is String
          ? json['profesional']
          : json['profesional']?['_id'],
      diaSemana: json['diaSemana'],
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
      duracionCita: json['duracionCita'] ?? 60,
      activo: json['activo'],
    );
  }

  Map<String, dynamic> toJson() => {
    'diaSemana': diaSemana,
    'horaInicio': horaInicio,
    'horaFin': horaFin,
    'duracionCita': duracionCita,
  };
}