// Eventos para el BLoC de autenticación de sede

abstract class AuthSedeEvent {
  const AuthSedeEvent();
}

/// Evento para login de sede
class LoginSedeEvent extends AuthSedeEvent {
  final String correo;
  final String contrasena;

  const LoginSedeEvent({
    required this.correo,
    required this.contrasena,
  });
}

/// Evento para verificar sesión
class VerificarSesionEvent extends AuthSedeEvent {
  const VerificarSesionEvent();
}

/// Evento para logout
class LogoutSedeEvent extends AuthSedeEvent {
  const LogoutSedeEvent();
}

/// Evento para registrar nueva sede
class RegistrarSedeEvent extends AuthSedeEvent {
  final String correo;
  final String contrasena;
  final String nombreSede;
  final String direccion;
  final String idSede;

  const RegistrarSedeEvent({
    required this.correo,
    required this.contrasena,
    required this.nombreSede,
    required this.direccion,
    required this.idSede,
  });
}
