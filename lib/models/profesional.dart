class Profesional {
  final String id;
  final String nombre;
  final String apellido;
  final String profesion;
  final String? correo;

  Profesional({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.profesion,
    this.correo,
  });

  factory Profesional.fromJson(Map<String, dynamic> json) {
    return Profesional(
      id: json['_id'] ?? json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      profesion: json['profesion'] ?? '',
      correo: json['correo'],
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}