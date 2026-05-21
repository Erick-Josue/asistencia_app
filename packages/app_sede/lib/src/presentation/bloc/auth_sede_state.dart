// Estados para el BLoC de autenticación de sede

abstract class AuthSedeState {
  const AuthSedeState();
}

/// Estado inicial
class AuthSedeInitial extends AuthSedeState {
  const AuthSedeInitial();
}

/// Verificando sesión
class VerificandoSesion extends AuthSedeState {
  const VerificandoSesion();
}

/// Usuario autenticado
class AuthSedeAutenticado extends AuthSedeState {
  final String usuarioId;
  final String correo;
  final String nombreSede;
  final String idSede;

  const AuthSedeAutenticado({
    required this.usuarioId,
    required this.correo,
    required this.nombreSede,
    required this.idSede,
  });
}

/// Usuario no autenticado
class AuthSedeNoAutenticado extends AuthSedeState {
  const AuthSedeNoAutenticado();
}

/// Error de autenticación
class AuthSedeError extends AuthSedeState {
  final String mensaje;

  const AuthSedeError(this.mensaje);
}

/// Cargando
class AuthSedeCargando extends AuthSedeState {
  const AuthSedeCargando();
}
