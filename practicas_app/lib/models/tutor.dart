class Tutor {
  final int id;
  final String nombre;
  final String email;
  final String? password; // Campo opcional de contraseña

  Tutor({
    required this.id,
    required this.nombre,
    required this.email,
    this.password, // Define password como opcional
  });

  // Método para convertir el objeto en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      if (password != null) 'password': password, // Solo incluye password si no es null
    };
  }

  // Método para crear una instancia de Tutor a partir de un JSON
  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      password: json['password'], // Asigna el valor de password si está presente
    );
  }
}
