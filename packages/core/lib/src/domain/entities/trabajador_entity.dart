// Entidad Trabajador
class TrabajadorEntity {
  final String id;
  final String nombreCompleto;
  final String dni;
  final String cargo;
  final String correo;
  final String idSede;
  final DateTime creadoEn;
  final bool activo;

  TrabajadorEntity({
    required this.id,
    required this.nombreCompleto,
    required this.dni,
    required this.cargo,
    required this.correo,
    required this.idSede,
    required this.creadoEn,
    required this.activo,
  });

  TrabajadorEntity copyWith({
    String? id,
    String? nombreCompleto,
    String? dni,
    String? cargo,
    String? correo,
    String? idSede,
    DateTime? creadoEn,
    bool? activo,
  }) {
    return TrabajadorEntity(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      dni: dni ?? this.dni,
      cargo: cargo ?? this.cargo,
      correo: correo ?? this.correo,
      idSede: idSede ?? this.idSede,
      creadoEn: creadoEn ?? this.creadoEn,
      activo: activo ?? this.activo,
    );
  }
}
