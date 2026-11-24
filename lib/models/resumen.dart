// Resultados de las consultas de agregacion (SUM / COUNT con GROUP BY)

class ResumenCategoria {
  final int categoriaId;
  final String nombre;
  final int cantidad;
  final double total;

  const ResumenCategoria({
    required this.categoriaId,
    required this.nombre,
    required this.cantidad,
    required this.total,
  });

  factory ResumenCategoria.fromMap(Map<String, dynamic> map) {
    return ResumenCategoria(
      categoriaId: map['categoria_id'] as int,
      nombre: map['nombre'] as String,
      cantidad: map['cantidad'] as int,
      total: (map['total'] as num).toDouble(),
    );
  }
}

class ResumenMes {
  // Formato yyyy-MM
  final String mes;
  final int cantidad;
  final double total;

  const ResumenMes({
    required this.mes,
    required this.cantidad,
    required this.total,
  });

  factory ResumenMes.fromMap(Map<String, dynamic> map) {
    return ResumenMes(
      mes: map['mes'] as String,
      cantidad: map['cantidad'] as int,
      total: (map['total'] as num).toDouble(),
    );
  }

  static const _meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  // "2026-11" -> "Noviembre 2026"
  String get etiqueta {
    final partes = mes.split('-');
    if (partes.length != 2) return mes;
    final numero = int.tryParse(partes[1]);
    if (numero == null || numero < 1 || numero > 12) return mes;
    return '${_meses[numero - 1]} ${partes[0]}';
  }
}
