import 'package:flutter/material.dart';
import '../models/persona.dart';
import 'deudas_screen.dart';
import '../services/persona_service.dart';
import '../services/deuda_service.dart';
import '../services/pago_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final deudaService = DeudaService();
  final pagoService = PagoService();
  final personaService = PersonaService();
  List<Persona> personas = [];
  
  @override
  void initState() {
    super.initState();
    cargarPersonas();
  }

  void cargarPersonas() async {
    personas = await personaService.obtenerPersonas();
    setState(() {});
  }

  void agregarPersona(String nombre, String telefono) async {
    bool existe = personas.any(
      (p) => p.nombre.toLowerCase() == nombre.toLowerCase(),
    );

    if (existe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ya existe una persona con ese nombre"),
        ),
      );
      return;
    }

    Persona nueva = Persona(nombre: nombre, telefono: telefono);
    await personaService.insertarPersona(nueva);
    cargarPersonas();
  }

  void mostrarEliminarDialog(Persona persona) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Eliminar Persona"),
          content: Text(
            "¿Seguro que deseas eliminar a ${persona.nombre}?",
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
                await pagoService.eliminarPagosPorPersona(persona.id!);
                await deudaService.eliminarDeudasPorPersona(persona.id!);
                await personaService.eliminarPersona(persona.id!);
                cargarPersonas();
                Navigator.pop(context);
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void mostrarFormulario() {
    TextEditingController nombreController = TextEditingController();
    TextEditingController telefonoController = TextEditingController();
    nombreController.clear();
    telefonoController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Nueva Persona"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: "Teléfono"),
                keyboardType: TextInputType.phone,
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
                String nombre = nombreController.text.trim();
                String telefono = telefonoController.text.trim();

                if (nombre.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("El nombre es obligatorio"),
                    ),
                  );
                  return;
                }

                agregarPersona(nombre, telefono);
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Mis Deudas"),
          Text(
            "By Carlos Reynoso",
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,),
          ),
        ],
      ),
    ),

      floatingActionButton: FloatingActionButton(
        onPressed: mostrarFormulario,
        child: const Icon(Icons.add),
      ),
      body: personas.isEmpty
          ? const Center(
              child: Text("No hay personas registradas"),
            )
          : ListView.builder(
              itemCount: personas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(personas[index].nombre),
                  subtitle: Text(personas[index].telefono),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeudasScreen(
                          persona: personas[index],
                        ),
                      ),
                    );
                  },

                  onLongPress: () {
                    mostrarEliminarDialog(personas[index]);
                  },
                );
              },
            ),
    );
  }
}
