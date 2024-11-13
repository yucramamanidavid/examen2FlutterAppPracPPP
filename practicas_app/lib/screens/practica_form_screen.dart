import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/practica.dart';
import '../services/api_service.dart';

class PracticaFormScreen extends StatefulWidget {
  final Practica? practica;
  final int alumnoId; // Se agrega el alumnoId como parámetro obligatorio

  PracticaFormScreen({this.practica, required this.alumnoId});

  @override
  _PracticaFormScreenState createState() => _PracticaFormScreenState();
}

class _PracticaFormScreenState extends State<PracticaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String titulo;
  late String descripcion;
  late String empresa;
  late DateTime fechaInicio;
  late DateTime fechaFin;
  String estado = 'pendiente';
  PlatformFile? selectedFile;

  @override
  void initState() {
    super.initState();
    titulo = widget.practica?.titulo ?? '';
    descripcion = widget.practica?.descripcion ?? '';
    empresa = widget.practica?.empresa ?? '';
    fechaInicio = widget.practica?.fechaInicio ?? DateTime.now();
    fechaFin = widget.practica?.fechaFin ?? DateTime.now();
    estado = widget.practica?.estado ?? 'pendiente';
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (fechaFin.isBefore(fechaInicio)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La fecha de fin debe ser igual o posterior a la fecha de inicio')),
        );
        return;
      }

      Practica practica = Practica(
        id: widget.practica?.id ?? 0,
        titulo: titulo,
        descripcion: descripcion,
        empresa: empresa,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        estado: estado,
        alumnoId: widget.alumnoId, // Asignamos el alumnoId
      );

      try {
        if (widget.practica == null) {
          await ApiService().crearPractica(practica);
        } else {
          await ApiService().actualizarPractica(practica.id, practica);
        }

        if (selectedFile != null) {
          await ApiService().subirEvidencia(practica.id, selectedFile!);
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el formulario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.practica == null ? 'Nueva Práctica' : 'Editar Práctica'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: titulo,
                  decoration: InputDecoration(labelText: 'Título'),
                  validator: (value) => value!.isEmpty ? 'Por favor ingresa un título' : null,
                  onSaved: (value) => titulo = value!,
                ),
                TextFormField(
                  initialValue: descripcion,
                  decoration: InputDecoration(labelText: 'Descripción'),
                  validator: (value) => value!.isEmpty ? 'Por favor ingresa una descripción' : null,
                  onSaved: (value) => descripcion = value!,
                ),
                TextFormField(
                  initialValue: empresa,
                  decoration: InputDecoration(labelText: 'Empresa'),
                  validator: (value) => value!.isEmpty ? 'Por favor ingresa una empresa' : null,
                  onSaved: (value) => empresa = value!,
                ),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Fecha de Inicio'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: fechaInicio,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        fechaInicio = pickedDate;
                      });
                    }
                  },
                  controller: TextEditingController(
                    text: fechaInicio.toLocal().toString().split(' ')[0],
                  ),
                ),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Fecha de Fin'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: fechaFin,
                      firstDate: fechaInicio,
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        fechaFin = pickedDate;
                      });
                    }
                  },
                  controller: TextEditingController(
                    text: fechaFin.toLocal().toString().split(' ')[0],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selectFile,
                  child: Text(selectedFile != null ? 'Archivo seleccionado: ${selectedFile!.name}' : 'Seleccionar Archivo de Evidencia'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.practica == null ? 'Crear' : 'Actualizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
