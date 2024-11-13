import 'package:flutter/material.dart';
import 'package:practicas_app/screens/alumno_form_screen.dart';
import 'package:practicas_app/screens/practica_form_screen.dart';
import 'package:practicas_app/screens/tutor_form_screen.dart';
import 'package:practicas_app/screens/practica_details_screen.dart';
import 'package:practicas_app/screens/practicas_alumno_screen.dart'; // Importa la nueva pantalla
import '../models/practica.dart';
import '../models/alumno.dart';
import '../models/tutor.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<List<Practica>> practicas;
  late Future<List<Alumno>> alumnos;
  late Future<List<Tutor>> tutores;
  final ApiService apiService = ApiService();

  String? selectedYear;
  List<String> availableYears = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      practicas = apiService.obtenerPracticas(1);
      alumnos = apiService.obtenerAlumnos();
      tutores = apiService.obtenerTutores();
      _getAvailableYears();
    });
  }

  void _getAvailableYears() async {
    final fetchedAlumnos = await apiService.obtenerAlumnos();
    final years = fetchedAlumnos
        .map((alumno) => alumno.codigo.substring(0, 4))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    setState(() {
      availableYears = years;
    });
  }

  List<Alumno> _filterAlumnosByYear(List<Alumno> alumnos) {
    if (selectedYear == null) return alumnos;
    return alumnos.where((alumno) => alumno.codigo.startsWith(selectedYear!)).toList();
  }

  void _deletePractica(int id) async {
    try {
      await apiService.eliminarPractica(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Práctica eliminada con éxito')),
      );
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar práctica: $e')),
      );
    }
  }

  void _deleteAlumno(int id) async {
    try {
      await apiService.eliminarAlumno(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alumno eliminado con éxito')),
      );
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar alumno: $e')),
      );
    }
  }

  void _deleteTutor(int id) async {
    try {
      await apiService.eliminarTutor(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tutor eliminado con éxito')),
      );
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar tutor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administración'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prácticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              FutureBuilder<List<Practica>>(
                future: practicas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay prácticas disponibles'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final practica = snapshot.data![index];
                        return ListTile(
                          title: Text(practica.titulo),
                          subtitle: Text('Empresa: ${practica.empresa}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.info, color: Colors.teal),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PracticaDetailsScreen(practica: practica),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  bool? result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PracticaFormScreen(
                                        practica: practica,
                                        alumnoId: practica.alumnoId,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    _refreshData();
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletePractica(practica.id),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Alumnos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    hint: Text('Filtrar por año'),
                    value: selectedYear,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue;
                      });
                    },
                    items: availableYears
                        .map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(year),
                    ))
                        .toList(),
                  ),
                ],
              ),
              FutureBuilder<List<Alumno>>(
                future: alumnos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay alumnos disponibles'));
                  } else {
                    final filteredAlumnos = _filterAlumnosByYear(snapshot.data!);
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredAlumnos.length,
                      itemBuilder: (context, index) {
                        final alumno = filteredAlumnos[index];
                        return ListTile(
                          title: Text(alumno.nombre),
                          subtitle: Text('Código: ${alumno.codigo}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.list_alt, color: Colors.purple),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PracticasAlumnoScreen(alumnoId: alumno.id),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  bool? result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AlumnoFormScreen(alumno: alumno),
                                    ),
                                  );
                                  if (result == true) {
                                    _refreshData();
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteAlumno(alumno.id),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              Divider(),
              Text('Tutores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              FutureBuilder<List<Tutor>>(
                future: tutores,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay tutores disponibles'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final tutor = snapshot.data![index];
                        return ListTile(
                          title: Text(tutor.nombre),
                          subtitle: Text('Email: ${tutor.email}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  bool? result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TutorFormScreen(tutor: tutor),
                                    ),
                                  );
                                  if (result == true) {
                                    _refreshData();
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTutor(tutor.id),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.person_add),
                    title: Text('Agregar Alumno'),
                    onTap: () async {
                      Navigator.pop(context);
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AlumnoFormScreen()),
                      );
                      if (result == true) {
                        _refreshData();
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.work),
                    title: Text('Agregar Práctica'),
                    onTap: () async {
                      Navigator.pop(context);
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PracticaFormScreen(alumnoId: 0)),
                      );
                      if (result == true) {
                        _refreshData();
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.school),
                    title: Text('Agregar Tutor'),
                    onTap: () async {
                      Navigator.pop(context);
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TutorFormScreen()),
                      );
                      if (result == true) {
                        _refreshData();
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
    );
  }
}
