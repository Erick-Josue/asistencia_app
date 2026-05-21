import '../../domain/entities/sede_entity.dart';

// Modelo Sede para Firestore
class SedeModel extends SedeEntity {
  SedeModel({
    required String id,
    required String nombre,
    required String direccion,
    required String idSede,
    required DateTime creadaEn,
    required String usuarioId,
  }) : super(
         id: id,
         nombre: nombre,
         direccion: direccion,
         idSede: idSede,
         creadaEn: creadaEn,
         usuarioId: usuarioId,
       );

  factory SedeModel.fromMap(Map<String, dynamic> data, String id) {
    return SedeModel(
      id: id,
      nombre: data['nombre'] ?? '',
      direccion: data['direccion'] ?? '',
      idSede: data['idSede'] ?? '',
      creadaEn: (data['creadaEn'] as dynamic)?.toDate() ?? DateTime.now(),
      usuarioId: data['usuarioId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'idSede': idSede,
      'creadaEn': creadaEn,
      'usuarioId': usuarioId,
    };
  }

  factory SedeModel.fromEntity(SedeEntity entity) {
    return SedeModel(
      id: entity.id,
      nombre: entity.nombre,
      direccion: entity.direccion,
      idSede: entity.idSede,
      creadaEn: entity.creadaEn,
      usuarioId: entity.usuarioId,
    );
  }

  SedeEntity toEntity() {
    return SedeEntity(
      id: id,
      nombre: nombre,
      direccion: direccion,
      idSede: idSede,
      creadaEn: creadaEn,
      usuarioId: usuarioId,
    );
  }
}
