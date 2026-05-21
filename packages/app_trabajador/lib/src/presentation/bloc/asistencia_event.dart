// Eventos para el BLoC de asistencia del trabajador

abstract class AsistenciaEvent {
  const AsistenciaEvent();
}

/// Escanear código QR
class EscanearQREvent extends AsistenciaEvent {
  final String codigoQREncriptado;
  final String idTrabajador;
  final String dni;
  final String nombreTrabajador;

  const EscanearQREvent({
    required this.codigoQREncriptado,
    required this.idTrabajador,
    required this.dni,
    required this.nombreTrabajador,
  });
}

/// Registrar asistencia
class RegistrarAsistenciaEvent extends AsistenciaEvent {
  final String idTrabajador;
  final String dni;
  final String nombreTrabajador;
  final String idSede;
  final String nombreSede;
  final String tipoMarca; // 'inicio', 'receso', 'fin_receso', 'salida'

  const RegistrarAsistenciaEvent({
    required this.idTrabajador,
    required this.dni,
    required this.nombreTrabajador,
    required this.idSede,
    required this.nombreSede,
    required this.tipoMarca,
  });
}

/// Cargar asistencia del día
class CargarAsistenciaDiaEvent extends AsistenciaEvent {
  final String idTrabajador;

  const CargarAsistenciaDiaEvent({required this.idTrabajador});
}

/// Cargar historial de asistencias
class CargarHistorialAsistenciasEvent extends AsistenciaEvent {
  final String idTrabajador;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const CargarHistorialAsistenciasEvent({
    required this.idTrabajador,
    required this.fechaInicio,
    required this.fechaFin,
  });
}
