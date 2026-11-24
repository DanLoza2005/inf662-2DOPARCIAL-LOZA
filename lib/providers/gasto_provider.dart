import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/gasto.dart';
import '../models/resumen.dart';

class GastoProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  // Lista general (con busqueda y filtro)
  List<Gasto> gastos = [];

  // Gastos de la categoria que se esta viendo en el detalle
  List<Gasto> gastosDeCategoria = [];

  // Resumen
  List<ResumenCategoria> resumenPorCategoria = [];
  List<ResumenMes> resumenPorMes = [];

  bool cargando = false;
  String? error;

  String _texto = '';
  int? _filtroCategoria;
  int? _categoriaAbierta;

  int? get filtroCategoria => _filtroCategoria;
  bool get hayFiltros => _texto.trim().isNotEmpty || _filtroCategoria != null;

  double get totalCategoriaAbierta =>
      gastosDeCategoria.fold(0.0, (suma, g) => suma + g.monto);

  double get totalGeneral =>
      resumenPorCategoria.fold(0.0, (suma, r) => suma + r.total);

  int get cantidadGeneral =>
      resumenPorCategoria.fold(0, (suma, r) => suma + r.cantidad);

  Future<void> cargarGastos({bool mostrarCarga = true}) async {
    if (mostrarCarga) {
      cargando = true;
      notifyListeners();
    }

    try {
      gastos = await _db.buscarGastos(
        texto: _texto,
        categoriaId: _filtroCategoria,
      );
      if (_categoriaAbierta != null) {
        gastosDeCategoria = await _db.buscarGastos(
          categoriaId: _categoriaAbierta,
        );
      }
      error = null;
    } catch (e) {
      error = 'No se pudieron cargar los gastos';
    }

    cargando = false;
    notifyListeners();
  }

  // Al entrar a la lista general se parte sin filtros
  Future<void> limpiarFiltros() {
    _texto = '';
    _filtroCategoria = null;
    return cargarGastos();
  }

  Future<void> buscar(String texto) {
    _texto = texto;
    return cargarGastos(mostrarCarga: false);
  }

  Future<void> filtrarCategoria(int? categoriaId) {
    _filtroCategoria = categoriaId;
    return cargarGastos(mostrarCarga: false);
  }

  Future<void> abrirCategoria(int categoriaId) {
    _categoriaAbierta = categoriaId;
    gastosDeCategoria = [];
    return cargarGastos();
  }

  Future<void> cargarResumen() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      resumenPorCategoria = await _db.obtenerTotalPorCategoria();
      resumenPorMes = await _db.obtenerTotalPorMes();
    } catch (e) {
      error = 'No se pudo calcular el resumen';
    }

    cargando = false;
    notifyListeners();
  }

  // null = salio bien, texto = mensaje de error
  Future<String?> agregarGasto(Gasto gasto) async {
    try {
      await _db.insertarGasto(gasto);
      await cargarGastos(mostrarCarga: false);
      return null;
    } catch (e) {
      return 'No se pudo guardar el gasto';
    }
  }

  Future<String?> actualizarGasto(Gasto gasto) async {
    try {
      await _db.actualizarGasto(gasto);
      await cargarGastos(mostrarCarga: false);
      return null;
    } catch (e) {
      return 'No se pudo actualizar el gasto';
    }
  }

  Future<String?> eliminarGasto(int id) async {
    try {
      await _db.eliminarGasto(id);
      await cargarGastos(mostrarCarga: false);
      return null;
    } catch (e) {
      return 'No se pudo eliminar el gasto';
    }
  }
}
