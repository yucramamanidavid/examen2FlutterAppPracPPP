import 'package:flutter/material.dart';
import '../models/practica.dart';
import '../services/api_service.dart';
import 'practica_form_screen.dart';

class PracticaScreen extends StatefulWidget {
  @override
  _PracticaScreenState createState() => _PracticaScreenState();
}

class _PracticaScreenState extends State<PracticaScreen> {
  List<Practica> practicas = [];
  bool isLoading = false;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchPracticas();
  }

  Future<void> _fetchPracticas() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedPracticas = await apiService.obtenerPracticas(1); // Página 1 como ejemplo
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
        title: Text('Gestión de Prácticas'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              bool? result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PracticaFormScreen()),
              );
              if (result == true) {
                _fetchPracticas();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: practicas.length,
        itemBuilder: (context, index) {
          final practica = practicas[index];
          return ListTile(
            title: Text(practica.titulo),
            subtitle: Text('Empresa: ${practica.empresa}'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PracticaFormScreen(practica: practica),
                  ),
                );
                if (result == true) {
                  _fetchPracticas();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
