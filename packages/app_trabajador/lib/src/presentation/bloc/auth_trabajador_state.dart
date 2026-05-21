// Estados para el BLoC de autenticación del trabajador

abstract class AuthTrabajadorState {
  const AuthTrabajadorState();
}

/// Estado inicial
class AuthTrabajadorInitial extends AuthTrabajadorState {
  const AuthTrabajadorInitial();
}

/// Verificando sesión
class VerificandoSesionTrabajador extends AuthTrabajadorState {
  const VerificandoSesionTrabajador();
}

/// Trabajador autenticado
class AuthTrabajadorAutenticado extends AuthTrabajadorState {
  final String usuarioId;
  final String nombreCompleto;
  final String dni;
  final String cargo;
  final String correo;
  final String idSede;

  const AuthTrabajadorAutenticado({
    required this.usuarioId,
    required this.nombreCompleto,
    required this.dni,
    required this.cargo,
    required this.correo,
    required this.idSede,
  });
}

/// Trabajador no autenticado
class AuthTrabajadorNoAutenticado extends AuthTrabajadorState {
  const AuthTrabajadorNoAutenticado();
}

/// Error de autenticación
class AuthTrabajadorError extends AuthTrabajadorState {
  final String mensaje;

  const AuthTrabajadorError(this.mensaje);
}

/// Cargando
class AuthTrabajadorCargando extends AuthTrabajadorState {
  const AuthTrabajadorCargando();
}
