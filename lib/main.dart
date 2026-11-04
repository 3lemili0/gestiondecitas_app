import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/citas_provider.dart';
import 'providers/profesionales_provider.dart';
import 'providers/disponibilidad_provider.dart';
import 'providers/notificaciones_provider.dart';
import 'providers/incidencias_provider.dart';
import 'providers/resenas_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/admin_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  await initializeDateFormatting('es_ES');
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..verificarSesion()),
        ChangeNotifierProvider(create: (_) => CitasProvider()),
        ChangeNotifierProvider(create: (_) => ProfesionalesProvider()),
        ChangeNotifierProvider(create: (_) => DisponibilidadProvider()),
        ChangeNotifierProvider(create: (_) => NotificacionesProvider()),
        ChangeNotifierProvider(create: (_) => IncidenciasProvider()),
        ChangeNotifierProvider(create: (_) => ResenasProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router = buildRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gestión de Citas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}