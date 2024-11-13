class AlumnoConTutor {
  final int alumnoId;
  final String alumnoNombre;
  final String? tutorNombre;

  AlumnoConTutor({
    required this.alumnoId,
    required this.alumnoNombre,
    this.tutorNombre,
  });

  factory AlumnoConTutor.fromJson(Map<String, dynamic> json) {
    return AlumnoConTutor(
      alumnoId: json['alumno_id'],
      alumnoNombre: json['alumno_nombre'],
      tutorNombre: json['tutor_nombre'],
    );
  }
}
