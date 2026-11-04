import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/admin_provider.dart';
import '../../models/admin_models.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_surface.dart';
import '../../core/theme/app_theme.dart';
import 'admin_widgets.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  static const _opciones = ['Todos', 'Pacientes', 'Doctores'];
  static const List<String?> _roles = [null, 'cliente', 'profesional'];

  final _buscarController = TextEditingController();
  int _filtro = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_cargar);
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> _cargar() {
    return context.read<AdminProvider>().cargarUsuarios(
      rol: _roles[_filtro],
      buscar: _buscarController.text.trim(),
    );
  }

  Future<void> _cambiarActivo(UsuarioAdmin u, bool nuevoValor) async {
    if (!nuevoValor) {
      final confirmar = await AppFeedback.confirmar(
        context,
        titulo: 'Desactivar cuenta',
        mensaje:
        '${u.nombreCompleto} ya no podrá iniciar sesión ni usar la app. ¿Deseas continuar?',
        textoConfirmar: 'Desactivar',
        esDestructivo: true,
      );
      if (!confirmar || !mounted) return;
    }

    final provider = context.read<AdminProvider>();
    final exito = await provider.cambiarEstadoUsuario(u.id, nuevoValor);
    if (!mounted) return;

    if (exito) {
      AppFeedback.showSuccess(
        context,
        nuevoValor ? 'Cuenta activada.' : 'Cuenta desactivada.',
      );
    } else {
      AppFeedback.showError(context, provider.errorAccion ?? 'No se pudo actualizar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Usuarios'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _buscarController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _cargar(),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, correo o identificación',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscarController.text.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _buscarController.clear();
                    setState(() {});
                    _cargar();
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
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
              cargando: provider.cargandoUsuarios,
              error: provider.errorUsuarios,
              cantidad: provider.usuarios.length,
              mensajeVacio: 'No se encontraron usuarios.',
              iconoVacio: Icons.people_outline,
              onRefresh: _cargar,
              itemBuilder: (context, index) {
                final u = provider.usuarios[index];
                final rolTexto = u.esProfesional && (u.profesion ?? '').isNotEmpty
                    ? 'Doctor · ${u.profesion}'
                    : u.rolLabel;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppSurface(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            u.iniciales,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.nombreCompleto,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                u.correo,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  AdminBadge(rolTexto, AppColors.primary),
                                  if (!u.activo) const AdminBadge('Inactivo', AppColors.error),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: u.activo,
                          activeColor: AppColors.success,
                          onChanged: (v) => _cambiarActivo(u, v),
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