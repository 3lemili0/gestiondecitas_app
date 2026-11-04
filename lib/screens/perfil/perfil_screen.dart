import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/validators/validators.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_surface.dart';
import '../../core/theme/app_theme.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _telefonoController;
  late TextEditingController _profesionController;
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    final usuario = context.read<AuthProvider>().usuario;
    _nombreController = TextEditingController(text: usuario?.nombre ?? '');
    _apellidoController = TextEditingController(text: usuario?.apellido ?? '');
    _telefonoController = TextEditingController(text: usuario?.telefono ?? '');
    _profesionController = TextEditingController(text: usuario?.profesion ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _profesionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();
    final exito = await provider.actualizarPerfil(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      profesion: _profesionController.text.trim(),
    );

    if (!mounted) return;

    if (exito) {
      setState(() => _editando = false);
      AppFeedback.showSuccess(context, 'Perfil actualizado.');
    } else {
      AppFeedback.showError(context, provider.error ?? 'Error al actualizar.');
    }
  }

  void _cancelarEdicion() {
    final usuario = context.read<AuthProvider>().usuario;
    setState(() {
      _nombreController.text = usuario?.nombre ?? '';
      _apellidoController.text = usuario?.apellido ?? '';
      _telefonoController.text = usuario?.telefono ?? '';
      _profesionController.text = usuario?.profesion ?? '';
      _editando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final usuario = authProvider.usuario;

    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Mi Perfil'),
        actions: [
          if (!_editando)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: () => setState(() => _editando = true),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              usuario.esAdministrador ? 'Administrador' : (usuario.esProfesional ? 'Doctor' : 'Paciente'),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: AppSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    enabled: _editando,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validators.soloLetras(v, campo: 'El nombre'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _apellidoController,
                    enabled: _editando,
                    decoration: const InputDecoration(labelText: 'Apellido'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validators.soloLetras(v, campo: 'El apellido'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: usuario.correo,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Correo (no editable)'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _telefonoController,
                    enabled: _editando,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    keyboardType: TextInputType.phone,
                    validator: Validators.telefono,
                  ),
                  if (usuario.esProfesional) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _profesionController,
                      enabled: _editando,
                      decoration: const InputDecoration(labelText: 'Especialidad'),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => Validators.profesion(v),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_editando)
            authProvider.cargando
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelarEdicion,
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _guardar,
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}