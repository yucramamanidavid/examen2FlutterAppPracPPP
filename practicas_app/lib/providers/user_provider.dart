import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _role = 'user'; // Rol por defecto
  String? _token; // Token de autenticación
  int? _userId; // ID del usuario
  int? _alumnoId; // ID del alumno
  int? _tutorId; // ID del tutor
  String _userName = 'Usuario'; // Valor predeterminado si es null
  String _userEmail = 'email@default.com'; // Valor predeterminado si es null

  // Getters
  String get role => _role;
  String? get token => _token;
  int? get userId => _userId;
  int? get alumnoId => _alumnoId; // Getter para alumnoId
  int? get tutorId => _tutorId; // Getter para tutorId
  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isAuthenticated => _token != null;
  bool get isAdmin => _role == 'admin';
  bool get isTutor => _role == 'tutor';

  // Método para cargar los datos de autenticación almacenados al iniciar la aplicación
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _role = prefs.getString('role') ?? 'user';
    _userId = prefs.getInt('userId');
    _alumnoId = prefs.getInt('alumnoId');
    _tutorId = prefs.getInt('tutorId');
    _userName = prefs.getString('userName') ?? 'Usuario';
    _userEmail = prefs.getString('userEmail') ?? 'email@default.com';
    notifyListeners();
  }

  // Método para guardar el token, rol, ID de usuario, ID de alumno, ID de tutor, nombre y correo del usuario en SharedPreferences y actualizar el estado
  Future<void> setToken(String token, String role, int userId, String userName, String userEmail, {int? alumnoId, int? tutorId}) async {
    _token = token;
    _role = role;
    _userId = userId;
    _alumnoId = alumnoId;
    _tutorId = tutorId;
    _userName = userName.isNotEmpty ? userName : 'Usuario';
    _userEmail = userEmail.isNotEmpty ? userEmail : 'email@default.com';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setInt('userId', userId);
    if (alumnoId != null) {
      await prefs.setInt('alumnoId', alumnoId);
    } else {
      await prefs.remove('alumnoId');
    }
    if (tutorId != null) {
      await prefs.setInt('tutorId', tutorId);
    } else {
      await prefs.remove('tutorId');
    }
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);
  }

  // Método para cerrar sesión y limpiar los datos de autenticación de SharedPreferences
  Future<void> logout() async {
    _role = 'user';
    _token = null;
    _userId = null;
    _alumnoId = null;
    _tutorId = null;
    _userName = 'Usuario';
    _userEmail = 'email@default.com';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('userId');
    await prefs.remove('alumnoId');
    await prefs.remove('tutorId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
  }
}
