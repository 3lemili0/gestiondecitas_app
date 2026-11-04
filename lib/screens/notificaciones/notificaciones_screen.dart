import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notificaciones_provider.dart';
import '../../core/widgets/app_surface.dart';
import '../../core/theme/app_theme.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NotificacionesProvider>().cargarNotificaciones());
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'cita_reservada':
        return Icons.event_available;
      case 'cita_manual':
        return Icons.event_note;
      case 'cita_cancelada':
        return Icons.event_busy;
      case 'incidencia_actualizada':
        return Icons.report_gmailerrorred_outlined;
      default:
        return Icons.notifications;
    }
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'cita_reservada':
      case 'cita_manual':
        return AppColors.primary;
      case 'cita_cancelada':
        return AppColors.error;
      case 'incidencia_actualizada':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificacionesProvider>();
    final formato = DateFormat('d MMM, h:mm a', 'es');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Notificaciones'),
        actions: [
          if (provider.noLeidas > 0)
            TextButton(
              onPressed: () => provider.marcarTodasLeidas(),
              child: const Text('Marcar todas', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => provider.cargarNotificaciones(),
        child: provider.cargando
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : provider.error != null
            ? ListView(
          children: [
            const SizedBox(height: 100),
            Center(child: Text(provider.error!)),
          ],
        )
            : provider.notificaciones.isEmpty
            ? ListView(
          children: [
            const SizedBox(height: 100),
            Icon(Icons.notifications_none, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Center(child: Text('No tienes notificaciones.')),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.notificaciones.length,
          itemBuilder: (context, index) {
            final n = provider.notificaciones[index];
            final color = _colorPorTipo(n.tipo);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppSurface(
                backgroundColor: n.leida ? AppColors.surface : AppColors.primary.withOpacity(0.04),
                onTap: () {
                  if (!n.leida) provider.marcarLeida(n.id);
                },
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_iconoPorTipo(n.tipo), color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.mensaje,
                            style: TextStyle(
                              fontWeight: n.leida ? FontWeight.normal : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formato.format(n.createdAt.toLocal()),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (!n.leida)
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
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