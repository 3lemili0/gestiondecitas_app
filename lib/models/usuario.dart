class Usuario {
  final String id;
  final String nombre;
  final String apellido;
  final String? numeroIdentificacion;
  final String correo;
  final String rol; // 'profesional' | 'cliente'
  final String? profesion;
  final String? telefono;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.numeroIdentificacion,
    required this.correo,
    required this.rol,
    this.profesion,
    this.telefono,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['_id'] ?? json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      numeroIdentificacion: json['numeroIdentificacion'],
      correo: json['correo'] ?? '',
      rol: json['rol'] ?? 'cliente',
      profesion: json['profesion'],
      telefono: json['telefono'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'nombre': nombre,
    'apellido': apellido,
    'numeroIdentificacion': numeroIdentificacion,
    'correo': correo,
    'rol': rol,
    'profesion': profesion,
    'telefono': telefono,
  };

  bool get esProfesional => rol == 'profesional';
  bool get esCliente => rol == 'cliente';
  bool get esAdministrador => rol == 'administrador';
  String get nombreCompleto => '$nombre $apellido';
}

class AuthResponse {
  final String mensaje;
  final Usuario usuario;
  final String token;

  AuthResponse({required this.mensaje, required this.usuario, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      mensaje: json['mensaje'] ?? '',
      usuario: Usuario.fromJson(json['usuario']),
      token: json['token'] ?? '',
    );
  }
}