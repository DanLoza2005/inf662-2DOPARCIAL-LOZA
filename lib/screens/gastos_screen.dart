import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/categoria_provider.dart';
import '../providers/gasto_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/gasto_tile.dart';

class GastosScreen extends StatefulWidget {
  const GastosScreen({super.key});

  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  final busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Entra sin filtros y carga todos los gastos
      context.read<GastoProvider>().limpiarFiltros();
    });
  }

  @override
  void dispose() {
    busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/nuevo-gasto',
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: busquedaController,
              onChanged: (texto) {
                context.read<GastoProvider>().buscar(texto);
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por descripción',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const _FiltroCategorias(),
          const Expanded(child: _ListaGastos()),
        ],
      ),
    );
  }
}

class _FiltroCategorias extends StatelessWidget {
  const _FiltroCategorias();

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<CategoriaProvider>().categorias;
    final filtro = context.select<GastoProvider, int?>(
      (p) => p.filtroCategoria,
    );

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: ChoiceChip(
              label: const Text('Todas'),
              selected: filtro == null,
              onSelected: (_) {
                context.read<GastoProvider>().filtrarCategoria(null);
              },
            ),
          ),
          for (final categoria in categorias)
            Padding(
              padding: const EdgeInsets.all(4),
              child: ChoiceChip(
                label: Text(categoria.nombre),
                selected: filtro == categoria.id,
                onSelected: (_) {
                  context.read<GastoProvider>().filtrarCategoria(categoria.id);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ListaGastos extends StatelessWidget {
  const _ListaGastos();

  @override
  Widget build(BuildContext context) {
    return Consumer<GastoProvider>(
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

        if (provider.gastos.isEmpty) {
          return EmptyState(
            icono: provider.hayFiltros ? Icons.search_off : Icons.money_off,
            titulo: provider.hayFiltros ? 'Sin resultados' : 'No existen gastos',
            mensaje: provider.hayFiltros
                ? 'Prueba con otra palabra o con otra categoría.'
                : 'Toca «+» para registrar tu primer gasto.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: provider.gastos.length,
          itemBuilder: (context, index) {
            return GastoTile(gasto: provider.gastos[index]);
          },
        );
      },
    );
  }
}
