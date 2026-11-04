import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AdminFiltroChips extends StatelessWidget {
  final List<String> opciones;
  final int seleccionado;
  final ValueChanged<int> onSeleccionar;

  const AdminFiltroChips({
    super.key,
    required this.opciones,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: opciones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sel = i == seleccionado;
          return ChoiceChip(
            label: Text(opciones[i]),
            selected: sel,
            showCheckmark: false,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(color: sel ? AppColors.primary : AppColors.border),
            labelStyle: TextStyle(
              color: sel ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            onSelected: (_) => onSeleccionar(i),
          );
        },
      ),
    );
  }
}

class AdminBadge extends StatelessWidget {
  final String texto;
  final Color color;

  const AdminBadge(this.texto, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

/// Lista con pull-to-refresh, estado de carga, error y vacío.
class AdminLista extends StatelessWidget {
  final bool cargando;
  final String? error;
  final int cantidad;
  final String mensajeVacio;
  final IconData iconoVacio;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const AdminLista({
    super.key,
    required this.cargando,
    required this.error,
    required this.cantidad,
    required this.mensajeVacio,
    required this.iconoVacio,
    required this.onRefresh,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: cargando
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : error != null
          ? ListView(
        children: [
          const SizedBox(height: 100),
          Center(child: Text(error!)),
        ],
      )
          : cantidad == 0
          ? ListView(
        children: [
          const SizedBox(height: 100),
          Icon(iconoVacio, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Center(child: Text(mensajeVacio)),
        ],
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: cantidad,
        itemBuilder: itemBuilder,
      ),
    );
  }
}