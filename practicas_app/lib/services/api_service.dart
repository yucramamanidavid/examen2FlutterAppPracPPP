import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:practicas_app/models/tutor.dart';
import '../models/practica.dart';
import '../models/alumno.dart';
import 'package:http_parser/http_parser.dart';
import '../models/alumno_con_tutor.dart'; // Importa el modelo adecuado

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  // Obtener prácticas con paginación y opción de búsqueda
  Future<List<Practica>> obtenerPracticas(int page, {String? query}) async {
    try {
      final uri = Uri.parse('$baseUrl/practicas?page=$page${query != null && query.isNotEmpty ? '&titulo=$query&empresa=$query' : ''}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> practicasJson = data['data'];
        return practicasJson.map((item) => Practica.fromJson(item)).toList();
      } else {
        throw Exception('Error en la solicitud: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al cargar prácticas: $e');
    }
  }

  // Crear una nueva práctica
  Future<void> crearPractica(Practica practica) async {
    final response = await http.post(
      Uri.parse('$baseUrl/practicas'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(practica.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear práctica: ${response.body}');
    }
  }

  // Actualizar una práctica existente
  Future<void> actualizarPractica(int id, Practica practica) async {
    final response = await http.put(
      Uri.parse('$baseUrl/practicas/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(practica.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar práctica: ${response.body}');
    }
  }

  // Eliminar una práctica
  Future<void> eliminarPractica(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/practicas/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar práctica: ${response.body}');
    }
  }

  // Obtener lista de alumnos con opción de búsqueda
  Future<List<Alumno>> obtenerAlumnos({String? query}) async {
    try {
      final uri = Uri.parse('$baseUrl/alumnos${query != null && query.isNotEmpty ? '?query=$query' : ''}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Alumno.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener alumnos');
      }
    } catch (e) {
      throw Exception('Error al cargar alumnos: $e');
    }
  }

  // Obtener un alumno específico por su ID
  Future<Alumno> obtenerAlumnoPorId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/alumnos/$id'));

    if (response.statusCode == 200) {
      return Alumno.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener el alumno: ${response.statusCode} - ${response.body}');
    }
  }

  // Crear un nuevo alumno
  Future<void> crearAlumno(Alumno alumno) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alumnos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(alumno.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear alumno');
    }
  }

  // Actualizar un alumno existente
  Future<void> actualizarAlumno(int id, Alumno alumno) async {
    final response = await http.put(
      Uri.parse('$baseUrl/alumnos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(alumno.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar alumno');
    }
  }

  // Eliminar un alumno
  Future<void> eliminarAlumno(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/alumnos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar alumno');
    }
  }

  // Obtener lista de tutores
  Future<List<Tutor>> obtenerTutores() async {
    try {
      final uri = Uri.parse('$baseUrl/tutores');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Tutor.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener tutores');
      }
    } catch (e) {
      throw Exception('Error al cargar tutores: $e');
    }
  }

  // Crear un nuevo tutor
  Future<void> crearTutor(String nombre, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tutores'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear tutor: ${response.body}');
    }
  }

  Future<void> actualizarTutor(int id, Tutor tutor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tutores/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': tutor.nombre,
        'email': tutor.email,
        'password': tutor.password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar tutor: ${response.body}');
    }
  }

  // Eliminar un tutor
  Future<void> eliminarTutor(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tutores/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar tutor');
    }
  }

  // Obtener lista de alumnos asignados a un tutor
  Future<List<Alumno>> obtenerAlumnosAsignadosATutor(int tutorId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tutores/$tutorId/alumnos'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Alumno.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener alumnos asignados');
      }
    } catch (e) {
      throw Exception('Error al cargar alumnos asignados: $e');
    }
  }

  Future<void> asignarTutorAAlumnos(int tutorId, List<int> alumnoIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tutor/asignar'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'tutor_id': tutorId,
        'alumno_ids': alumnoIds,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al asignar tutor a alumnos');
    }
  }

  // Método para actualizar el estado de una práctica
  Future<void> actualizarEstadoPractica(int practicaId, String estado) async {
    final response = await http.put(
      Uri.parse('$baseUrl/practicas/$practicaId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'estado': estado}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el estado de la práctica');
    }
  }

  // Obtener prácticas de un alumno específico
  Future<List<Practica>> obtenerPracticasPorAlumno(int alumnoId) async {
    final response = await http.get(Uri.parse('$baseUrl/alumnos/$alumnoId/practicas'));

    if (response.statusCode == 200) {
      List<dynamic> practicasJson = json.decode(response.body);
      return practicasJson.map((json) => Practica.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener prácticas');
    }
  }

  Future<List<AlumnoConTutor>> obtenerAlumnosConTutores() async {
    final response = await http.get(Uri.parse('$baseUrl/alumnos_con_tutores'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => AlumnoConTutor.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener alumnos con tutores asignados');
    }
  }
  // Obtener tutores con alumnos asignados
  Future<Map<Tutor, List<Alumno>>> obtenerTutoresConAlumnosAsignados() async {
    final response = await http.get(Uri.parse('$baseUrl/tutores-con-alumnos'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      Map<Tutor, List<Alumno>> tutoresConAlumnos = {};

      for (var item in data) {
        Tutor tutor = Tutor(
          id: item['tutor']['id'],
          nombre: item['tutor']['nombre'],
          email: item['tutor']['email'],
        );

        List<Alumno> alumnos = (item['alumnos'] as List).map((alumnoData) {
          return Alumno(
            id: alumnoData['id'],
            nombre: alumnoData['nombre'],
            codigo: alumnoData['codigo'],
            email: alumnoData['email'], // Agregamos el email aquí
          );
        }).toList();

        tutoresConAlumnos[tutor] = alumnos;
      }
      return tutoresConAlumnos;
    } else {
      throw Exception('Error al obtener tutores con alumnos asignados');
    }
  }
  Future<List<Map<String, dynamic>>?> obtenerTutoresAsignados() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tutoresAsignados'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Error al obtener tutores asignados: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
// En ApiService.dart

  Future<void> aprobarPractica(int practicaId) async {
    final response = await http.put(
      Uri.parse('http://tu-api-url.com/practicas/$practicaId/aprobar'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al aprobar práctica');
    }
  }

  Future<void> rechazarPractica(int practicaId) async {
    final response = await http.put(
      Uri.parse('http://tu-api-url.com/practicas/$practicaId/rechazar'),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al rechazar práctica');
    }
  }
// Método para obtener las prácticas pendientes
  Future<List<Practica>> obtenerPracticasPendientes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/practicasPendientes'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Practica.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener prácticas pendientes');
      }
    } catch (e) {
      throw Exception('Error al obtener prácticas pendientes: $e');
    }
  }
  Future<Map<String, int>> obtenerEstadoPracticas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/estadisticas/practicas'));
      if (response.statusCode == 200) {
        return Map<String, int>.from(json.decode(response.body));
      } else {
        throw Exception('Error al obtener estadísticas de prácticas');
      }
    } catch (e) {
      throw Exception('Error al obtener estadísticas de prácticas: $e');
    }
  }

  Future<Map<String, int>> obtenerEstadisticasPracticas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/practicas/estadisticas'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return {
          'aprobadas': data['aprobadas'] ?? 0,
          'rechazadas': data['rechazadas'] ?? 0,
        };
      } else {
        throw Exception('Error al obtener estadísticas de prácticas');
      }
    } catch (e) {
      throw Exception('Error al cargar estadísticas: $e');
    }
  }


  // Método para cambiar el estado de una práctica
  Future<void> cambiarEstadoPractica(int practicaId, String estado) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/practicas/$practicaId/cambiar-estado'), // Asegúrate de que esta URL coincida con la ruta en Laravel
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'estado': estado}),
      );
      if (response.statusCode != 200) {
        throw Exception('Error al cambiar el estado de la práctica');
      }
    } catch (e) {
      throw Exception('Error al cambiar el estado de la práctica: $e');
    }
  }

  // Subir archivo de evidencia
  Future<void> subirEvidencia(int practicaId, PlatformFile file) async {
    var uri = Uri.parse('$baseUrl/practicas/$practicaId/evidencia');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile(
        'evidencia',
        File(file.path!).readAsBytes().asStream(),
        File(file.path!).lengthSync(),
        filename: file.name,
        contentType: MediaType('application', 'octet-stream'),
      ),
    );

    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Error al subir la evidencia');
    }
  }
}
