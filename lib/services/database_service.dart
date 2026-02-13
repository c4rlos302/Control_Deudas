import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'deudas.db');

    return await openDatabase(
      path,
      version: 3, // 👈 SUBIMOS VERSION
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ---------- CREACION INICIAL ----------
  Future _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE personas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE deudas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        persona_id INTEGER,
        concepto TEXT,
        monto REAL,
        saldo REAL,
        estado TEXT,
        fecha TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pagos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deuda_id INTEGER,
        monto REAL,
        fecha TEXT
      )
    ''');
  }

  // ---------- MIGRACIONES ----------
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {

    // v2 → agregar fecha a deudas y pagos
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE deudas ADD COLUMN fecha TEXT");
      await db.execute("ALTER TABLE pagos ADD COLUMN fecha TEXT");
    }

    // v3 → eliminar telefono de personas (recrear tabla)
    if (oldVersion < 3) {

      await db.execute('''
        CREATE TABLE personas_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL
        )
      ''');

      await db.execute('''
        INSERT INTO personas_new (id, nombre)
        SELECT id, nombre FROM personas
      ''');

      await db.execute('DROP TABLE personas');

      await db.execute('ALTER TABLE personas_new RENAME TO personas');
    }
  }
}
