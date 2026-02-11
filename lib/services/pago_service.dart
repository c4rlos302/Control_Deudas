import 'database_service.dart';
import '../models/pago.dart';

class PagoService {
  final dbService = DatabaseService();

  Future<void> insertarPago(int deudaId, Pago pago) async {
    final db = await dbService.database;

    await db.insert('pagos', {
      'deuda_id': deudaId,
      'monto': pago.monto,
      'fecha': pago.fecha.toIso8601String(),
    });
  }

  Future<List<Pago>> obtenerPagosPorDeuda(int deudaId) async {
    final db = await dbService.database;

    final maps = await db.query(
      'pagos',
      where: 'deuda_id = ?',
      whereArgs: [deudaId],
    );

    return maps.map((e) {
      return Pago(
        monto: e['monto'] as double,
        fecha: DateTime.parse(e['fecha'] as String),
      );
    }).toList();
  }
}
