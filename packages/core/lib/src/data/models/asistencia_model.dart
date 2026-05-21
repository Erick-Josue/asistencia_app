import '../../domain/entities/asistencia_entity.dart';

// Modelo Asistencia para Firestore
class AsistenciaModel extends AsistenciaEntity {
  AsistenciaModel({
    required String id,
    required String idTrabajador,
    required String dni,
    required String nombreTrabajador,
    required String idSede,
    required String nombreSede,
    required DateTime fecha,
    DateTime? horaInicio,
    DateTime? horaReceso,
    DateTime? horaFinReceso,
    DateTime? horaSalida,
  }) : super(
         id: id,
         idTrabajador: idTrabajador,
         dni: dni,
         nombreTrabajador: nombreTrabajador,
         idSede: idSede,
         nombreSede: nombreSede,
         fecha: fecha,
         horaInicio: horaInicio,
         horaReceso: horaReceso,
         horaFinReceso: horaFinReceso,
         horaSalida: horaSalida,
       );

  factory AsistenciaModel.fromMap(Map<String, dynamic> data, String id) {
    return AsistenciaModel(
      id: id,
      idTrabajador: data['idTrabajador'] ?? '',
      dni: data['dni'] ?? '',
      nombreTrabajador: data['nombreTrabajador'] ?? '',
      idSede: data['idSede'] ?? '',
      nombreSede: data['nombreSede'] ?? '',
      fecha: (data['fecha'] as dynamic)?.toDate() ?? DateTime.now(),
      horaInicio: (data['horaInicio'] as dynamic)?.toDate(),
      horaReceso: (data['horaReceso'] as dynamic)?.toDate(),
      horaFinReceso: (data['horaFinReceso'] as dynamic)?.toDate(),
      horaSalida: (data['horaSalida'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idTrabajador': idTrabajador,
      'dni': dni,
      'nombreTrabajador': nombreTrabajador,
      'idSede': idSede,
      'nombreSede': nombreSede,
      'fecha': fecha,
      'horaInicio': horaInicio,
      'horaReceso': horaReceso,
      'horaFinReceso': horaFinReceso,
      'horaSalida': horaSalida,
    };
  }

  factory AsistenciaModel.fromEntity(AsistenciaEntity entity) {
    return AsistenciaModel(
      id: entity.id,
      idTrabajador: entity.idTrabajador,
      dni: entity.dni,
      nombreTrabajador: entity.nombreTrabajador,
      idSede: entity.idSede,
      nombreSede: entity.nombreSede,
      fecha: entity.fecha,
      horaInicio: entity.horaInicio,
      horaReceso: entity.horaReceso,
      horaFinReceso: entity.horaFinReceso,
      horaSalida: entity.horaSalida,
    );
  }

  AsistenciaEntity toEntity() {
    return AsistenciaEntity(
      id: id,
      idTrabajador: idTrabajador,
      dni: dni,
      nombreTrabajador: nombreTrabajador,
      idSede: idSede,
      nombreSede: nombreSede,
      fecha: fecha,
      horaInicio: horaInicio,
      horaReceso: horaReceso,
      horaFinReceso: horaFinReceso,
      horaSalida: horaSalida,
    );
  }

  @override
  AsistenciaModel copyWith({
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
    return AsistenciaModel(
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
