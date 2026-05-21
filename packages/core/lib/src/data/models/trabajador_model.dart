import '../../domain/entities/trabajador_entity.dart';

// Modelo Trabajador para Firestore
class TrabajadorModel extends TrabajadorEntity {
  TrabajadorModel({
    required String id,
    required String nombreCompleto,
    required String dni,
    required String cargo,
    required String correo,
    required String idSede,
    required DateTime creadoEn,
    required bool activo,
  }) : super(
         id: id,
         nombreCompleto: nombreCompleto,
         dni: dni,
         cargo: cargo,
         correo: correo,
         idSede: idSede,
         creadoEn: creadoEn,
         activo: activo,
       );

  factory TrabajadorModel.fromMap(Map<String, dynamic> data, String id) {
    return TrabajadorModel(
      id: id,
      nombreCompleto: data['nombreCompleto'] ?? '',
      dni: data['dni'] ?? '',
      cargo: data['cargo'] ?? '',
      correo: data['correo'] ?? '',
      idSede: data['idSede'] ?? '',
      creadoEn: (data['creadoEn'] as dynamic)?.toDate() ?? DateTime.now(),
      activo: data['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreCompleto': nombreCompleto,
      'dni': dni,
      'cargo': cargo,
      'correo': correo,
      'idSede': idSede,
      'creadoEn': creadoEn,
      'activo': activo,
    };
  }

  factory TrabajadorModel.fromEntity(TrabajadorEntity entity) {
    return TrabajadorModel(
      id: entity.id,
      nombreCompleto: entity.nombreCompleto,
      dni: entity.dni,
      cargo: entity.cargo,
      correo: entity.correo,
      idSede: entity.idSede,
      creadoEn: entity.creadoEn,
      activo: entity.activo,
    );
  }

  TrabajadorEntity toEntity() {
    return TrabajadorEntity(
      id: id,
      nombreCompleto: nombreCompleto,
      dni: dni,
      cargo: cargo,
      correo: correo,
      idSede: idSede,
      creadoEn: creadoEn,
      activo: activo,
    );
  }
}
