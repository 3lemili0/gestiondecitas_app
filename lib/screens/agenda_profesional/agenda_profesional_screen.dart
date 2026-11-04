import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/citas_provider.dart';
import '../../models/usuario.dart';
import '../../core/validators/validators.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/time_utils.dart';

class AgendaProfesionalScreen extends StatefulWidget {
  const AgendaProfesionalScreen({super.key});

  @override
  State<AgendaProfesionalScreen> createState() => _AgendaProfesionalScreenState();
}

class _AgendaProfesionalScreenState extends State<AgendaProfesionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  Usuario? _clienteSeleccionado;
  DateTime? _fecha;
  TimeOfDay? _hora;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CitasProvider>().cargarClientes());
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (fecha != null) setState(() => _fecha = fecha);
  }

  Future<void> _elegirHora() async {
    final hora = await seleccionarHora12(context, inicial: _hora ?? TimeOfDay.now());
    if (hora != null) setState(() => _hora = hora);
  }

  Future<void> _crearCita() async {
    if (_clienteSeleccionado == null) {
      AppFeedback.showInfo(context, 'Selecciona un paciente.');
      return;
    }
    if (_fecha == null || _hora == null) {
      AppFeedback.showInfo(context, 'Selecciona fecha y hora.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final fechaCompleta = DateTime(
      _fecha!.year, _fecha!.month, _fecha!.day, _hora!.hour, _hora!.minute,
    );

    setState(() => _enviando = true);

    final provider = context.read<CitasProvider>();
    final exito = await provider.crearCitaManual(
      clienteId: _clienteSeleccionado!.id,
      fecha: fechaCompleta,
      motivo: _motivoController.text.trim(),
    );

    setState(() => _enviando = false);

    if (!mounted) return;

    if (exito) {
      AppFeedback.showSuccess(context, 'Cita creada con éxito.');
      context.go('/dashboard');
    } else {
      AppFeedback.showError(context, provider.error ?? 'Error al crear la cita.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final citasProvider = context.watch<CitasProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Crear Cita Manual'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Paciente', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Usuario>(
              initialValue: _clienteSeleccionado,
              decoration: const InputDecoration(),
              hint: const Text('Selecciona un paciente'),
              items: citasProvider.clientes.map((cliente) {
                return DropdownMenuItem(
                  value: cliente,
                  child: Text(cliente.nombreCompleto),
                );
              }).toList(),
              onChanged: (cliente) => setState(() => _clienteSeleccionado = cliente),
            ),
            const SizedBox(height: 20),
            const Text('Fecha y hora', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _elegirFecha,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(_fecha == null
                        ? 'Fecha'
                        : '${_fecha!.day}/${_fecha!.month}/${_fecha!.year}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _elegirHora,
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(_hora == null ? 'Hora' : formatearHora12(_hora!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Motivo', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _motivoController,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(),
              validator: Validators.motivo,
            ),
            const SizedBox(height: 16),
            _enviando
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ElevatedButton(
              onPressed: _crearCita,
              child: const Text('Crear Cita'),
            ),
          ],
        ),
      ),
    );
  }
}