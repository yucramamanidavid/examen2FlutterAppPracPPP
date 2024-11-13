import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/practica.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'add_practica_screen.dart';
import 'practica_details_screen.dart';

class AlumnoScreen extends StatefulWidget {
  @override
  _AlumnoScreenState createState() => _AlumnoScreenState();
}

class _AlumnoScreenState extends State<AlumnoScreen> {
  List<Practica> practicas = [];
  bool isLoading = false;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchPracticasAlumno();
  }

  Future<void> _fetchPracticasAlumno() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final alumnoId = userProvider.alumnoId; // Asegúrate de que `alumnoId` esté correctamente gestionado en `UserProvider`

      if (alumnoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No se pudo obtener el ID del alumno')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final fetchedPracticas = await apiService.obtenerPracticasPorAlumno(alumnoId);

      setState(() {
        practicas = fetchedPracticas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar prácticas: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Prácticas'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : practicas.isEmpty
          ? Center(child: Text('No tienes prácticas registradas.'))
          : ListView.builder(
        itemCount: practicas.length,
        itemBuilder: (context, index) {
          final practica = practicas[index];
          return ListTile(
            title: Text(practica.titulo),
            subtitle: Text('Empresa: ${practica.empresa}\nEstado: ${practica.estado}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticaDetailsScreen(practica: practica),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPracticaScreen(),
            ),
          );
          if (result == true) {
            _fetchPracticasAlumno();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Práctica agregada exitosamente')),
            );
          }
        },
        icon: Icon(Icons.add),
        label: Text('Agregar Práctica'),
      ),
    );
  }
}
