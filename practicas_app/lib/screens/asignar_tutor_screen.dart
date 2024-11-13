import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../models/tutor.dart';
import '../services/api_service.dart';

class AsignarTutorScreen extends StatefulWidget {
  @override
  _AsignarTutorScreenState createState() => _AsignarTutorScreenState();
}

class _AsignarTutorScreenState extends State<AsignarTutorScreen> {
  final ApiService apiService = ApiService();
  Future<List<Alumno>>? alumnos;
  late Future<List<Tutor>> tutores;
  int? selectedAlumnoId;
  int? selectedTutorId;
  String? selectedYear;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    tutores = apiService.obtenerTutores();
  }

  void _loadAlumnos() {
    setState(() {
      if (selectedYear != null && selectedYear!.isNotEmpty) {
        alumnos = apiService.obtenerAlumnos().then((alumnosList) {
          // Filtrar alumnos cuyo código comienza con el año seleccionado
          final filteredAlumnos = alumnosList
              .where((alumno) => alumno.codigo.startsWith(selectedYear!))
              .toList();

          // Verificar si hay elementos duplicados en el valor
          final ids = filteredAlumnos.map((alumno) => alumno.id).toList();
          print("IDs de alumnos filtrados para el año $selectedYear: $ids");

          return filteredAlumnos;
        });
      } else {
        alumnos = apiService.obtenerAlumnos();
      }
    });
  }


  void _asignarTutor() async {
    if (selectedAlumnoId == null || selectedTutorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccione un tutor y un alumno')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await apiService.asignarTutorAAlumnos(selectedTutorId!, [selectedAlumnoId!]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tutor asignado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al asignar tutor: ${e.toString()}')),
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
        title: Text('Asignar Tutor a Alumno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Seleccionar Año'),
              value: selectedYear,
              onChanged: (value) {
                setState(() {
                  selectedYear = value;
                  _loadAlumnos();
                });
              },
              items: ['2021', '2022', '2023', '2024'].map((year) {
                return DropdownMenuItem<String>(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
            ),
            FutureBuilder<List<Alumno>>(
              future: alumnos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error al cargar alumnos: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No hay alumnos disponibles para el año seleccionado.');
                } else {
                  return DropdownButton<int>(
                    hint: Text('Selecciona un Alumno'),
                    value: selectedAlumnoId,
                    onChanged: (value) {
                      setState(() {
                        selectedAlumnoId = value;
                      });
                    },
                    items: snapshot.data!.map((alumno) {
                      return DropdownMenuItem<int>(
                        value: alumno.id,
                        child: Text(alumno.nombre),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            FutureBuilder<List<Tutor>>(
              future: tutores,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error al cargar tutores: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No hay tutores disponibles.');
                } else {
                  return DropdownButton<int>(
                    hint: Text('Selecciona un Tutor'),
                    value: selectedTutorId,
                    onChanged: (value) {
                      setState(() {
                        selectedTutorId = value;
                      });
                    },
                    items: snapshot.data!.map((tutor) {
                      return DropdownMenuItem<int>(
                        value: tutor.id,
                        child: Text(tutor.nombre),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _asignarTutor,
              child: Text('Asignar Tutor'),
            ),
          ],
        ),
      ),
    );
  }
}
