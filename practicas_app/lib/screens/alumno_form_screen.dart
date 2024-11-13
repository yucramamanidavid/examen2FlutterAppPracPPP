import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../services/api_service.dart';

class AlumnoFormScreen extends StatefulWidget {
  final Alumno? alumno; // Si es null, se trata de un nuevo alumno

  AlumnoFormScreen({this.alumno});

  @override
  _AlumnoFormScreenState createState() => _AlumnoFormScreenState();
}

class _AlumnoFormScreenState extends State<AlumnoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  String codigo = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    if (widget.alumno != null) {
      nombre = widget.alumno!.nombre;
      codigo = widget.alumno!.codigo;
      email = widget.alumno!.email;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final alumno = Alumno(
      id: widget.alumno?.id ?? 0,
      nombre: nombre,
      codigo: codigo,
      email: email,
    );

    try {
      if (widget.alumno == null) {
        await ApiService().crearAlumno(alumno);
      } else {
        await ApiService().actualizarAlumno(alumno.id, alumno);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el formulario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alumno == null ? 'Nuevo Alumno' : 'Editar Alumno'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: nombre,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Por favor ingresa un nombre' : null,
                onSaved: (value) => nombre = value!,
              ),
              TextFormField(
                initialValue: codigo,
                decoration: InputDecoration(labelText: 'Código'),
                validator: (value) => value!.isEmpty ? 'Por favor ingresa un código' : null,
                onSaved: (value) => codigo = value!,
              ),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Por favor ingresa un email' : null,
                onSaved: (value) => email = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.alumno == null ? 'Crear' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
