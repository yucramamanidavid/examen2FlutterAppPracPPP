import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../services/api_service.dart';
import 'alumno_form_screen.dart';

class AlumnoManagementScreen extends StatefulWidget {
  @override
  _AlumnoManagementScreenState createState() => _AlumnoManagementScreenState();
}

class _AlumnoManagementScreenState extends State<AlumnoManagementScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Alumno>> alumnos;

  @override
  void initState() {
    super.initState();
    _loadAlumnos();
  }

  void _loadAlumnos() {
    setState(() {
      alumnos = apiService.obtenerAlumnos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Alumnos'),
      ),
      body: FutureBuilder<List<Alumno>>(
        future: alumnos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar alumnos: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay alumnos registrados.'));
          } else {
            final alumnosList = snapshot.data!;
            return ListView.builder(
              itemCount: alumnosList.length,
              itemBuilder: (context, index) {
                final alumno = alumnosList[index];
                return ListTile(
                  title: Text(alumno.nombre),
                  subtitle: Text('Código: ${alumno.codigo}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AlumnoFormScreen(alumno: alumno)),
                          );
                          if (result == true) _loadAlumnos();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Implementar la lógica de eliminación
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AlumnoFormScreen()),
          );
          if (result == true) _loadAlumnos();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
