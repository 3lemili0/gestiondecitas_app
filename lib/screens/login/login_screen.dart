import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _tardandoMucho = false;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    setState(() => _tardandoMucho = false);

    final avisoTimer = Future.delayed(const Duration(seconds: 5), () {
      if (mounted && context.read<AuthProvider>().cargando) {
        setState(() => _tardandoMucho = true);
      }
    });

    final authProvider = context.read<AuthProvider>();
    final exito = await authProvider.login(
      _correoController.text.trim(),
      _passwordController.text,
    );

    await avisoTimer;
    if (!mounted) return;
    setState(() => _tardandoMucho = false);

    if (exito) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 72, height: 72),
              const SizedBox(height: 16),
              const Text(
                'Bienvenido de nuevo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Inicia sesión para continuar',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (authProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    authProvider.error!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              authProvider.cargando
                  ? Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  if (_tardandoMucho) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'El servidor está iniciando, esto puede tardar unos segundos...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ],
              )
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _iniciarSesion,
                  child: const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/registro'),
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}