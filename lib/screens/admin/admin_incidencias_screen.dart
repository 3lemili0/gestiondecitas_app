import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/admin_provider.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_surface.dart';
import '../../core/theme/app_theme.dart';
import 'admin_widgets.dart';

class AdminIncidenciasScreen extends StatefulWidget {
  const AdminIncidenciasScreen({super.key});

  @override
  State<AdminIncidenciasScreen> createState() => _AdminIncidenciasScreenState();
}

class _AdminIncidenciasScreenState extends State<AdminIncidenciasScreen> {
  static const _opciones = ['Todas', 'Abierta', 'En revisión', 'Resuelta'];
  static const List<String?> _valores = [null, 'Abierta', 'En revisión', 'Resuelta'];
  static const _estados = ['Abierta', 'En revisión', 'Resuelta'];

  int _filtro = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_cargar);
  }

  Future<void> _cargar() {
    return context.read<AdminProvider>().cargarIncidencias(estado: _valores[_filtro]);
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

  Future<void> _cambiarEstado(String id, String estado) async {
    final provider = context.read<AdminProvider>();
    final exito = await provider.cambiarEstadoIncidencia(id, estado);
    if (!mounted) return;

    if (exito) {
      AppFeedback.showSuccess(context, 'Estado actualizado a "$estado". Se notificó al usuario.');
    } else {
      AppFeedback.showError(context, provider.errorAccion ?? 'No se pudo actualizar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final formato = DateFormat('d MMM yyyy, h:mm a', 'es');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Incidencias'),
      ),
      body: Column(
        children: [
          AdminFiltroChips(
            opciones: _opciones,
            seleccionado: _filtro,
            onSeleccionar: (i) {
              setState(() => _filtro = i);
              _cargar();
            },
          ),
          Expanded(
            child: AdminLista(
              cargando: provider.cargandoIncidencias,
              error: provider.errorIncidencias,
              cantidad: provider.incidencias.length,
              mensajeVacio: 'No hay incidencias.',
              iconoVacio: Icons.report_gmailerrorred_outlined,
              onRefresh: _cargar,
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AdminBadge(inc.estado, color),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reportada por ${inc.usuarioNombre} (${inc.rolLabel})',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          inc.descripcion,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              inc.esGeneral ? Icons.info_outline : Icons.event,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                inc.esGeneral
                                    ? 'General'
                                    : inc.citaFecha != null
                                    ? 'Cita del ${formato.format(inc.citaFecha!.toLocal())}'
                                    : 'Ligada a una cita',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              formato.format(inc.createdAt.toLocal()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: PopupMenuButton<String>(
                            onSelected: (e) => _cambiarEstado(inc.id, e),
                            itemBuilder: (_) => _estados
                                .where((e) => e != inc.estado)
                                .map((e) => PopupMenuItem(value: e, child: Text(e)))
                                .toList(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.swap_horiz, size: 18, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text(
                                    'Cambiar estado',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}