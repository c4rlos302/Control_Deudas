import 'package:flutter/material.dart';
import '../models/persona.dart';
import 'deudas_screen.dart';
import '../services/persona_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
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
    Persona nueva = Persona(nombre: nombre, telefono: telefono);
    await personaService.insertarPersona(nueva);
    cargarPersonas();
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
        title: const Text("Mis Deudas"),
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
                );
              },
            ),
    );
  }
}
