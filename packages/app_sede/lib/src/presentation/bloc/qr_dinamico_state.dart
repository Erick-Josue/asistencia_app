// Estados para el BLoC de QR dinámico

abstract class QRDinamicoState {
  const QRDinamicoState();
}

/// Estado inicial
class QRDinamicoInitial extends QRDinamicoState {
  const QRDinamicoInitial();
}

/// Generando QR
class QRDinamicoGenerando extends QRDinamicoState {
  const QRDinamicoGenerando();
}

/// QR generado exitosamente
class QRDinamicoGenerado extends QRDinamicoState {
  final String qrEncriptado; // Datos encriptados del QR
  final String idSede;
  final String nombreSede;
  final DateTime generadoEn;
  final int tiempoRestante; // Segundos hasta el próximo cambio

  const QRDinamicoGenerado({
    required this.qrEncriptado,
    required this.idSede,
    required this.nombreSede,
    required this.generadoEn,
    required this.tiempoRestante,
  });
}

/// Error generando QR
class QRDinamicoError extends QRDinamicoState {
  final String mensaje;

  const QRDinamicoError(this.mensaje);
}

/// QR Automático en progreso
class QRAutomaticoEnProgreso extends QRDinamicoState {
  final String qrEncriptado;
  final String idSede;
  final String nombreSede;
  final int tiempoRestante;
  final int totalRegistros; // Total de asistencias registradas en el día

  const QRAutomaticoEnProgreso({
    required this.qrEncriptado,
    required this.idSede,
    required this.nombreSede,
    required this.tiempoRestante,
    required this.totalRegistros,
  });
}
