import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/categoria_provider.dart';
import 'providers/gasto_provider.dart';
import 'providers/tema_provider.dart';

import 'screens/categorias_screen.dart';
import 'screens/gastos_screen.dart';
import 'screens/gasto_form_screen.dart';
import 'screens/resumen_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoriaProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GastoProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TemaProvider()..cargarTema(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Solo se reconstruye el MaterialApp cuando cambia el tema
    return Consumer<TemaProvider>(
      builder: (context, tema, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Control de Gastos',
          themeMode: tema.modo,
          theme: ThemeData(
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          home: const CategoriasScreen(),
          routes: {
            '/gastos': (_) => const GastosScreen(),
            '/nuevo-gasto': (_) => const GastoFormScreen(),
            '/resumen': (_) => const ResumenScreen(),
          },
        );
      },
    );
  }
}
