import 'package:flutter/material.dart';
import 'package:practicas_app/screens/asignados_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/practica.dart';
import '../models/alumno.dart';
import '../models/tutor.dart';
import 'admin_screen.dart';
import 'alumno_screen.dart';
import 'tutor_screen.dart';
import 'alumno_management_screen.dart';
import 'tutor_management_screen.dart';
import 'asignar_tutor_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  Future<Map<Tutor, List<Alumno>>>? tutoresConAlumnos;
  Future<List<Practica>>? practicasPendientes;

  @override
  void initState() {
    super.initState();
    // Carga los tutores y alumnos asignados al iniciar
    tutoresConAlumnos = apiService.obtenerTutoresConAlumnosAsignados();
    practicasPendientes = apiService.obtenerPracticasPendientes(); // Cargar prácticas pendientes
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Prácticas Preprofesionales'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              userProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userProvider.userName),
              accountEmail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userProvider.userEmail),
                  Text('Rol: ${userProvider.role}', style: TextStyle(fontSize: 12)),
                ],
              ),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Principal"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("Actividad"),
              onTap: () {
                Navigator.pushNamed(context, '/actividad');
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("Información"),
              onTap: () {
                Navigator.pushNamed(context, '/informacion');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.people),
              title: Text("Gestión de Alumnos"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlumnoManagementScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.supervisor_account),
              title: Text("Gestión de Tutores"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TutorManagementScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_ind),
              title: Text("Asignar Tutor"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AsignarTutorScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text("Tutores Asignados"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AsignadosScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Salir"),
              onTap: () {
                userProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: _buildBody(userProvider),
    );
  }

  Widget _buildBody(UserProvider userProvider) {
    if (userProvider.isAdmin) {
      return Column(
        children: [
          Expanded(child: AdminScreen()),
          Expanded(
            child: FutureBuilder<List<Practica>>(
              future: practicasPendientes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay prácticas pendientes.'));
                } else {
                  final practicas = snapshot.data!;
                  return ListView.builder(
                    itemCount: practicas.length,
                    itemBuilder: (context, index) {
                      final practica = practicas[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(practica.titulo),
                          subtitle: Text('Alumno: ${practica.alumnoId}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () => _cambiarEstadoPractica(practica.id, 'aprobado'),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () => _cambiarEstadoPractica(practica.id, 'rechazado'),
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
          ),
        ],
      );
    } else if (userProvider.isTutor && userProvider.userId != null) {
      return TutorScreen(tutorId: userProvider.userId!);
    } else {
      return AlumnoScreen();
    }
  }

  Future<void> _cambiarEstadoPractica(int practicaId, String estado) async {
    try {
      await apiService.cambiarEstadoPractica(practicaId, estado);
      setState(() {
        practicasPendientes = apiService.obtenerPracticasPendientes();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Práctica $estado con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar el estado de la práctica: $e')),
      );
    }
  }
}
