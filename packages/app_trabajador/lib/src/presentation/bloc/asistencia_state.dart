import 'package:asistencia_core/asistencia_core.dart';

// Estados para el BLoC de asistencia

abstract class AsistenciaState {
  const AsistenciaState();
}

/// Estado inicial
class AsistenciaInitial extends AsistenciaState {
  const AsistenciaInitial();
}

/// Cargando
class AsistenciaCargando extends AsistenciaState {
  const AsistenciaCargando();
}

/// QR validado correctamente
class QRValido extends AsistenciaState {
  final String idSede;
  final String nombreSede;
  final String proximaMarca;

  const QRValido({
    required this.idSede,
    required this.nombreSede,
    required this.proximaMarca,
  });
}

/// QR inválido o expirado
class QRInvalido extends AsistenciaState {
  final String mensaje;

  const QRInvalido(this.mensaje);
}

/// Asistencia registrada exitosamente
class AsistenciaRegistrada extends AsistenciaState {
  final AsistenciaEntity asistencia;
  final String tipoMarcaRegistrada;
  final String proximaMarca;
  final bool diarioCompleto;

  const AsistenciaRegistrada({
    required this.asistencia,
    required this.tipoMarcaRegistrada,
    required this.proximaMarca,
    required this.diarioCompleto,
  });
}

/// Error registrando asistencia
class ErrorAsistencia extends AsistenciaState {
  final String mensaje;

  const ErrorAsistencia(this.mensaje);
}

/// Asistencia del día cargada
class AsistenciaDiaLoaded extends AsistenciaState {
  final AsistenciaEntity asistencia;
  final String proximaMarca;
  final int marcasCompletadas;
  final bool diarioCompleto;

  const AsistenciaDiaLoaded({
    required this.asistencia,
    required this.proximaMarca,
    required this.marcasCompletadas,
    required this.diarioCompleto,
  });
}

/// Historial de asistencias cargado
class HistorialAsistenciaLoaded extends AsistenciaState {
  final List<AsistenciaEntity> asistencias;
  final int totalDias;
  final int diasCompletos;
  final int diasIncompletos;

  const HistorialAsistenciaLoaded({
    required this.asistencias,
    required this.totalDias,
    required this.diasCompletos,
    required this.diasIncompletos,
  });
}
