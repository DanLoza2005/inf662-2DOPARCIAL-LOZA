import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/categoria.dart';
import '../providers/categoria_provider.dart';
import '../providers/gasto_provider.dart';
import '../widgets/boton_tema.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/mensajes.dart';
import 'categoria_form_screen.dart';
import 'detalle_categoria_screen.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CategoriaProvider>().cargarCategorias();
    });
  }

  Future<void> _eliminar(Categoria categoria) async {
    final confirmado = await mostrarConfirmacion(
      context,
      titulo: 'Eliminar categoría',
      mensaje:
          'Se eliminará «${categoria.nombre}» junto con todos sus gastos. ¿Continuar?',
    );
    if (confirmado != true || !mounted) return;

    final error = await context
        .read<CategoriaProvider>()
        .eliminarCategoria(categoria.id!);
    if (!mounted) return;

    // Los gastos de esa categoria ya no existen: se refresca la lista
    if (error == null) {
      await context.read<GastoProvider>().cargarGastos(mostrarCarga: false);
      if (!mounted) return;
    }

    mostrarSnack(context, error ?? 'Categoría eliminada');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          IconButton(
            tooltip: 'Todos los gastos',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.pushNamed(context, '/gastos'),
          ),
          IconButton(
            tooltip: 'Resumen',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/resumen'),
          ),
          const BotonTema(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nueva categoría',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoriaFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<CategoriaProvider>(
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

          if (provider.categorias.isEmpty) {
            return const EmptyState(
              icono: Icons.category_outlined,
              titulo: 'No existen categorías',
              mensaje: 'Toca «+» para crear la primera.',
            );
          }

          return ListView.builder(
            itemCount: provider.categorias.length,
            itemBuilder: (context, index) {
              final categoria = provider.categorias[index];

              return ListTile(
                leading: const Icon(Icons.category),
                title: Text(categoria.nombre),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetalleCategoriaScreen(categoria: categoria),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CategoriaFormScreen(categoria: categoria),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminar(categoria),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
