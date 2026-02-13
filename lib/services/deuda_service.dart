import 'database_service.dart';
import '../models/deuda.dart';

class DeudaService {
  final dbService = DatabaseService();

  Future<void> insertarDeuda(Deuda deuda) async {
    final db = await dbService.database;

    int id = await db.insert('deudas', {
      'persona_id': deuda.personaId,
      'concepto': deuda.concepto,
      'monto': deuda.montoTotal,
      'saldo': deuda.saldo,
      'estado': deuda.estado,
      'fecha': deuda.fecha.toIso8601String(),
    });

    deuda.id = id;
  }

  Future<List<Deuda>> obtenerDeudasPorPersona(int personaId) async {
    final db = await dbService.database;

    final maps = await db.query(
      'deudas',
      where: 'persona_id = ?',
      whereArgs: [personaId],
    );

    return maps.map((e) {
      return Deuda(
        id: e['id'] as int,
        personaId: e['persona_id'] as int,
        concepto: e['concepto'] as String,
        montoTotal: e['monto'] as double,
        fecha: DateTime.parse(e['fecha'] as String),
        saldo: e['saldo'] as double,
        estado: e['estado'] as String,
      );
    }).toList();

  }

  Future<void> actualizarDeuda(int id, double saldo, String estado) async {
    final db = await dbService.database;

    await db.update(
      'deudas',
      {
        'saldo': saldo,
        'estado': estado,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> eliminarDeudasPorPersona(int personaId) async {
    final db = await dbService.database;

    await db.delete(
      'deudas',
      where: 'persona_id = ?',
      whereArgs: [personaId],
    );
  }

  Future<void> eliminarDeuda(int deudaId) async {
    final db = await dbService.database;

    await db.delete(
      'deudas',
      where: 'id = ?',
      whereArgs: [deudaId],
    );
  }
}
