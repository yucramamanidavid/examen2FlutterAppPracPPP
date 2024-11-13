import 'package:flutter/material.dart';
import 'package:practicas_app/screens/practica_details_screen.dart';
import '../models/practica.dart';
import '../services/api_service.dart';

class PracticasAlumnoScreen extends StatefulWidget {
  final int alumnoId;

  PracticasAlumnoScreen({required this.alumnoId});

  @override
  _PracticasAlumnoScreenState createState() => _PracticasAlumnoScreenState();
}

class _PracticasAlumnoScreenState extends State<PracticasAlumnoScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Practica>> practicas;

  @override
  void initState() {
    super.initState();
    _loadPracticas();
  }

  void _loadPracticas() {
    setState(() {
      practicas = apiService.obtenerPracticasPorAlumno(widget.alumnoId);
    });
  }

  Future<void> _cambiarEstadoPractica(int practicaId, String estado) async {
    try {
      await apiService.cambiarEstadoPractica(practicaId, estado);
      // Refresca la lista de prácticas automáticamente
      practicas = apiService.obtenerPracticasPorAlumno(widget.alumnoId);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Práctica $estado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar el estado de la práctica: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prácticas del Alumno'),
      ),
      body: FutureBuilder<List<Practica>>(
        future: practicas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay prácticas disponibles'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final practica = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(practica.titulo),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Empresa: ${practica.empresa}'),
                        Text('Estado: ${practica.estado}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _cambiarEstadoPractica(practica.id, 'aprobado');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            _cambiarEstadoPractica(practica.id, 'rechazado');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.info, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PracticaDetailsScreen(practica: practica),
                              ),
                            );
                          },
                        ),

                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
