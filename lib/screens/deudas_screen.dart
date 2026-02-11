import 'package:control_deudas/models/pago.dart';
import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../models/deuda.dart';
import '../services/deuda_service.dart';
import '../services/pago_service.dart';

class DeudasScreen extends StatefulWidget {
  final Persona persona;

  const DeudasScreen({super.key, required this.persona});

  @override
  State<DeudasScreen> createState() => _DeudasScreenState();
}

class _DeudasScreenState extends State<DeudasScreen> {

  final deudaService = DeudaService();
  final pagoService = PagoService();
  List<Deuda> deudas = [];

  @override
  void initState() {
    super.initState();
    cargarDeudas();
  }

  void cargarDeudas() async {
    deudas = await deudaService.obtenerDeudasPorPersona(
      widget.persona.id!,
    );
    setState(() {});
  }

  void agregarDeuda(String concepto, double monto) async {
    Deuda nueva = Deuda(
      concepto: concepto,
      montoTotal: monto,
      fecha: DateTime.now(),
    );

    await deudaService.insertarDeuda(
      widget.persona.id!,
      nueva,
    );

    cargarDeudas();
  }


  void mostrarPagoDialog(Deuda deuda) {
    TextEditingController pagoController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Registrar Pago"),
          content: TextField(
            controller: pagoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Monto max(${deuda.saldo.toStringAsFixed(2)})"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                double? monto = double.tryParse(pagoController.text);

                if (monto == null || monto <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Monto inválido")),
                  );
                  return;
                }

                if (monto > deuda.saldo) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "El monto excede el saldo pendiente (\$${deuda.saldo})",
                      ),
                    ),
                  );
                  return;
                }

                final pago = Pago(
                  monto: monto,
                  fecha: DateTime.now(),
                );

                await pagoService.insertarPago(deuda.id!, pago);

                setState(() {
                  deuda.agregarPago(monto);
                });

                await deudaService.actualizarDeuda(
                  deuda.id!,
                  deuda.saldo,
                  deuda.estado,
                );

                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void mostrarFormulario() {
    TextEditingController conceptoController = TextEditingController();
    TextEditingController montoController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Nueva Deuda"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: conceptoController,
                decoration: const InputDecoration(labelText: "Concepto"),
              ),
              TextField(
                controller: montoController,
                decoration: const InputDecoration(labelText: "Monto"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                String concepto = conceptoController.text.trim();
                String montoTxt = montoController.text.trim();

                if (montoTxt.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("El monto no puede estar vacío"),
                    ),
                  );
                  return;
                }

                double? monto = double.tryParse(montoTxt);
                if (monto == null || monto <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Monto inválido"),
                    ),
                  );
                  return;
                }

                agregarDeuda(concepto, monto);
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  double calcularTotalDeuda() {
    double total = 0;

    for (var d in deudas) {
      total += d.saldo;
    }

    return total;
  }

  void mostrarPagoGeneralDialog() {
    TextEditingController controller = TextEditingController();
    final totalDeuda = calcularTotalDeuda();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Pago General"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Monto del pago max(${totalDeuda.toStringAsFixed(2)})",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                double? monto = double.tryParse(controller.text);
                double total = calcularTotalDeuda();
                if (monto == null || monto <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Monto inválido")),
                  );
                  return;
                }
                if (monto > total) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "El monto excede la deuda total (\$${total.toStringAsFixed(2)})",
                      ),
                    ),
                  );
                  return;
                }

                await aplicarPagoGeneral(monto);
                Navigator.pop(context);
              },
              child: const Text("Aplicar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> aplicarPagoGeneral(double monto) async {
    double restante = monto;

    // Ordenar por fecha (más antiguas primero)
    deudas.sort((a, b) => a.fecha.compareTo(b.fecha));

    for (var deuda in deudas) {
      if (restante <= 0) break;
      if (deuda.saldo <= 0) continue;

      double pago = restante >= deuda.saldo
          ? deuda.saldo
          : restante;

      final pagoObj = Pago(
        monto: pago,
        fecha: DateTime.now(),
      );

      await pagoService.insertarPago(deuda.id!, pagoObj);

      deuda.agregarPago(pago);

      await deudaService.actualizarDeuda(
        deuda.id!,
        deuda.saldo,
        deuda.estado,
      );

      restante -= pago;
    }

    setState(() {});
  }

  void mostrarEliminarDeudaDialog(Deuda deuda) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Eliminar Deuda"),
          content: Text(
            "¿Eliminar deuda '${deuda.concepto}'?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
              ),
              onPressed: () async {
                await pagoService.eliminarPagosPorDeuda(deuda.id!);
                await deudaService.eliminarDeuda(deuda.id!);
                cargarDeudas();
                Navigator.pop(context);
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Deudas de ${widget.persona.nombre}"),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "pagoGeneral",
            backgroundColor: Colors.green,
            onPressed: mostrarPagoGeneralDialog,
            child: const Icon(Icons.payments),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "nuevaDeuda",
            onPressed: mostrarFormulario,
            child: const Icon(Icons.add),
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Text(
              "Deuda total: \$${calcularTotalDeuda().toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: deudas.isEmpty
                ? const Center(child: Text("No hay deudas"))
                : ListView.builder(
                    itemCount: deudas.length,
                    itemBuilder: (context, index) {
                      final deuda = deudas[index];

                      return ListTile(
                        title: Text(deuda.concepto),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Monto original: \$${deuda.montoTotal}"),
                            Text("Saldo: \$${deuda.saldo}"),
                          ],
                        ),
                        trailing: Text(
                          deuda.estado,
                          style: TextStyle(
                            color: deuda.estado == "PAGADA"
                                ? Colors.green
                                : deuda.estado == "PARCIAL"
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                        onTap: () {
                          mostrarPagoDialog(deuda);
                        },
                        onLongPress: () {
                          mostrarEliminarDeudaDialog(deuda);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
