import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/registro/registro_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/mis_citas/mis_citas_screen.dart';
import '../../screens/solicitar_cita/solicitar_cita_screen.dart';
import '../../screens/gestionar_disponibilidad/gestionar_disponibilidad_screen.dart';
import '../../screens/agenda_profesional/agenda_profesional_screen.dart';
import '../../screens/notificaciones/notificaciones_screen.dart';
import '../../screens/incidencias/incidencias_screen.dart';
import '../../screens/perfil/perfil_screen.dart';
import '../../screens/admin/admin_usuarios_screen.dart';
import '../../screens/admin/admin_incidencias_screen.dart';
import '../../screens/admin/admin_citas_screen.dart';

GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final logueado = authProvider.isLoggedIn;
      final desconocido = authProvider.status == AuthStatus.desconocido;
      final rutaActual = state.matchedLocation;

      final rutasPublicas = ['/login', '/registro'];
      final esRutaPublica = rutasPublicas.contains(rutaActual);

      if (desconocido) {
        return rutaActual == '/splash' ? null : '/splash';
      }

      if (rutaActual == '/splash') {
        return logueado ? '/dashboard' : '/login';
      }

      if (!logueado && !esRutaPublica) {
        return '/login';
      }

      if (logueado && esRutaPublica) {
        return '/dashboard';
      }

      // Las rutas /admin/... solo para administradores
      final esAdmin = authProvider.usuario?.esAdministrador ?? false;
      if (rutaActual.startsWith('/admin') && !esAdmin) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/registro', builder: (context, state) => const RegistroScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/mis-citas', builder: (context, state) => const MisCitasScreen()),
      GoRoute(path: '/solicitar-cita', builder: (context, state) => const SolicitarCitaScreen()),
      GoRoute(
        path: '/gestionar-disponibilidad',
        builder: (context, state) => const GestionarDisponibilidadScreen(),
      ),
      GoRoute(
        path: '/agenda-profesional',
        builder: (context, state) => const AgendaProfesionalScreen(),
      ),
      GoRoute(path: '/notificaciones', builder: (context, state) => const NotificacionesScreen()),
      GoRoute(path: '/incidencias', builder: (context, state) => const IncidenciasScreen()),
      GoRoute(path: '/perfil', builder: (context, state) => const PerfilScreen()),
      GoRoute(path: '/admin/usuarios', builder: (context, state) => const AdminUsuariosScreen()),
      GoRoute(
        path: '/admin/incidencias',
        builder: (context, state) => const AdminIncidenciasScreen(),
      ),
      GoRoute(path: '/admin/citas', builder: (context, state) => const AdminCitasScreen()),
    ],
  );
}