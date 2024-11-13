import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AsignadosScreen extends StatefulWidget {
  @override
  _AsignadosScreenState createState() => _AsignadosScreenState();
}

class _AsignadosScreenState extends State<AsignadosScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>?> tutoresAsignados;

  @override
  void initState() {
    super.initState();
    tutoresAsignados = apiService.obtenerTutoresAsignados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutores Asignados'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: tutoresAsignados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay tutores asignados.'));
          } else {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final alumno = data[index];
                final alumnoNombre = alumno['alumno_nombre'] ?? 'Nombre no disponible';
                final tutores = alumno['tutores'] as List<dynamic>? ?? [];

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text('Alumno: $alumnoNombre'),
                    children: tutores.map<Widget>((tutor) {
                      final tutorNombre = tutor['tutor_nombre'] ?? 'Nombre no disponible';
                      final tutorEmail = tutor['tutor_email'] ?? 'Email no disponible';
                      return ListTile(
                        title: Text('Tutor: $tutorNombre'),
                        subtitle: Text('Email: $tutorEmail'),
                      );
                    }).toList(),
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
