import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gasto_provider.dart';
import '../widgets/empty_state.dart';

class ResumenScreen extends StatefulWidget {
  const ResumenScreen({super.key});

  @override
  State<ResumenScreen> createState() => _ResumenScreenState();
}

class _ResumenScreenState extends State<ResumenScreen> {
  @override
  void initState() {
    super.initState();

    // Cada vez que se abre, se vuelve a consultar la BD
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GastoProvider>().cargarResumen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen'),
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

          if (provider.cantidadGeneral == 0) {
            return const EmptyState(
              icono: Icons.bar_chart,
              titulo: 'Nada que resumir',
              mensaje: 'Registra algunos gastos para ver las estadísticas.',
            );
          }

          final tema = Theme.of(context);

          // El mayor total sirve para dibujar las barras proporcionales
          final maxCategoria = provider.resumenPorCategoria
              .fold<double>(1, (a, r) => r.total > a ? r.total : a);
          final maxMes = provider.resumenPorMes
              .fold<double>(1, (a, r) => r.total > a ? r.total : a);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: tema.colorScheme.primaryContainer,
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
                        '${provider.totalGeneral.toStringAsFixed(2)} Bs',
                        style: tema.textTheme.headlineMedium,
                      ),
                      Text('${provider.cantidadGeneral} gastos registrados'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Por categoría', style: tema.textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final r in provider.resumenPorCategoria)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.nombre,
                                style: tema.textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              '${r.total.toStringAsFixed(2)} Bs',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${r.cantidad} ${r.cantidad == 1 ? 'gasto' : 'gastos'}',
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: r.total / maxCategoria),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text('Por mes', style: tema.textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final m in provider.resumenPorMes)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                m.etiqueta,
                                style: tema.textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              '${m.total.toStringAsFixed(2)} Bs',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${m.cantidad} ${m.cantidad == 1 ? 'gasto' : 'gastos'}',
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: m.total / maxMes),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
