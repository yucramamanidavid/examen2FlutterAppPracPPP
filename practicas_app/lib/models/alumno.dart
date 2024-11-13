class Alumno {
  final int id;
  final String nombre;
  final String codigo;
  final String email;

  Alumno({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.email,
  });

  // Método para convertir un JSON en una instancia de Alumno
  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      email: json['email'],
    );
  }

  // Método para convertir una instancia de Alumno en un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'email': email,
    };
  }
}
