import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/profesionales_provider.dart';
import '../../providers/citas_provider.dart';
import '../../providers/resenas_provider.dart';
import '../../models/usuario.dart';
import '../../core/validators/validators.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_surface.dart';
import '../../core/theme/app_theme.dart';

class SolicitarCitaScreen extends StatefulWidget {
  const SolicitarCitaScreen({super.key});

  @override
  State<SolicitarCitaScreen> createState() => _SolicitarCitaScreenState();
}

class _SolicitarCitaScreenState extends State<SolicitarCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();

  Usuario? _profesionalSeleccionado;
  DateTime _mesEnfocado = DateTime.now();
  DateTime? _fechaSeleccionada;
  String? _horarioSeleccionado;
  List<String> _horariosDisponibles = [];
  bool _cargandoHorarios = false;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = context.read<ProfesionalesProvider>();
      await provider.cargarProfesionales();
      final resenasProvider = context.read<ResenasProvider>();
      for (final prof in provider.profesionales) {
        resenasProvider.cargarEstadisticasDoctor(prof.id);
      }
    });
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(DateTime fecha) async {
    setState(() {
      _fechaSeleccionada = fecha;
      _mesEnfocado = fecha;
      _horarioSeleccionado = null;
      _horariosDisponibles = [];
    });

    if (_profesionalSeleccionado != null) {
      await _cargarHorarios();
    }
  }

  Future<void> _cargarHorarios() async {
    if (_profesionalSeleccionado == null || _fechaSeleccionada == null) return;

    setState(() => _cargandoHorarios = true);

    final fechaTexto = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!);
    final horarios = await context
        .read<ProfesionalesProvider>()
        .obtenerHorarios(_profesionalSeleccionado!.id, fechaTexto);

    setState(() {
      _horariosDisponibles = horarios;
      _cargandoHorarios = false;
    });
  }

  Future<void> _confirmarReserva() async {
    if (_profesionalSeleccionado == null) {
      AppFeedback.showInfo(context, 'Selecciona un doctor.');
      return;
    }
    if (_horarioSeleccionado == null) {
      AppFeedback.showInfo(context, 'Selecciona un horario.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);

    final provider = context.read<CitasProvider>();
    final exito = await provider.reservarCita(
      profesionalId: _profesionalSeleccionado!.id,
      fecha: DateTime.parse(_horarioSeleccionado!),
      motivo: _motivoController.text.trim(),
    );

    setState(() => _enviando = false);

    if (!mounted) return;

    if (exito) {
      AppFeedback.showSuccess(context, '¡Cita reservada con éxito!');
      context.go('/dashboard');
    } else {
      AppFeedback.showError(context, provider.error ?? 'Error al reservar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profesionalesProvider = context.watch<ProfesionalesProvider>();
    final resenasProvider = context.watch<ResenasProvider>();
    final hoy = DateTime.now();
    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Solicitar Cita'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<ProfesionalesProvider>().cargarProfesionales(),
        child: profesionalesProvider.cargando
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : profesionalesProvider.error != null
            ? ListView(
          children: [
            const SizedBox(height: 100),
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  profesionalesProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => context.read<ProfesionalesProvider>().cargarProfesionales(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ),
          ],
        )
            : profesionalesProvider.profesionales.isEmpty
            ? ListView(
          children: [
            const SizedBox(height: 100),
            Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Center(child: Text('No hay doctores disponibles todavía.')),
          ],
        )
            : Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('1. Elige un doctor',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              ...profesionalesProvider.profesionales.map((prof) {
                final seleccionado = _profesionalSeleccionado?.id == prof.id;
                final estadisticas = resenasProvider.estadisticasDe(prof.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppSurface(
                    backgroundColor: seleccionado ? AppColors.primary.withOpacity(0.06) : null,
                    borderColor: seleccionado ? AppColors.primary : null,
                    onTap: () async {
                      setState(() {
                        _profesionalSeleccionado = prof;
                        _horarioSeleccionado = null;
                        _horariosDisponibles = [];
                      });
                      if (_fechaSeleccionada != null) {
                        await _cargarHorarios();
                      }
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.medical_services_outlined, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dr. ${prof.nombreCompleto}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(prof.profesion ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              const SizedBox(height: 4),
                              if (estadisticas != null && estadisticas.total > 0)
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${estadisticas.promedio} (${estadisticas.total})',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                )
                              else
                                const Text(
                                  'Sin calificaciones aún',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                        if (seleccionado)
                          const Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              const Text('2. Elige una fecha',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              AppSurface(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: TableCalendar(
                  locale: 'es_ES',
                  firstDay: hoySinHora,
                  lastDay: hoySinHora.add(const Duration(days: 90)),
                  focusedDay: _mesEnfocado.isBefore(hoySinHora) ? hoySinHora : _mesEnfocado,
                  currentDay: hoySinHora,
                  selectedDayPredicate: (day) =>
                  _fechaSeleccionada != null && isSameDay(_fechaSeleccionada, day),
                  enabledDayPredicate: (day) => !day.isBefore(hoySinHora),
                  onDaySelected: _profesionalSeleccionado == null
                      ? null
                      : (selected, focused) => _seleccionarFecha(selected),
                  onPageChanged: (focused) => setState(() => _mesEnfocado = focused),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
                    rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    weekendStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    disabledTextStyle: TextStyle(color: Colors.grey[300]),
                    defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
                    weekendTextStyle: const TextStyle(color: AppColors.textPrimary),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (_profesionalSeleccionado == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Selecciona primero un doctor para elegir fecha.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),
              if (_fechaSeleccionada != null) ...[
                const Text('3. Elige un horario',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                _cargandoHorarios
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _horariosDisponibles.isEmpty
                    ? const Text('No hay horarios disponibles para este día.',
                    style: TextStyle(color: AppColors.textSecondary))
                    : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _horariosDisponibles.map((horario) {
                    final hora = DateFormat('h:mm a')
                        .format(DateTime.parse(horario).toLocal());
                    final seleccionado = _horarioSeleccionado == horario;
                    return ChoiceChip(
                      label: Text(hora),
                      selected: seleccionado,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: seleccionado ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: AppColors.surface,
                      side: BorderSide(color: seleccionado ? AppColors.primary : AppColors.border),
                      onSelected: (_) {
                        setState(() => _horarioSeleccionado = horario);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              const Text('4. Motivo de la cita',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _motivoController,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: 'Describe brevemente el motivo...',
                ),
                validator: Validators.motivo,
              ),
              const SizedBox(height: 16),
              _enviando
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ElevatedButton(
                onPressed: _confirmarReserva,
                child: const Text('Confirmar Reserva'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}