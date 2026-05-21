// Entidad Usuario (para autenticación)
class UsuarioEntity {
  final String id;
  final String correo;
  final String nombre;
  final String tipo; // 'sede' o 'trabajador'
  final bool esAutenticado;

  UsuarioEntity({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.tipo,
    required this.esAutenticado,
  });

  UsuarioEntity copyWith({
    String? id,
    String? correo,
    String? nombre,
    String? tipo,
    bool? esAutenticado,
  }) {
    return UsuarioEntity(
      id: id ?? this.id,
      correo: correo ?? this.correo,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      esAutenticado: esAutenticado ?? this.esAutenticado,
    );
  }
}
