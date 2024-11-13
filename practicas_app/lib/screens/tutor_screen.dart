import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../models/practica.dart'; // Importa el modelo de Practica
import '../services/api_service.dart';
import 'practica_details_screen.dart';

class TutorScreen extends StatefulWidget {
  final int tutorId;

  TutorScreen({required this.tutorId});

  @override
  _TutorScreenState createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Alumno>> alumnos;

  @override
  void initState() {
    super.initState();
    _loadAlumnosAsignados();
  }

  void _loadAlumnosAsignados() {
    setState(() {
      alumnos = apiService.obtenerAlumnosAsignadosATutor(widget.tutorId);
    });
  }

  void _navigateToPracticaDetails(BuildContext context, Alumno alumno) async {
    try {
      // Obtén la lista de prácticas del alumno
      final List<Practica> practicas = await apiService.obtenerPracticasPorAlumno(alumno.id);

      if (practicas.isNotEmpty) {
        // Navega al detalle de la primera práctica como ejemplo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PracticaDetailsScreen(practica: practicas.first),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No hay prácticas asignadas para este alumno.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar prácticas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel del Tutor'),
      ),
      body: FutureBuilder<List<Alumno>>(
        future: alumnos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar alumnos: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay alumnos asignados.'));
          } else {
            final alumnosList = snapshot.data!;
            return ListView.builder(
              itemCount: alumnosList.length,
              itemBuilder: (context, index) {
                final alumno = alumnosList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      alumno.nombre,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Código: ${alumno.codigo}'),
                    trailing: Icon(Icons.arrow_forward, color: Colors.purple),
                    onTap: () => _navigateToPracticaDetails(context, alumno),
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
