import '../models/pago.dart';
import 'database_service.dart';

class PagoService {
  final dbService = DatabaseService();

  Future<void> insertarPago(Pago pago) async {
    final db = await dbService.database;
    await db.insert('pagos', pago.toMap());
  }

  Future<List<Pago>> obtenerPagosPorDeuda(int deudaId) async {
    final db = await dbService.database;

    final maps = await db.query(
      'pagos',
      where: 'deuda_id = ?',
      whereArgs: [deudaId],
      orderBy: 'fecha DESC',
    );

    return maps.map((e) => Pago.fromMap(e)).toList();
  }

  Future<void> eliminarPagosPorPersona(int personaId) async {
    final db = await dbService.database;

    await db.rawDelete('''
      DELETE FROM pagos
      WHERE deuda_id IN (
        SELECT id FROM deudas WHERE persona_id = ?
      )
    ''', [personaId]);
  }

  Future<void> eliminarPagosPorDeuda(int deudaId) async {
    final db = await dbService.database;

    await db.delete(
      'pagos',
      where: 'deuda_id = ?',
      whereArgs: [deudaId],
    );
  }
}
