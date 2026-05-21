// Eventos para el BLoC de autenticación del trabajador

abstract class AuthTrabajadorEvent {
  const AuthTrabajadorEvent();
}

/// Registro de trabajador
class RegistroTrabajadorEvent extends AuthTrabajadorEvent {
  final String nombreCompleto;
  final String dni;
  final String cargo;
  final String correo;
  final String contrasena;
  final String idSede;

  const RegistroTrabajadorEvent({
    required this.nombreCompleto,
    required this.dni,
    required this.cargo,
    required this.correo,
    required this.contrasena,
    required this.idSede,
  });
}

/// Login de trabajador
class LoginTrabajadorEvent extends AuthTrabajadorEvent {
  final String correo;
  final String contrasena;

  const LoginTrabajadorEvent({
    required this.correo,
    required this.contrasena,
  });
}

/// Verificar sesión
class VerificarSesionTrabajadorEvent extends AuthTrabajadorEvent {
  const VerificarSesionTrabajadorEvent();
}

/// Logout
class LogoutTrabajadorEvent extends AuthTrabajadorEvent {
  const LogoutTrabajadorEvent();
}
