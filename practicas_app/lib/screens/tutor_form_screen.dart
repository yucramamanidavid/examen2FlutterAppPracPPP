import 'package:flutter/material.dart';
import '../models/tutor.dart'; // Asegúrate de que tienes un modelo Tutor definido
import '../services/api_service.dart';

class TutorFormScreen extends StatefulWidget {
  final Tutor? tutor; // Agrega un tutor opcional para edición

  TutorFormScreen({this.tutor});

  @override
  _TutorFormScreenState createState() => _TutorFormScreenState();
}

class _TutorFormScreenState extends State<TutorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    if (widget.tutor != null) {
      // Si estamos en modo de edición, cargamos los datos del tutor existente
      nameController.text = widget.tutor!.nombre;
      emailController.text = widget.tutor!.email;
      // Deja la contraseña vacía para que el usuario pueda actualizarla si lo desea
    }
  }

  Future<void> _saveTutor() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        if (widget.tutor == null) {
          // Modo creación
          await apiService.crearTutor(
            nameController.text.trim(),
            emailController.text.trim(),
            passwordController.text.trim(),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tutor creado con éxito')),
          );
        } else {
          // Modo edición
          await apiService.actualizarTutor(
            widget.tutor!.id,
            Tutor(
              id: widget.tutor!.id,
              nombre: nameController.text.trim(),
              email: emailController.text.trim(),
              password: passwordController.text.isEmpty
                  ? widget.tutor!.password
                  : passwordController.text.trim(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tutor actualizado con éxito')),
          );
        }

        Navigator.pop(context, true); // Regresa a la pantalla anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el formulario: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tutor == null ? 'Crear Tutor' : 'Editar Tutor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el correo electrónico';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (widget.tutor == null && (value == null || value.length < 6)) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _saveTutor,
                child: Text(widget.tutor == null ? 'Crear Tutor' : 'Actualizar Tutor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
