import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notificaciones_provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_surface.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final usuario = context.read<AuthProvider>().usuario;
      if (usuario?.esAdministrador ?? false) {
        context.read<AdminProvider>().cargarResumen();
      } else {
        context.read<NotificacionesProvider>().actualizarContador();
      }
    });
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await AppFeedback.confirmar(
      context,
      titulo: 'Cerrar sesión',
      mensaje: '¿Seguro que quieres cerrar tu sesión?',
      textoConfirmar: 'Cerrar sesión',
      esDestructivo: true,
    );

    if (!confirmar || !mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notificacionesProvider = context.watch<NotificacionesProvider>();
    final usuario = authProvider.usuario;

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final esAdmin = usuario.esAdministrador;
    final portada = usuario.esProfesional
        ? 'assets/images/portada_doctor.png'
        : 'assets/images/portada_paciente.png';

    final etiquetaRol = esAdmin
        ? 'Administrador'
        : usuario.esProfesional
        ? 'Doctor · ${usuario.profesion ?? ''}'
        : 'Paciente';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            expandedHeight: 190,
            pinned: true,
            actions: [
              if (!esAdmin)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      tooltip: 'Notificaciones',
                      onPressed: () => context.go('/notificaciones'),
                    ),
                    if (notificacionesProvider.noLeidas > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            notificacionesProvider.noLeidas > 9
                                ? '9+'
                                : '${notificacionesProvider.noLeidas}',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                tooltip: 'Mi Perfil',
                onPressed: () => context.go('/perfil'),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar sesión',
                onPressed: _cerrarSesion,
              ),
              const SizedBox(width: 4),
            ],
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 20, bottom: 18, right: 20),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${usuario.nombre} ${usuario.apellido}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          background: esAdmin
              ? Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 24, bottom: 30),
                child: Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 90,
                  color: Colors.white.withOpacity(0.18),
                ),
              ),
            ),
          )
              : Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(portada, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryDark.withOpacity(0.25),
                      AppColors.primaryDark.withOpacity(0.75),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etiquetaRol,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  if (esAdmin) ...[
                    const Text(
                      'Resumen',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const _ResumenAdmin(),
                    const SizedBox(height: 24),
                    const Text(
                      'Gestión',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                  ],
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.05,
                    children: esAdmin
                        ? _opcionesAdmin(context)
                        : usuario.esProfesional
                        ? _opcionesProfesional(context)
                        : _opcionesCliente(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _opcionesAdmin(BuildContext context) {
    return [
      _DashboardTile(
        icon: Icons.people_outline,
        label: 'Usuarios',
        onTap: () => context.go('/admin/usuarios'),
      ),
      _DashboardTile(
        icon: Icons.report_gmailerrorred_outlined,
        label: 'Incidencias',
        onTap: () => context.go('/admin/incidencias'),
      ),
      _DashboardTile(
        icon: Icons.event_note,
        label: 'Todas las citas',
        onTap: () => context.go('/admin/citas'),
      ),
    ];
  }

  List<Widget> _opcionesCliente(BuildContext context) {
    return [
      _DashboardTile(
        icon: Icons.add_circle_outline,
        label: 'Solicitar Cita',
        onTap: () => context.go('/solicitar-cita'),
      ),
      _DashboardTile(
        icon: Icons.event_note,
        label: 'Mis Citas',
        onTap: () => context.go('/mis-citas'),
      ),
      _DashboardTile(
        icon: Icons.report_gmailerrorred_outlined,
        label: 'Incidencias',
        onTap: () => context.go('/incidencias'),
      ),
    ];
  }

  List<Widget> _opcionesProfesional(BuildContext context) {
    return [
      _DashboardTile(
        icon: Icons.event_note,
        label: 'Mis Citas',
        onTap: () => context.go('/mis-citas'),
      ),
      _DashboardTile(
        icon: Icons.person_add_alt,
        label: 'Crear Cita Manual',
        onTap: () => context.go('/agenda-profesional'),
      ),
      _DashboardTile(
        icon: Icons.schedule,
        label: 'Mi Disponibilidad',
        onTap: () => context.go('/gestionar-disponibilidad'),
      ),
      _DashboardTile(
        icon: Icons.report_gmailerrorred_outlined,
        label: 'Incidencias',
        onTap: () => context.go('/incidencias'),
      ),
    ];
  }
}

class _ResumenAdmin extends StatelessWidget {
  const _ResumenAdmin();

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final r = admin.resumen;

    if (r == null) {
      if (admin.cargandoResumen) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }
      return Row(
        children: [
          Expanded(
            child: Text(
              admin.errorResumen ?? 'No se pudo cargar el resumen.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => context.read<AdminProvider>().cargarResumen(),
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55, // Aumentado de 2.1 a 1.55 para dar más espacio vertical
      children: [
        _StatCard(
          icon: Icons.people_outline,
          label: 'Pacientes',
          valor: r.clientes,
          color: AppColors.primary,
        ),
        _StatCard(
          icon: Icons.medical_services_outlined,
          label: 'Doctores',
          valor: r.profesionales,
          color: AppColors.primary,
        ),
        _StatCard(
          icon: Icons.event_available,
          label: 'Citas programadas',
          valor: r.citasProgramadas,
          color: AppColors.success,
        ),
        _StatCard(
          icon: Icons.report_gmailerrorred_outlined,
          label: 'Incidencias pendientes',
          valor: r.incidenciasPendientes,
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int valor;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$valor',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 26, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}