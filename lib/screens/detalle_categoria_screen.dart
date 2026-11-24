import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/categoria.dart';
import '../providers/gasto_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/gasto_tile.dart';
import 'gasto_form_screen.dart';

// Detalle de la categoria (padre) con sus gastos (hijos)
class DetalleCategoriaScreen extends StatefulWidget {
  final Categoria categoria;

  const DetalleCategoriaScreen({
    super.key,
    required this.categoria,
  });

  @override
  State<DetalleCategoriaScreen> createState() => _DetalleCategoriaScreenState();
}

class _DetalleCategoriaScreenState extends State<DetalleCategoriaScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GastoProvider>().abrirCategoria(widget.categoria.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria.nombre),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GastoFormScreen(
                categoriaInicial: widget.categoria.id,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Gasto'),
      ),
      body: Consumer<GastoProvider>(
        builder: (context, provider, _) {
          if (provider.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return EmptyState(
              icono: Icons.error_outline,
              titulo: 'Algo salió mal',
              mensaje: provider.error,
            );
          }

          if (provider.gastosDeCategoria.isEmpty) {
            return const EmptyState(
              icono: Icons.money_off,
              titulo: 'No existen gastos',
              mensaje: 'Esta categoría todavía no tiene gastos.',
            );
          }

          final tema = Theme.of(context);

          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              Card(
                color: tema.colorScheme.primaryContainer,
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total gastado',
                        style: tema.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.totalCategoriaAbierta.toStringAsFixed(2)} Bs',
                        style: tema.textTheme.headlineMedium,
                      ),
                      Text(
                        '${provider.gastosDeCategoria.length} '
                        '${provider.gastosDeCategoria.length == 1 ? 'gasto' : 'gastos'}',
                      ),
                    ],
                  ),
                ),
              ),
              for (final gasto in provider.gastosDeCategoria)
                GastoTile(gasto: gasto, mostrarCategoria: false),
            ],
          );
        },
      ),
    );
  }
}
