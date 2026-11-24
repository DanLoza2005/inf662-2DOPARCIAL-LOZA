import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/categoria.dart';
import '../models/gasto.dart';
import '../models/resumen.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Guardo el Future (no la BD) para que si varios providers piden la BD
  // al mismo tiempo no se intente abrir dos veces
  static Future<Database>? _dbFuture;

  DatabaseHelper._init();

  Future<Database> get database => _dbFuture ??= _initDB('gastos.db');

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categorias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE gastos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT NOT NULL,
        monto REAL NOT NULL,
        categoria_id INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (categoria_id)
        REFERENCES categorias(id)
      )
    ''');

    await _crearTablaAjustes(db);

    // ---------- datos semilla ----------
    await db.insert('categorias', {'id': 1, 'nombre': 'Comida'});
    await db.insert('categorias', {'id': 2, 'nombre': 'Transporte'});
    await db.insert('categorias', {'id': 3, 'nombre': 'Estudios'});

    final semilla = [
      ['Almuerzo en el mercado', 18.0, 1, '2026-11-20'],
      ['Salteñas', 12.5, 1, '2026-11-15'],
      ['Compras del súper', 85.0, 1, '2026-10-28'],
      ['Taxi a la terminal', 20.0, 2, '2026-11-10'],
      ['Pasajes de la semana', 24.0, 2, '2026-10-12'],
      ['Fotocopias', 15.0, 3, '2026-11-02'],
      ['Libro de Flutter', 120.0, 3, '2026-10-05'],
      ['Impresión del informe', 8.5, 3, '2026-11-18'],
    ];

    for (final g in semilla) {
      await db.insert('gastos', {
        'descripcion': g[0],
        'monto': g[1],
        'categoria_id': g[2],
        'fecha': g[3],
      });
    }
  }

  // Migracion v1 -> v2: agrega la columna fecha sin perder los datos
  // y crea la tabla de ajustes (tema)
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE gastos ADD COLUMN fecha TEXT');
      await db.execute(
        "UPDATE gastos SET fecha = date('now') WHERE fecha IS NULL",
      );
      await _crearTablaAjustes(db);
    }
  }

  Future<void> _crearTablaAjustes(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ajustes(
        clave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');
  }

  // =====================================================
  // CATEGORIAS
  // =====================================================
  Future<List<Categoria>> obtenerCategorias() async {
    final db = await database;
    final result = await db.query('categorias', orderBy: 'nombre');
    return result.map((e) => Categoria.fromMap(e)).toList();
  }

  Future<int> insertarCategoria(Categoria categoria) async {
    final db = await database;
    final datos = categoria.toMap()..remove('id');
    return await db.insert('categorias', datos);
  }

  Future<int> actualizarCategoria(Categoria categoria) async {
    final db = await database;
    return await db.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  // Transaccion: primero se borran los gastos hijos y despues la categoria
  Future<void> eliminarCategoriaConGastos(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'gastos',
        where: 'categoria_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'categorias',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // =====================================================
  // GASTOS
  // =====================================================
  static const _selectGasto = '''
    SELECT g.*, c.nombre AS categoria_nombre
    FROM gastos g
    JOIN categorias c ON c.id = g.categoria_id
  ''';

  // Busqueda por texto con LIKE parametrizado + filtro por categoria
  Future<List<Gasto>> buscarGastos({
    String texto = '',
    int? categoriaId,
  }) async {
    final db = await database;

    final condiciones = <String>[];
    final args = <Object?>[];

    final t = texto.trim();
    if (t.isNotEmpty) {
      condiciones.add('g.descripcion LIKE ?');
      args.add('%$t%');
    }
    if (categoriaId != null) {
      condiciones.add('g.categoria_id = ?');
      args.add(categoriaId);
    }

    final where =
        condiciones.isEmpty ? '' : 'WHERE ${condiciones.join(' AND ')}';

    final result = await db.rawQuery(
      '$_selectGasto $where ORDER BY g.fecha DESC, g.id DESC',
      args,
    );
    return result.map((e) => Gasto.fromMap(e)).toList();
  }

  Future<int> insertarGasto(Gasto gasto) async {
    final db = await database;
    final datos = gasto.toMap()..remove('id');
    return await db.insert('gastos', datos);
  }

  Future<int> actualizarGasto(Gasto gasto) async {
    final db = await database;
    return await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  Future<int> eliminarGasto(int id) async {
    final db = await database;

    return await db.delete(
      'gastos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =====================================================
  // RESUMEN (agregaciones)
  // =====================================================

  // Total gastado por categoria: LEFT JOIN + GROUP BY + SUM/COUNT
  Future<List<ResumenCategoria>> obtenerTotalPorCategoria() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT c.id AS categoria_id,
             c.nombre,
             COUNT(g.id) AS cantidad,
             COALESCE(SUM(g.monto), 0) AS total
      FROM categorias c
      LEFT JOIN gastos g ON g.categoria_id = c.id
      GROUP BY c.id, c.nombre
      ORDER BY total DESC, c.nombre
    ''');
    return result.map((e) => ResumenCategoria.fromMap(e)).toList();
  }

  // Total gastado por mes: GROUP BY sobre yyyy-MM
  Future<List<ResumenMes>> obtenerTotalPorMes() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT strftime('%Y-%m', fecha) AS mes,
             COUNT(*) AS cantidad,
             SUM(monto) AS total
      FROM gastos
      WHERE fecha IS NOT NULL
      GROUP BY mes
      ORDER BY mes DESC
    ''');
    return result.map((e) => ResumenMes.fromMap(e)).toList();
  }

  // =====================================================
  // AJUSTES (tema)
  // =====================================================
  Future<String?> leerAjuste(String clave) async {
    final db = await database;
    final result = await db.query(
      'ajustes',
      where: 'clave = ?',
      whereArgs: [clave],
      limit: 1,
    );
    return result.isEmpty ? null : result.first['valor'] as String;
  }

  Future<void> guardarAjuste(String clave, String valor) async {
    final db = await database;
    await db.insert(
      'ajustes',
      {'clave': clave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
