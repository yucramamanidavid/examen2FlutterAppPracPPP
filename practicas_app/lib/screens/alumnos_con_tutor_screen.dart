import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../services/api_service.dart';

class AlumnosConTutorScreen extends StatefulWidget {
  @override
  _AlumnosConTutorScreenState createState() => _AlumnosConTutorScreenState();
}

class _AlumnosConTutorScreenState extends State<AlumnosConTutorScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, List<Alumno>>> tutoresConAlumnos;

  @override
  void initState() {
    super.initState();
    tutoresConAlumnos = apiService.obtenerTutoresConAlumnosAsignados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alumnos con Tutor Asignado'),
      ),
      body: FutureBuilder<Map<String, List<Alumno>>>(
        future: tutoresConAlumnos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay alumnos con tutor asignado.'));
          } else {
            final Map<String, List<Alumno>> data = snapshot.data!;
            return ListView.builder(
              itemCount: data.keys.length,
              itemBuilder: (context, index) {
                String tutorNombre = data.keys.elementAt(index);
                List<Alumno> alumnos = data[tutorNombre]!;

                return ExpansionTile(
                  title: Text('Tutor: $tutorNombre'),
                  children: alumnos.map((alumno) {
                    return ListTile(
                      title: Text(alumno.nombre),
                      subtitle: Text('Código: ${alumno.codigo}'),
                    );
                  }).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }
}
