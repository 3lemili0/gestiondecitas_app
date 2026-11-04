import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/incidencias_provider.dart';
import '../../core/validators/validators.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_surface.dart';
import '../../core/theme/app_theme.dart';

class IncidenciasScreen extends StatefulWidget {
  const IncidenciasScreen({super.key});

  @override
  State<IncidenciasScreen> createState() => _IncidenciasScreenState();
}

class _IncidenciasScreenState extends State<IncidenciasScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<IncidenciasProvider>().cargarIncidencias());
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Abierta':
        return AppColors.warning;
      case 'En revisión':
        return AppColors.primary;
      case 'Resuelta':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  void _abrirFormularioNueva() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FormularioIncidencia(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidenciasProvider>();
    final formato = DateFormat('d MMM yyyy, h:mm a', 'es');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Mis Incidencias'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _abrirFormularioNueva,
        icon: const Icon(Icons.add),
        label: const Text('Reportar'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => provider.cargarIncidencias(),
        child: provider.cargando
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : provider.error != null
            ? ListView(
          children: [
            const SizedBox(height: 100),
            Center(child: Text(provider.error!)),
          ],
        )
            : provider.incidencias.isEmpty
            ? ListView(
          children: [
            const SizedBox(height: 100),
            Icon(Icons.report_gmailerrorred_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Center(child: Text('No has reportado incidencias.')),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.incidencias.length,
          itemBuilder: (context, index) {
            final inc = provider.incidencias[index];
            final color = _colorEstado(inc.estado);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            inc.asunto,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            inc.estado,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(inc.descripcion, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          inc.esGeneral ? Icons.info_outline : Icons.event_note,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          inc.esGeneral ? 'General' : 'Ligada a una cita',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        Text(
                          formato.format(inc.createdAt.toLocal()),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
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

class _FormularioIncidencia extends StatefulWidget {
  const _FormularioIncidencia();

  @override
  State<_FormularioIncidencia> createState() => _FormularioIncidenciaState();
}

class _FormularioIncidenciaState extends State<_FormularioIncidencia> {
  final _formKey = GlobalKey<FormState>();
  final _asuntoController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _esGeneral = true;
  bool _enviando = false;

  @override
  void dispose() {
    _asuntoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);

    final provider = context.read<IncidenciasProvider>();
    final exito = await provider.crearIncidencia(
      tipo: _esGeneral ? 'general' : 'cita',
      asunto: _asuntoController.text.trim(),
      descripcion: _descripcionController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _enviando = false);

    if (exito) {
      Navigator.of(context).pop();
      AppFeedback.showSuccess(context, 'Incidencia reportada.');
    } else {
      AppFeedback.showError(context, provider.error ?? 'Error al reportar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Reportar incidencia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.primary,
                selectedForegroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
              segments: const [
                ButtonSegment(value: true, label: Text('General'), icon: Icon(Icons.info_outline)),
                ButtonSegment(value: false, label: Text('De una cita'), icon: Icon(Icons.event_note)),
              ],
              selected: {_esGeneral},
              onSelectionChanged: (nuevo) => setState(() => _esGeneral = nuevo.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _asuntoController,
              decoration: const InputDecoration(labelText: 'Asunto'),
              validator: (v) => Validators.requerido(v, campo: 'El asunto'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 4,
              maxLength: 500,
              validator: (v) => Validators.requerido(v, campo: 'La descripción'),
            ),
            const SizedBox(height: 12),
            _enviando
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ElevatedButton(
              onPressed: _enviar,
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}