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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE personas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        telefono TEXT
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
}
