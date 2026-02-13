class Pago {
  int? id;
  final int deudaId;
  final double monto;
  final DateTime fecha;

  Pago({
    this.id,
    required this.deudaId,
    required this.monto,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deuda_id': deudaId,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Pago.fromMap(Map<String, dynamic> map) {
    return Pago(
      id: map['id'],
      deudaId: map['deuda_id'],
      monto: map['monto'],
      fecha: DateTime.parse(map['fecha']),
    );
  }
}
