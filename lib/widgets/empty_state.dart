import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? mensaje;

  const EmptyState({
    super.key,
    this.icono = Icons.inbox_outlined,
    this.titulo = 'No existen datos',
    this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: tema.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (mensaje != null) ...[
              const SizedBox(height: 8),
              Text(
                mensaje!,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
