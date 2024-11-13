class Practica {
  final int id;
  final String titulo;
  final String descripcion;
  final String empresa;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  String estado; // Quitar 'final' de estado
  final int alumnoId;

  Practica({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.empresa,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado, // Estado ahora es modificable
    required this.alumnoId,
  });

  // Convertir de JSON a Practica
  factory Practica.fromJson(Map<String, dynamic> json) {
    return Practica(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      empresa: json['empresa'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      estado: json['estado'],
      alumnoId: json['alumno_id'],
    );
  }

  // Convertir de Practica a JSON
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'empresa': empresa,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'estado': estado,
      'alumno_id': alumnoId,
    };
  }
}
