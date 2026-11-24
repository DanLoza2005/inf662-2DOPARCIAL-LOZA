import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/categoria.dart';

class CategoriaProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<Categoria> categorias = [];
  bool cargando = false;
  String? error;

  Future<void> cargarCategorias() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      categorias = await _db.obtenerCategorias();
    } catch (e) {
      error = 'No se pudieron cargar las categorías';
    }

    cargando = false;
    notifyListeners();
  }

  // Las operaciones devuelven null si salio bien o el mensaje de error
  Future<String?> agregarCategoria(Categoria categoria) async {
    try {
      await _db.insertarCategoria(categoria);
      await cargarCategorias();
      return null;
    } catch (e) {
      return 'No se pudo guardar la categoría';
    }
  }

  Future<String?> actualizarCategoria(Categoria categoria) async {
    try {
      await _db.actualizarCategoria(categoria);
      await cargarCategorias();
      return null;
    } catch (e) {
      return 'No se pudo actualizar la categoría';
    }
  }

  // Borra la categoria junto con sus gastos (transaccion en el helper)
  Future<String?> eliminarCategoria(int id) async {
    try {
      await _db.eliminarCategoriaConGastos(id);
      await cargarCategorias();
      return null;
    } catch (e) {
      return 'No se pudo eliminar la categoría';
    }
  }
}
