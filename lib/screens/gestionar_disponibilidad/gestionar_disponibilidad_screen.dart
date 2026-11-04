import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/disponibilidad_provider.dart';
import '../../models/disponibilidad.dart';
import '../../core/widgets/app_surface.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/time_utils.dart';

const List<String> _diasSemana = [
  'Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'
];

class GestionarDisponibilidadScreen extends StatefulWidget {
  const GestionarDisponibilidadScreen({super.key});

  @override
  State<GestionarDisponibilidadScreen> createState() =>
      _GestionarDisponibilidadScreenState();
}

class _GestionarDisponibilidadScreenState
    extends State<GestionarDisponibilidadScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
            () => context.read<DisponibilidadProvider>().cargarMiDisponibilidad());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DisponibilidadProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Mi Disponibilidad'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => provider.cargarMiDisponibilidad(),
        child: provider.cargando
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : provider.error != null
            ? ListView(
          children: [
            const SizedBox(height: 100),
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => provider.cargarMiDisponibilidad(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ),
          ],
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Desliza hacia abajo para actualizar. Toca un día para definir tu horario.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            ...List.generate(7, (diaSemana) {
              final existente = provider.paraDia(diaSemana);
              return _DiaCard(diaSemana: diaSemana, existente: existente);
            }),
          ],
        ),
      ),
    );
  }
}

class _DiaCard extends StatefulWidget {
  final int diaSemana;
  final Disponibilidad? existente;

  const _DiaCard({required this.diaSemana, required this.existente});

  @override
  State<_DiaCard> createState() => _DiaCardState();
}

class _DiaCardState extends State<_DiaCard> {
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFin;
  late TextEditingController _duracionController;
  bool _activo = false;
  bool _expandido = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _activo = widget.existente != null;
    _horaInicio = horaTextoATimeOfDay(widget.existente?.horaInicio ?? '09:00');
    _horaFin = horaTextoATimeOfDay(widget.existente?.horaFin ?? '17:00');
    _duracionController = TextEditingController(
        text: (widget.existente?.duracionCita ?? 60).toString());
  }

  @override
  void didUpdateWidget(covariant _DiaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.existente != widget.existente) {
      _activo = widget.existente != null;
      _horaInicio = horaTextoATimeOfDay(widget.existente?.horaInicio ?? '09:00');
      _horaFin = horaTextoATimeOfDay(widget.existente?.horaFin ?? '17:00');
      _duracionController.text = (widget.existente?.duracionCita ?? 60).toString();
    }
  }

  @override
  void dispose() {
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarHoraInicio() async {
    final hora = await seleccionarHora12(context, inicial: _horaInicio);
    if (hora != null) setState(() => _horaInicio = hora);
  }

  Future<void> _seleccionarHoraFin() async {
    final hora = await seleccionarHora12(context, inicial: _horaFin);
    if (hora != null) setState(() => _horaFin = hora);
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);

    final disponibilidad = Disponibilidad(
      diaSemana: widget.diaSemana,
      horaInicio: timeOfDayAHoraTexto24(_horaInicio),
      horaFin: timeOfDayAHoraTexto24(_horaFin),
      duracionCita: int.tryParse(_duracionController.text) ?? 60,
    );

    final exito = await context.read<DisponibilidadProvider>().guardar(disponibilidad);

    if (!mounted) return;
    setState(() {
      _guardando = false;
      _activo = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(exito ? 'Horario guardado.' : 'Error al guardar.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppSurface(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _expandido = !_expandido),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _activo ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: _activo ? AppColors.success : Colors.grey[400],
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _diasSemana[widget.diaSemana],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _activo
                                ? '${formatearHora12(_horaInicio)} - ${formatearHora12(_horaFin)}'
                                : 'Sin definir',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expandido ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (_expandido)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _CampoHora(
                            label: 'Hora inicio',
                            valor: formatearHora12(_horaInicio),
                            onTap: _seleccionarHoraInicio,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CampoHora(
                            label: 'Hora fin',
                            valor: formatearHora12(_horaFin),
                            onTap: _seleccionarHoraFin,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _duracionController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Duración por cita (min)'),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _guardando
                          ? const CircularProgressIndicator(color: AppColors.primary)
                          : ElevatedButton(
                        onPressed: _guardar,
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CampoHora extends StatelessWidget {
  final String label;
  final String valor;
  final VoidCallback onTap;

  const _CampoHora({required this.label, required this.valor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(valor),
      ),
    );
  }
}