class Deuda {
  int? id;
  final int personaId;
  final String concepto;
  final double montoTotal;
  final DateTime fecha;

  double saldo;
  String estado;

  Deuda({
    this.id,
    required this.personaId,
    required this.concepto,
    required this.montoTotal,
    required this.fecha,
    double? saldo,
    String? estado,
  })  : saldo = saldo ?? montoTotal,
        estado = estado ?? "PENDIENTE";

  void agregarPago(double monto) {
    saldo -= monto;

    if (saldo <= 0) {
      saldo = 0;
      estado = "PAGADA";
    } else {
      estado = "PARCIAL";
    }
  }
}
