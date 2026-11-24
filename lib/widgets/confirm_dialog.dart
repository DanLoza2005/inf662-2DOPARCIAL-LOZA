import 'package:flutter/material.dart';

// Los parametros son opcionales: si no se pasan, queda el texto de siempre
Future<bool?> mostrarConfirmacion(
  BuildContext context, {
  String titulo = 'Confirmar',
  String mensaje = '¿Desea eliminar el registro?',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );
}
