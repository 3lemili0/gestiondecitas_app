import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TimeOfDay horaTextoATimeOfDay(String horaTexto) {
  final partes = horaTexto.split(':');
  return TimeOfDay(
    hour: int.tryParse(partes[0]) ?? 0,
    minute: int.tryParse(partes.length > 1 ? partes[1] : '0') ?? 0,
  );
}

String timeOfDayAHoraTexto24(TimeOfDay hora) {
  return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
}

String formatearHora12(TimeOfDay hora) {
  final ahora = DateTime.now();
  final dt = DateTime(ahora.year, ahora.month, ahora.day, hora.hour, hora.minute);
  return DateFormat('h:mm a').format(dt);
}

String formatearHoraTexto12(String horaTexto24) {
  return formatearHora12(horaTextoATimeOfDay(horaTexto24));
}

Future<TimeOfDay?> seleccionarHora12(BuildContext context, {required TimeOfDay inicial}) {
  return showTimePicker(
    context: context,
    initialTime: inicial,
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      );
    },
  );
}