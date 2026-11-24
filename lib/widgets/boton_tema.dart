import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tema_provider.dart';

class BotonTema extends StatelessWidget {
  const BotonTema({super.key});

  @override
  Widget build(BuildContext context) {
    // Selector: solo se reconstruye cuando cambia claro/oscuro
    return Selector<TemaProvider, bool>(
      selector: (_, tema) => tema.oscuro,
      builder: (context, oscuro, _) {
        return IconButton(
          tooltip: oscuro ? 'Modo claro' : 'Modo oscuro',
          icon: Icon(oscuro ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => context.read<TemaProvider>().alternar(),
        );
      },
    );
  }
}
