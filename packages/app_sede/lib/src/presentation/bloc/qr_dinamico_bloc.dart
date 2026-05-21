import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asistencia_core/asistencia_core.dart';
import 'qr_dinamico_event.dart';
import 'qr_dinamico_state.dart';

/// BLoC para gestionar la generación de QR dinámico
class QRDinamicoBloc extends Bloc<QRDinamicoEvent, QRDinamicoState> {
  final FirestoreService _firestoreService;

  Timer? _qrTimer;
  int _segundosRestantes = 0;
  int _totalAsistenciasDelDia = 0;

  QRDinamicoBloc({
    required FirestoreService firestoreService,
  })  : _firestoreService = firestoreService,
        super(const QRDinamicoInitial()) {
    on<GenerarQREvent>(_onGenerarQR);
    on<IniciarQRAutomaticoEvent>(_onIniciarQRAutomatico);
    on<DetenerQRAutomaticoEvent>(_onDetenerQRAutomatico);
  }

  /// Generar un único QR
  Future<void> _onGenerarQR(
    GenerarQREvent event,
    Emitter<QRDinamicoState> emit,
  ) async {
    emit(const QRDinamicoGenerando());
    try {
      final qrEncriptado = EncryptionService.encryptQRData(
        idSede: event.idSede,
        nombreSede: event.nombreSede,
      );

      emit(
        QRDinamicoGenerado(
          qrEncriptado: qrEncriptado,
          idSede: event.idSede,
          nombreSede: event.nombreSede,
          generadoEn: DateTime.now(),
          tiempoRestante: 30,
        ),
      );
    } catch (e) {
      emit(QRDinamicoError('Error generando QR: ${e.toString()}'));
    }
  }

  /// Iniciar generación automática de QR cada X segundos
  Future<void> _onIniciarQRAutomatico(
    IniciarQRAutomaticoEvent event,
    Emitter<QRDinamicoState> emit,
  ) async {
    // Detener timer anterior si existe
    _qrTimer?.cancel();

    _segundosRestantes = event.intervaloSegundos;

    // Generar QR inicial
    final qrEncriptado = EncryptionService.encryptQRData(
      idSede: event.idSede,
      nombreSede: event.nombreSede,
    );

    emit(
      QRAutomaticoEnProgreso(
        qrEncriptado: qrEncriptado,
        idSede: event.idSede,
        nombreSede: event.nombreSede,
        tiempoRestante: _segundosRestantes,
        totalRegistros: _totalAsistenciasDelDia,
      ),
    );

    // Timer para generar nuevo QR cada intervalo
    _qrTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        _segundosRestantes--;

        if (_segundosRestantes <= 0) {
          // Generar nuevo QR
          final nuevoQR = EncryptionService.encryptQRData(
            idSede: event.idSede,
            nombreSede: event.nombreSede,
          );

          // Obtener cantidad de asistencias del día
          try {
            final hoy = DateTime.now();
            final asistencias =
                await _firestoreService.obtenerAsistenciasSedeRango(
              idSede: event.idSede,
              fechaInicio: DateTime(hoy.year, hoy.month, hoy.day),
              fechaFin: DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59),
            );
            _totalAsistenciasDelDia = asistencias.length;
          } catch (e) {
            // Keep QR rotation alive even if the live counter cannot refresh.
          }

          _segundosRestantes = event.intervaloSegundos;

          emit(
            QRAutomaticoEnProgreso(
              qrEncriptado: nuevoQR,
              idSede: event.idSede,
              nombreSede: event.nombreSede,
              tiempoRestante: _segundosRestantes,
              totalRegistros: _totalAsistenciasDelDia,
            ),
          );
        } else {
          // Actualizar contador de tiempo
          if (state is QRAutomaticoEnProgreso) {
            final currentState = state as QRAutomaticoEnProgreso;
            emit(
              QRAutomaticoEnProgreso(
                qrEncriptado: currentState.qrEncriptado,
                idSede: currentState.idSede,
                nombreSede: currentState.nombreSede,
                tiempoRestante: _segundosRestantes,
                totalRegistros: currentState.totalRegistros,
              ),
            );
          }
        }
      },
    );
  }

  /// Detener generación automática
  Future<void> _onDetenerQRAutomatico(
    DetenerQRAutomaticoEvent event,
    Emitter<QRDinamicoState> emit,
  ) async {
    _qrTimer?.cancel();
    emit(const QRDinamicoInitial());
  }

  @override
  Future<void> close() {
    _qrTimer?.cancel();
    return super.close();
  }
}
