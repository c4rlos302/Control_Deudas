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
            decoration: const InputDecoration(labelText: "Monto"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Deudas de ${widget.persona.nombre}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarFormulario,
        child: const Icon(Icons.add),
      ),
      body: deudas.isEmpty
          ? const Center(
              child: Text("No hay deudas registradas"),
            )
          : ListView.builder(
              itemCount: deudas.length,
              itemBuilder: (context, index) {
                final deuda = deudas[index];
                return ListTile(
                  title: Text(deuda.concepto),
                  subtitle: Text("Saldo: \$${deuda.saldo}"),
                  trailing: Text(deuda.estado),
                  onTap: () {
                    mostrarPagoDialog(deuda);
                  },
                );
              },
            ),
    );
  }
}
