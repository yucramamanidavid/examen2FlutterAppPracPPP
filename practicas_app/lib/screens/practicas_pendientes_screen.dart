import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/practica.dart';

class PracticasPendientesScreen extends StatefulWidget {
  @override
  _PracticasPendientesScreenState createState() => _PracticasPendientesScreenState();
}

class _PracticasPendientesScreenState extends State<PracticasPendientesScreen> {
  final ApiService apiService = ApiService();
  Future<List<Practica>>? practicasPendientes;

  @override
  void initState() {
    super.initState();
    practicasPendientes = apiService.obtenerPracticasPendientes();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prácticas Pendientes'),
      ),
      body: FutureBuilder<List<Practica>>(
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
    );
  }
}
