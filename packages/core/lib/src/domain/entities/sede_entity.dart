// Entidad Sede
class SedeEntity {
  final String id;
  final String nombre;
  final String direccion;
  final String idSede;
  final DateTime creadaEn;
  final String usuarioId; // ID del usuario autenticado

  SedeEntity({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.idSede,
    required this.creadaEn,
    required this.usuarioId,
  });

  SedeEntity copyWith({
    String? id,
    String? nombre,
    String? direccion,
    String? idSede,
    DateTime? creadaEn,
    String? usuarioId,
  }) {
    return SedeEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      idSede: idSede ?? this.idSede,
      creadaEn: creadaEn ?? this.creadaEn,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }
}
