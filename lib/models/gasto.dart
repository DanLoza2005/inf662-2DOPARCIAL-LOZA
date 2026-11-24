class Gasto {
  int? id;
  String descripcion;
  double monto;
  int categoriaId;

  // Fecha en formato ISO (yyyy-MM-dd) para poder agrupar por mes en SQL
  String fecha;

  // Solo viene cuando la consulta hace JOIN con categorias
  String? categoriaNombre;

  Gasto({
    this.id,
    required this.descripcion,
    required this.monto,
    required this.categoriaId,
    required this.fecha,
    this.categoriaNombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
      'monto': monto,
      'categoria_id': categoriaId,
      'fecha': fecha,
    };
  }

  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'],
      descripcion: map['descripcion'],
      monto: (map['monto'] as num).toDouble(),
      categoriaId: map['categoria_id'],
      fecha: (map['fecha'] as String?) ?? fechaIso(DateTime.now()),
      categoriaNombre: map['categoria_nombre'] as String?,
    );
  }

  // ---------- utilidades de fecha ----------
  static String fechaIso(DateTime d) {
    final mes = d.month.toString().padLeft(2, '0');
    final dia = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mes-$dia';
  }

  static String formatearFecha(DateTime d) {
    final mes = d.month.toString().padLeft(2, '0');
    final dia = d.day.toString().padLeft(2, '0');
    return '$dia/$mes/${d.year}';
  }

  String get fechaLegible {
    final d = DateTime.tryParse(fecha);
    return d == null ? fecha : formatearFecha(d);
  }
}
