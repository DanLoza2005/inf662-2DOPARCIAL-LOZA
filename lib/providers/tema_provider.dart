import 'package:flutter/material.dart';

import '../db/database_helper.dart';

// Modo claro / oscuro, guardado en SQLite (tabla ajustes)
class TemaProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  ThemeMode _modo = ThemeMode.light;

  ThemeMode get modo => _modo;
  bool get oscuro => _modo == ThemeMode.dark;

  Future<void> cargarTema() async {
    try {
      final guardado = await _db.leerAjuste('tema');
      _modo = guardado == 'oscuro' ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      debugPrint('No se pudo leer el tema: $e');
    }
  }

  Future<void> alternar() async {
    _modo = oscuro ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();

    try {
      await _db.guardarAjuste('tema', oscuro ? 'oscuro' : 'claro');
    } catch (e) {
      debugPrint('No se pudo guardar el tema: $e');
    }
  }
}
