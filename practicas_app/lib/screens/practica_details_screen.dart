import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/practica.dart';
import '../services/api_service.dart';

class PracticaDetailsScreen extends StatefulWidget {
  final Practica practica;

  PracticaDetailsScreen({required this.practica});

  @override
  _PracticaDetailsScreenState createState() => _PracticaDetailsScreenState();
}

class _PracticaDetailsScreenState extends State<PracticaDetailsScreen> {
  final ApiService apiService = ApiService();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _cambiarEstadoPractica(String nuevoEstado) async {
    try {
      if (nuevoEstado == 'aprobado') {
        await apiService.aprobarPractica(widget.practica.id);
      } else if (nuevoEstado == 'rechazado') {
        await apiService.rechazarPractica(widget.practica.id);
      }

      setState(() {
        widget.practica.estado = nuevoEstado;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Práctica $nuevoEstado exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar estado de la práctica: $e')),
      );
    }
  }

  Future<void> _uploadEvidencia(int practicaId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      try {
        await apiService.subirEvidencia(practicaId, file);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Evidencia subida con éxito.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir evidencia: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se seleccionó ningún archivo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final practica = widget.practica;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de ${practica.titulo}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              practica.titulo,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Empresa: ${practica.empresa}'),
            SizedBox(height: 10),
            Text('Descripción: ${practica.descripcion}'),
            SizedBox(height: 10),
            Text('Fecha de inicio: ${dateFormat.format(practica.fechaInicio)}'),
            Text('Fecha de fin: ${dateFormat.format(practica.fechaFin)}'),
            SizedBox(height: 10),
            Text('Estado: ${practica.estado}'),

            // Botones para el admin o tutor
            if (practica.estado == 'pendiente') ...[
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _cambiarEstadoPractica('aprobado'),
                child: Text('Aprobar Práctica'),
              ),
              ElevatedButton(
                onPressed: () => _cambiarEstadoPractica('rechazado'),
                child: Text('Rechazar Práctica'),
              ),
            ],

            // Subida de evidencia solo si está aprobado
            if (practica.estado == 'aprobado') ...[
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _uploadEvidencia(practica.id),
                child: Text('Subir Evidencia'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
