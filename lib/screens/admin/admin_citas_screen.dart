import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/admin_provider.dart';
import '../../core/widgets/app_surface.dart';
import '../../core/theme/app_theme.dart';
import 'admin_widgets.dart';

class AdminCitasScreen extends StatefulWidget {
  const AdminCitasScreen({super.key});

  @override
  State<AdminCitasScreen> createState() => _AdminCitasScreenState();
}

class _AdminCitasScreenState extends State<AdminCitasScreen> {
  static const _opciones = ['Todas', 'Programadas', 'Completadas', 'Canceladas'];
  static const List<String?> _valores = [null, 'Programada', 'Completada', 'Cancelada'];

  int _filtro = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_cargar);
  }

  Future<void> _cargar() {
    return context.read<AdminProvider>().cargarCitas(estado: _valores[_filtro]);
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
        title: const Text('Todas las citas'),
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
              cargando: provider.cargandoCitas,
              error: provider.errorCitas,
              cantidad: provider.citas.length,
              mensajeVacio: 'No hay citas para mostrar.',
              iconoVacio: Icons.event_busy,
              onRefresh: _cargar,
              itemBuilder: (context, index) {
                final cita = provider.citas[index];
                final color = _colorEstado(cita.estado);

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
                                formato.format(cita.fecha.toLocal()),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            AdminBadge(cita.estado, color),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Doctor: ${cita.profesionalNombre ?? 'Sin datos'}'),
                        Text('Paciente: ${cita.clienteNombre ?? 'Sin datos'}'),
                        const SizedBox(height: 6),
                        Text(
                          cita.motivo,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cita.origen == 'manual'
                              ? 'Creada manualmente por el doctor'
                              : 'Reservada por el paciente',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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