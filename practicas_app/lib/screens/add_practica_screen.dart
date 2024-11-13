import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/practica.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'package:intl/intl.dart';

class AddPracticaScreen extends StatefulWidget {
  @override
  _AddPracticaScreenState createState() => _AddPracticaScreenState();
}

class _AddPracticaScreenState extends State<AddPracticaScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController empresaController = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  DateTime? fechaInicio;
  DateTime? fechaFin;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _selectFechaInicio(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != fechaInicio) {
      setState(() {
        fechaInicio = picked;
      });
    }
  }

  Future<void> _selectFechaFin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaFin ?? DateTime.now(),
      firstDate: fechaInicio ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != fechaFin) {
      setState(() {
        fechaFin = picked;
      });
    }
  }

  Future<void> _submitPractica() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        empresaController.text.isEmpty ||
        fechaInicio == null ||
        fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final alumnoId = userProvider.alumnoId;

    if (alumnoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No se pudo obtener el ID del alumno')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    Practica practica = Practica(
      id: 0,
      titulo: titleController.text,
      descripcion: descriptionController.text,
      empresa: empresaController.text,
      fechaInicio: fechaInicio!,
      fechaFin: fechaFin!,
      estado: 'pendiente',
      alumnoId: alumnoId,
    );

    try {
      await apiService.crearPractica(practica);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Práctica añadida con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir práctica: $e')),
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
      appBar: AppBar(title: Text('Agregar Práctica')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: empresaController,
              decoration: InputDecoration(labelText: 'Empresa'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    fechaInicio != null
                        ? 'Fecha de Inicio: ${dateFormat.format(fechaInicio!)}'
                        : 'Seleccionar Fecha de Inicio',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectFechaInicio(context),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    fechaFin != null
                        ? 'Fecha de Fin: ${dateFormat.format(fechaFin!)}'
                        : 'Seleccionar Fecha de Fin',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectFechaFin(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submitPractica,
              child: Text('Agregar Práctica'),
            ),
          ],
        ),
      ),
    );
  }
}
