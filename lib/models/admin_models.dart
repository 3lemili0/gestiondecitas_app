class ResumenAdmin {
  final int clientes;
  final int profesionales;
  final int usuariosInactivos;
  final int citasTotal;
  final int citasProgramadas;
  final int incidenciasPendientes;

  const ResumenAdmin({
    required this.clientes,
    required this.profesionales,
    required this.usuariosInactivos,
    required this.citasTotal,
    required this.citasProgramadas,
    required this.incidenciasPendientes,
  });

  factory ResumenAdmin.fromJson(Map<String, dynamic> json) {
    int n(String k) => (json[k] ?? 0) as int;
    return ResumenAdmin(
      clientes: n('clientes'),
      profesionales: n('profesionales'),
      usuariosInactivos: n('usuariosInactivos'),
      citasTotal: n('citasTotal'),
      citasProgramadas: n('citasProgramadas'),
      incidenciasPendientes: n('incidenciasPendientes'),
    );
  }
}

class UsuarioAdmin {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String rol;
  final String? numeroIdentificacion;
  final String? profesion;
  final String? telefono;
  final bool activo;

  const UsuarioAdmin({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.rol,
    this.numeroIdentificacion,
    this.profesion,
    this.telefono,
    required this.activo,
  });

  factory UsuarioAdmin.fromJson(Map<String, dynamic> json) {
    return UsuarioAdmin(
      id: json['_id'] ?? json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      correo: json['correo'] ?? '',
      rol: json['rol'] ?? 'cliente',
      numeroIdentificacion: json['numeroIdentificacion'],
      profesion: json['profesion'],
      telefono: json['telefono'],
      activo: json['activo'] ?? true,
    );
  }

  UsuarioAdmin copyWith({bool? activo}) {
    return UsuarioAdmin(
      id: id,
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      rol: rol,
      numeroIdentificacion: numeroIdentificacion,
      profesion: profesion,
      telefono: telefono,
      activo: activo ?? this.activo,
    );
  }

  String get nombreCompleto => '$nombre $apellido';
  bool get esProfesional => rol == 'profesional';
  String get rolLabel => esProfesional ? 'Doctor' : 'Paciente';

  String get iniciales {
    final a = nombre.isNotEmpty ? nombre[0] : '';
    final b = apellido.isNotEmpty ? apellido[0] : '';
    return (a + b).toUpperCase();
  }
}

class IncidenciaAdmin {
  final String id;
  final String tipo;
  final String asunto;
  final String descripcion;
  final String estado;
  final DateTime createdAt;
  final String usuarioNombre;
  final String usuarioRol;
  final DateTime? citaFecha;
  final String? citaMotivo;

  const IncidenciaAdmin({
    required this.id,
    required this.tipo,
    required this.asunto,
    required this.descripcion,
    required this.estado,
    required this.createdAt,
    required this.usuarioNombre,
    required this.usuarioRol,
    this.citaFecha,
    this.citaMotivo,
  });

  factory IncidenciaAdmin.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'];
    final cita = json['cita'];
    return IncidenciaAdmin(
      id: json['_id'] ?? json['id'] ?? '',
      tipo: json['tipo'] ?? 'general',
      asunto: json['asunto'] ?? '',
      descripcion: json['descripcion'] ?? '',
      estado: json['estado'] ?? 'Abierta',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      usuarioNombre: usuario is Map
          ? '${usuario['nombre'] ?? ''} ${usuario['apellido'] ?? ''}'.trim()
          : 'Usuario',
      usuarioRol: usuario is Map ? (usuario['rol'] ?? 'cliente') as String : 'cliente',
      citaFecha: cita is Map && cita['fecha'] != null
          ? DateTime.parse(cita['fecha'])
          : null,
      citaMotivo: cita is Map ? cita['motivo'] as String? : null,
    );
  }

  IncidenciaAdmin copyWith({String? estado}) {
    return IncidenciaAdmin(
      id: id,
      tipo: tipo,
      asunto: asunto,
      descripcion: descripcion,
      estado: estado ?? this.estado,
      createdAt: createdAt,
      usuarioNombre: usuarioNombre,
      usuarioRol: usuarioRol,
      citaFecha: citaFecha,
      citaMotivo: citaMotivo,
    );
  }

  bool get esGeneral => tipo == 'general';
  String get rolLabel => usuarioRol == 'profesional' ? 'Doctor' : 'Paciente';
}