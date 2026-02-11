import 'database_service.dart';
import '../models/persona.dart';

class PersonaService {
  final dbService = DatabaseService();

  Future<void> insertarPersona(Persona persona) async {
    final db = await dbService.database;
    await db.insert('personas', persona.toMap());
  }

  Future<List<Persona>> obtenerPersonas() async {
    final db = await dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('personas');

    return maps.map((e) => Persona.fromMap(e)).toList();
  }

  Future<void> eliminarPersona(int id) async {
    final db = await dbService.database;
    await db.delete(
      'personas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
