import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      setState(() {
        isLoading = true;
      });

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      String email = userCredential.user?.email ?? 'email@default.com';
      int userId = userCredential.user?.uid.hashCode ?? 0;
      String userName = userCredential.user?.displayName ?? 'Usuario';

      String role = email.endsWith('@tutors.edu') ? 'tutor' : 'user';

      // Obtener `alumnoId` o `tutorId` según el rol del usuario
      int? alumnoId;
      int? tutorId;

      if (role == 'user') {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/obtenerAlumnoId/$userId'),
          headers: {'Authorization': 'Bearer ${userCredential.credential?.token}'},
        );

        if (response.statusCode == 200) {
          alumnoId = json.decode(response.body)['alumno_id'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al obtener el ID del alumno')),
          );
          setState(() {
            isLoading = false;
          });
          return null;
        }
      } else if (role == 'tutor') {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/obtenerTutorId/$userId'),
          headers: {'Authorization': 'Bearer ${userCredential.credential?.token}'},
        );

        if (response.statusCode == 200) {
          tutorId = json.decode(response.body)['tutor_id'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al obtener el ID del tutor')),
          );
          setState(() {
            isLoading = false;
          });
          return null;
        }
      }

      Provider.of<UserProvider>(context, listen: false).setToken(
        userCredential.credential?.token.toString() ?? '',
        role,
        userId,
        userName,
        email,
        alumnoId: alumnoId,
        tutorId: tutorId,
      );

      setState(() {
        isLoading = false;
      });
      return userCredential;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión con Google: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Por favor ingresa todos los campos')),
                    );
                    setState(() {
                      isLoading = false;
                    });
                    return;
                  }

                  try {
                    final response = await http.post(
                      Uri.parse('http://10.0.2.2:8000/api/login'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({'email': email, 'password': password}),
                    );

                    if (response.statusCode == 200) {
                      var responseData = json.decode(response.body);
                      String token = responseData['access_token'];
                      String role = responseData['user']['role'];
                      int userId = responseData['user']['id'];
                      String userName = responseData['user']['name'] ?? 'Usuario';
                      String userEmail = responseData['user']['email'] ?? 'email@default.com';

                      int? alumnoId;
                      int? tutorId;

                      if (role == 'user') {
                        alumnoId = responseData['user']['alumno_id'];
                        if (alumnoId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: No se encontró el ID de alumno asociado')),
                          );
                          setState(() {
                            isLoading = false;
                          });
                          return;
                        }
                      } else if (role == 'tutor') {
                        tutorId = responseData['user']['tutor_id'];
                        if (tutorId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: No se encontró el ID de tutor asociado')),
                          );
                          setState(() {
                            isLoading = false;
                          });
                          return;
                        }
                      }

                      Provider.of<UserProvider>(context, listen: false).setToken(
                        token,
                        role,
                        userId,
                        userName,
                        userEmail,
                        alumnoId: alumnoId,
                        tutorId: tutorId,
                      );
                      Navigator.pushReplacementNamed(context, '/');
                    } else {
                      var errorData = json.decode(response.body);
                      String errorMessage = errorData['error'] ?? 'Credenciales incorrectas';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: Text('Iniciar Sesión'),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text('Iniciar sesión con Google'),
                onPressed: () async {
                  UserCredential? userCredential = await _signInWithGoogle();
                  if (userCredential != null) {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('¿No tienes una cuenta? Regístrate aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
