import 'package:flutter/material.dart';
import '../models/tutor.dart';
import '../services/api_service.dart';
import 'tutor_form_screen.dart';

class TutorManagementScreen extends StatefulWidget {
  @override
  _TutorManagementScreenState createState() => _TutorManagementScreenState();
}

class _TutorManagementScreenState extends State<TutorManagementScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Tutor>> tutores;

  @override
  void initState() {
    super.initState();
    _loadTutores();
  }

  void _loadTutores() {
    setState(() {
      tutores = apiService.obtenerTutores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Tutores'),
      ),
      body: FutureBuilder<List<Tutor>>(
        future: tutores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar tutores: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay tutores registrados.'));
          } else {
            final tutoresList = snapshot.data!;
            return ListView.builder(
              itemCount: tutoresList.length,
              itemBuilder: (context, index) {
                final tutor = tutoresList[index];
                return ListTile(
                  title: Text(tutor.nombre),
                  subtitle: Text('Email: ${tutor.email}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TutorFormScreen(tutor: tutor)),
                          );
                          if (result == true) _loadTutores();
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
            MaterialPageRoute(builder: (context) => TutorFormScreen()),
          );
          if (result == true) _loadTutores();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
