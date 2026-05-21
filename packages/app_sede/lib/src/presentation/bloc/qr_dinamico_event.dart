// Eventos para el BLoC de QR dinámico

abstract class QRDinamicoEvent {
  const QRDinamicoEvent();
}

/// Generar nuevo QR (se llama cada X segundos)
class GenerarQREvent extends QRDinamicoEvent {
  final String idSede;
  final String nombreSede;

  const GenerarQREvent({
    required this.idSede,
    required this.nombreSede,
  });
}

/// Iniciar generación automática de QR
class IniciarQRAutomaticoEvent extends QRDinamicoEvent {
  final String idSede;
  final String nombreSede;
  final int intervaloSegundos; // Intervalo de cambio del QR

  const IniciarQRAutomaticoEvent({
    required this.idSede,
    required this.nombreSede,
    this.intervaloSegundos = 30, // Cambiar QR cada 30 segundos
  });
}

/// Detener generación automática
class DetenerQRAutomaticoEvent extends QRDinamicoEvent {
  const DetenerQRAutomaticoEvent();
}
