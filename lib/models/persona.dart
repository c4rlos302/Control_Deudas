class Persona {
  int? id;
  String nombre;
  String telefono;

  Persona({
    this.id,
    required this.nombre,
    required this.telefono,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
    };
  }

  factory Persona.fromMap(Map<String, dynamic> map) {
    return Persona(
      id: map['id'],
      nombre: map['nombre'],
      telefono: map['telefono'] ?? '',
    );
  }
}
