import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/gasto.dart';
import '../providers/gasto_provider.dart';
import '../screens/gasto_form_screen.dart';
import 'confirm_dialog.dart';
import 'mensajes.dart';

class GastoTile extends StatelessWidget {
  final Gasto gasto;
  final bool mostrarCategoria;

  const GastoTile({
    super.key,
    required this.gasto,
    this.mostrarCategoria = true,
  });

  Future<void> _eliminar(BuildContext context) async {
    // Se captura antes de los await: al borrar, este tile sale de la lista
    // y su context ya no estaria montado para mostrar el SnackBar
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<GastoProvider>();

    final confirmado = await mostrarConfirmacion(
      context,
      titulo: 'Eliminar gasto',
      mensaje: '¿Eliminar «${gasto.descripcion}»?',
    );
    if (confirmado != true || !context.mounted) return;

    final error = await provider.eliminarGasto(gasto.id!);
    mostrarSnackEn(messenger, error ?? 'Gasto eliminado');
  }

  @override
  Widget build(BuildContext context) {
    final detalle = mostrarCategoria
        ? '${gasto.categoriaNombre ?? ''} · ${gasto.fechaLegible}'
        : gasto.fechaLegible;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GastoFormScreen(gasto: gasto),
            ),
          );
        },
        leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
        title: Text(gasto.descripcion),
        subtitle: Text(detalle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${gasto.monto.toStringAsFixed(2)} Bs',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _eliminar(context),
            ),
          ],
        ),
      ),
    );
  }
}
