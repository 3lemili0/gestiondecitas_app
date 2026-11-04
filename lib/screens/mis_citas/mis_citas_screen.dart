import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/citas_provider.dart';
import '../../providers/resenas_provider.dart';
import '../../models/cita.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_surface.dart';
import '../../core/theme/app_theme.dart';

class MisCitasScreen extends StatefulWidget {
  const MisCitasScreen({super.key});

  @override
  State<MisCitasScreen> createState() => _MisCitasScreenState();
}

class _MisCitasScreenState extends State<MisCitasScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final citasProvider = context.read<CitasProvider>();
      await citasProvider.cargarMisCitas();
      final usuario = context.read<AuthProvider>().usuario;
      if (usuario != null && !usuario.esProfesional) {
        final resenasProvider = context.read<ResenasProvider>();
        for (final cita in citasProvider.citas.where((c) => c.esCompletada)) {
          resenasProvider.verificarResena(cita.id);
        }
      }
    });
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Programada':
        return AppColors.primary;
      case 'Completada':
        return AppColors.success;
      case 'Cancelada':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'Programada':
        return Icons.event_available;
      case 'Completada':
        return Icons.check_circle_outline;
      case 'Cancelada':
        return Icons.event_busy;
      default:
        return Icons.event_note;
    }
  }

  Future<void> _confirmarCancelar(BuildContext context, Cita cita) async {
    final confirmar = await AppFeedback.confirmar(
      context,
      titulo: 'Cancelar cita',
      mensaje: '¿Seguro que quieres cancelar esta cita? Esta acción no se puede deshacer.',
      textoConfirmar: 'Sí, cancelar',
      esDestructivo: true,
    );

    if (!confirmar || !context.mounted) return;

    final provider = context.read<CitasProvider>();
    final exito = await provider.cancelarCita(cita.id);
    if (!context.mounted) return;

    if (exito) {
      AppFeedback.showSuccess(context, 'Cita cancelada.');
    } else {
      AppFeedback.showError(context, provider.error ?? 'No se pudo cancelar.');
    }
  }

  Future<void> _confirmarCompletar(BuildContext context, Cita cita) async {
    final confirmar = await AppFeedback.confirmar(
      context,
      titulo: 'Marcar como completada',
      mensaje: '¿Confirmas que esta cita ya se llevó a cabo?',
      textoConfirmar: 'Sí, completada',
    );

    if (!confirmar || !context.mounted) return;

    final provider = context.read<CitasProvider>();
    final exito = await provider.completarCita(cita.id);
    if (!context.mounted) return;

    if (exito) {
      AppFeedback.showSuccess(context, 'Cita marcada como completada.');
    } else {
      AppFeedback.showError(context, provider.error ?? 'No se pudo completar.');
    }
  }

  void _abrirCalificar(BuildContext context, Cita cita) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FormularioCalificacion(cita: cita),
    );
  }

  @override
  Widget build(BuildContext context) {
    final citasProvider = context.watch<CitasProvider>();
    final resenasProvider = context.watch<ResenasProvider>();
    final usuario = context.read<AuthProvider>().usuario;
    final esProfesional = usuario?.esProfesional ?? false;
    final formatoFecha = DateFormat('EEEE d MMMM, h:mm a', 'es');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Mis Citas'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => citasProvider.cargarMisCitas(),
        child: citasProvider.cargando
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : citasProvider.error != null
            ? ListView(
          children: [
            const SizedBox(height: 100),
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Center(child: Text(citasProvider.error!)),
          ],
        )
            : citasProvider.citas.isEmpty
            ? ListView(
          children: [
            const SizedBox(height: 100),
            Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Center(child: Text('No tienes citas todavía.')),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: citasProvider.citas.length,
          itemBuilder: (context, index) {
            final cita = citasProvider.citas[index];
            final nombreContraparte = esProfesional
                ? (cita.clienteNombre ?? 'Paciente')
                : (cita.profesionalNombre ?? 'Doctor');

            String fechaTexto;
            try {
              fechaTexto = formatoFecha.format(cita.fecha.toLocal());
            } catch (_) {
              fechaTexto = cita.fecha.toLocal().toString();
            }

            final color = _colorEstado(cita.estado);
            final yaCalificada = resenasProvider.citaTieneResena(cita.id) ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_iconoEstado(cita.estado), color: color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            nombreContraparte,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cita.estado,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(fechaTexto, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notes, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            cita.motivo,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    if (cita.esProgramada && !esProfesional) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _confirmarCancelar(context, cita),
                          icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                          label: const Text('Cancelar', style: TextStyle(color: AppColors.error)),
                        ),
                      ),
                    ],
                    if (cita.esProgramada && esProfesional) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _confirmarCancelar(context, cita),
                            icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                            label: const Text('Cancelar', style: TextStyle(color: AppColors.error)),
                          ),
                          TextButton.icon(
                            onPressed: () => _confirmarCompletar(context, cita),
                            icon: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                            label: const Text('Completar', style: TextStyle(color: AppColors.success)),
                          ),
                        ],
                      ),
                    ],
                    if (cita.esCompletada && !esProfesional && !yaCalificada) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _abrirCalificar(context, cita),
                          icon: const Icon(Icons.star_outline, color: AppColors.primary, size: 18),
                          label: const Text('Calificar', style: TextStyle(color: AppColors.primary)),
                        ),
                      ),
                    ],
                    if (cita.esCompletada && !esProfesional && yaCalificada) ...[
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '✓ Ya calificaste esta cita',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FormularioCalificacion extends StatefulWidget {
  final Cita cita;
  const _FormularioCalificacion({required this.cita});

  @override
  State<_FormularioCalificacion> createState() => _FormularioCalificacionState();
}

class _FormularioCalificacionState extends State<_FormularioCalificacion> {
  int _calificacion = 0;
  final _comentarioController = TextEditingController();

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_calificacion == 0) {
      AppFeedback.showInfo(context, 'Selecciona una calificación.');
      return;
    }

    final provider = context.read<ResenasProvider>();
    final exito = await provider.enviarResena(
      citaId: widget.cita.id,
      calificacion: _calificacion,
      comentario: _comentarioController.text,
    );

    if (!mounted) return;

    if (exito) {
      Navigator.of(context).pop();
      AppFeedback.showSuccess(context, '¡Gracias por tu calificación!');
    } else {
      AppFeedback.showError(context, provider.error ?? 'Error al enviar la calificación.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResenasProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Calificar cita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            'Dr. ${widget.cita.profesionalNombre ?? ''}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final estrella = i + 1;
              return IconButton(
                iconSize: 36,
                onPressed: () => setState(() => _calificacion = estrella),
                icon: Icon(
                  estrella <= _calificacion ? Icons.star : Icons.star_border,
                  color: AppColors.primary,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _comentarioController,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Comentario (opcional)',
            ),
          ),
          const SizedBox(height: 8),
          provider.enviando
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ElevatedButton(
            onPressed: _enviar,
            child: const Text('Enviar calificación'),
          ),
        ],
      ),
    );
  }
}