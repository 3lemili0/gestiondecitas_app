import 'package:flutter/material.dart';

class AppFeedback {
  static void showSuccess(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showInfo(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<bool> confirmar(
      BuildContext context, {
        required String titulo,
        required String mensaje,
        String textoConfirmar = 'Confirmar',
        String textoCancelar = 'Cancelar',
        bool esDestructivo = false,
      }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(textoCancelar),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: esDestructivo ? Colors.red : null,
            ),
            child: Text(textoConfirmar),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }
}