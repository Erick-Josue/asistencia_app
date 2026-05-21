// Entidad Asistencia con los 4 registros obligatorios
class AsistenciaEntity {
  final String id;
  final String idTrabajador;
  final String dni;
  final String nombreTrabajador;
  final String idSede;
  final String nombreSede;
  final DateTime fecha;
  
  // Cuatro marcas obligatorias del día
  final DateTime? horaInicio;           // Marca 1
  final DateTime? horaReceso;           // Marca 2
  final DateTime? horaFinReceso;        // Marca 3
  final DateTime? horaSalida;           // Marca 4

  AsistenciaEntity({
    required this.id,
    required this.idTrabajador,
    required this.dni,
    required this.nombreTrabajador,
    required this.idSede,
    required this.nombreSede,
    required this.fecha,
    this.horaInicio,
    this.horaReceso,
    this.horaFinReceso,
    this.horaSalida,
  });

  // Obtener el número de marcas completadas
  int get marcasCompletadas {
    int count = 0;
    if (horaInicio != null) count++;
    if (horaReceso != null) count++;
    if (horaFinReceso != null) count++;
    if (horaSalida != null) count++;
    return count;
  }

  // Verificar si el día está completo
  bool get estaCompleto => marcasCompletadas == 4;

  // Obtener la próxima marca esperada
  String get proximaMarca {
    if (horaInicio == null) return 'Hora de Inicio';
    if (horaReceso == null) return 'Hora de Receso';
    if (horaFinReceso == null) return 'Fin de Receso';
    if (horaSalida == null) return 'Hora de Salida';
    return 'Completo';
  }

  AsistenciaEntity copyWith({
    String? id,
    String? idTrabajador,
    String? dni,
    String? nombreTrabajador,
    String? idSede,
    String? nombreSede,
    DateTime? fecha,
    DateTime? horaInicio,
    DateTime? horaReceso,
    DateTime? horaFinReceso,
    DateTime? horaSalida,
  }) {
    return AsistenciaEntity(
      id: id ?? this.id,
      idTrabajador: idTrabajador ?? this.idTrabajador,
      dni: dni ?? this.dni,
      nombreTrabajador: nombreTrabajador ?? this.nombreTrabajador,
      idSede: idSede ?? this.idSede,
      nombreSede: nombreSede ?? this.nombreSede,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaReceso: horaReceso ?? this.horaReceso,
      horaFinReceso: horaFinReceso ?? this.horaFinReceso,
      horaSalida: horaSalida ?? this.horaSalida,
    );
  }
}
