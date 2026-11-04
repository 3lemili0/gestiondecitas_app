import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/validators/validators.dart';
import '../../core/theme/app_theme.dart';

enum _RolRegistro { cliente, profesional }

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _identificacionController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _profesionController = TextEditingController();

  _RolRegistro _rolSeleccionado = _RolRegistro.cliente;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _identificacionController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    _profesionController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final esProfesional = _rolSeleccionado == _RolRegistro.profesional;

    final datos = {
      'nombre': _nombreController.text.trim(),
      'apellido': _apellidoController.text.trim(),
      'numeroIdentificacion': _identificacionController.text.trim(),
      'correo': _correoController.text.trim(),
      'password': _passwordController.text,
      'rol': esProfesional ? 'profesional' : 'cliente',
      if (esProfesional) 'profesion': _profesionController.text.trim(),
      if (_telefonoController.text.trim().isNotEmpty)
        'telefono': _telefonoController.text.trim(),
    };

    final exito = await authProvider.registrar(datos);

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso. Ahora inicia sesión.')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final esProfesional = _rolSeleccionado == _RolRegistro.profesional;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Crear cuenta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿Cómo quieres registrarte?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              SegmentedButton<_RolRegistro>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.primary,
                  selectedForegroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                segments: const [
                  ButtonSegment(
                    value: _RolRegistro.cliente,
                    label: Text('Paciente'),
                    icon: Icon(Icons.person),
                  ),
                  ButtonSegment(
                    value: _RolRegistro.profesional,
                    label: Text('Doctor'),
                    icon: Icon(Icons.medical_services),
                  ),
                ],
                selected: {_rolSeleccionado},
                onSelectionChanged: (nuevo) {
                  setState(() => _rolSeleccionado = nuevo.first);
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => Validators.soloLetras(v, campo: 'El nombre'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => Validators.soloLetras(v, campo: 'El apellido'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _identificacionController,
                decoration: const InputDecoration(labelText: 'Número de identificación'),
                keyboardType: TextInputType.number,
                validator: Validators.identificacion,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: esProfesional
                    ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextFormField(
                    controller: _profesionController,
                    decoration: const InputDecoration(labelText: 'Especialidad'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => esProfesional ? Validators.profesion(v) : null,
                  ),
                )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.correo,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                keyboardType: TextInputType.phone,
                validator: Validators.telefono,
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
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ElevatedButton(
                onPressed: _registrar,
                child: const Text('Registrarme'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}