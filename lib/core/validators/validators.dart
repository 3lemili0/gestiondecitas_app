class Validators {
  static String? requerido(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) {
      return '$campo es requerido';
    }
    return null;
  }

  static String? soloLetras(String? valor, {String campo = 'Este campo'}) {
    final requeridoError = requerido(valor, campo: campo);
    if (requeridoError != null) return requeridoError;

    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!regex.hasMatch(valor!.trim())) {
      return '$campo solo debe contener letras';
    }
    if (valor.trim().length < 2) {
      return '$campo es muy corto';
    }
    return null;
  }

  static String? identificacion(String? valor) {
    final requeridoError = requerido(valor, campo: 'La identificación');
    if (requeridoError != null) return requeridoError;

    final limpio = valor!.trim();
    final regex = RegExp(r'^[0-9]+$');
    if (!regex.hasMatch(limpio)) {
      return 'La identificación solo debe contener números';
    }
    if (limpio.length < 6 || limpio.length > 15) {
      return 'La identificación debe tener entre 6 y 15 dígitos';
    }
    return null;
  }

  static String? correo(String? valor) {
    final requeridoError = requerido(valor, campo: 'El correo');
    if (requeridoError != null) return requeridoError;

    final regex = RegExp(r'^[\w.\-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!regex.hasMatch(valor!.trim())) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  static String? password(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (valor.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    if (valor.length > 50) {
      return 'Máximo 50 caracteres';
    }
    return null;
  }

  static String? telefono(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;

    final limpio = valor.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    final regex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!regex.hasMatch(limpio)) {
      return 'Ingresa un teléfono válido';
    }
    return null;
  }

  static String? profesion(String? valor) {
    return requerido(valor, campo: 'La especialidad');
  }

  static String? motivo(String? valor) {
    final requeridoError = requerido(valor, campo: 'El motivo');
    if (requeridoError != null) return requeridoError;

    if (valor!.trim().length < 5) {
      return 'Describe el motivo con más detalle (mínimo 5 caracteres)';
    }
    if (valor.trim().length > 300) {
      return 'Máximo 300 caracteres';
    }
    return null;
  }
}