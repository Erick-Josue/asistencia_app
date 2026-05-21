import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asistencia_core/asistencia_core.dart';
import 'asistencia_event.dart';
import 'asistencia_state.dart';

/// BLoC para gestionar la asistencia del trabajador
class AsistenciaBloc extends Bloc<AsistenciaEvent, AsistenciaState> {
  final FirestoreService _firestoreService;

  AsistenciaBloc({
    required FirestoreService firestoreService,
  })  : _firestoreService = firestoreService,
        super(const AsistenciaInitial()) {
    on<EscanearQREvent>(_onEscanearQR);
    on<RegistrarAsistenciaEvent>(_onRegistrarAsistencia);
    on<CargarAsistenciaDiaEvent>(_onCargarAsistenciaDelDia);
    on<CargarHistorialAsistenciasEvent>(_onCargarHistorial);
  }

  /// Validar y procesar escaneo de QR
  Future<void> _onEscanearQR(
    EscanearQREvent event,
    Emitter<AsistenciaState> emit,
  ) async {
    emit(const AsistenciaCargando());

    try {
      // Desencriptar y validar QR
      final datosQR = EncryptionService.decryptQRData(event.codigoQREncriptado);

      if (datosQR == null) {
        emit(const QRInvalido('No se pudo desencriptar el código QR'));
        return;
      }

      // Validar que el QR sea reciente (máximo 60 segundos)
      if (!EncryptionService.isQRValid(
        encryptedData: event.codigoQREncriptado,
        maxAgeSeconds: 60,
      )) {
        emit(const QRInvalido('Código QR expirado. Solicite uno nuevo.'));
        return;
      }

      final idSede = datosQR['idSede'] as String;
      final nombreSede = datosQR['nombreSede'] as String;

      // Obtener asistencia del día
      final asistencia = await _firestoreService.obtenerAsistenciaDelDia(
        idTrabajador: event.idTrabajador,
        fecha: DateTime.now(),
      );

      String proximaMarca = 'Hora de Inicio';
      if (asistencia != null) {
        proximaMarca = asistencia.proximaMarca;
      }

      emit(
        QRValido(
          idSede: idSede,
          nombreSede: nombreSede,
          proximaMarca: proximaMarca,
        ),
      );
    } catch (e) {
      emit(ErrorAsistencia('Error procesando QR: ${e.toString()}'));
    }
  }

  /// Registrar marca de asistencia
  Future<void> _onRegistrarAsistencia(
    RegistrarAsistenciaEvent event,
    Emitter<AsistenciaState> emit,
  ) async {
    emit(const AsistenciaCargando());

    try {
      final hoy = DateTime.now();
      final ahora = DateTime.now();

      // Obtener o crear registro de asistencia del día
      var asistencia = await _firestoreService.obtenerAsistenciaDelDia(
        idTrabajador: event.idTrabajador,
        fecha: hoy,
      );

      asistencia ??= AsistenciaModel(
        id: '${event.idTrabajador}_${hoy.toIso8601String().split('T')[0]}',
        idTrabajador: event.idTrabajador,
        dni: event.dni,
        nombreTrabajador: event.nombreTrabajador,
        idSede: event.idSede,
        nombreSede: event.nombreSede,
        fecha: hoy,
      );

      // Validar orden de marcas
      final tipoMarca = event.tipoMarca;

      if (tipoMarca == 'inicio' && asistencia.horaInicio != null) {
        emit(const ErrorAsistencia('Ya registraste tu hora de inicio'));
        return;
      }

      if (tipoMarca == 'receso') {
        if (asistencia.horaInicio == null) {
          emit(const ErrorAsistencia(
              'Primero debes registrar tu hora de inicio'));
          return;
        }
        if (asistencia.horaReceso != null) {
          emit(const ErrorAsistencia('Ya registraste tu hora de receso'));
          return;
        }
      }

      if (tipoMarca == 'fin_receso') {
        if (asistencia.horaReceso == null) {
          emit(const ErrorAsistencia(
              'Primero debes registrar tu hora de receso'));
          return;
        }
        if (asistencia.horaFinReceso != null) {
          emit(const ErrorAsistencia('Ya registraste el fin de tu receso'));
          return;
        }
      }

      if (tipoMarca == 'salida') {
        if (asistencia.horaFinReceso == null) {
          emit(const ErrorAsistencia(
              'Primero debes registrar el fin de tu receso'));
          return;
        }
        if (asistencia.horaSalida != null) {
          emit(const ErrorAsistencia('Ya registraste tu hora de salida'));
          return;
        }
      }

      // Actualizar la marca correspondiente
      final asistenciaActualizada =
          _actualizarAsistencia(asistencia, tipoMarca, ahora);

      // Guardar en Firestore
      await _firestoreService.registrarAsistencia(asistenciaActualizada);

      emit(
        AsistenciaRegistrada(
          asistencia: asistenciaActualizada,
          tipoMarcaRegistrada: tipoMarca,
          proximaMarca: asistenciaActualizada.proximaMarca,
          diarioCompleto: asistenciaActualizada.estaCompleto,
        ),
      );
    } catch (e) {
      emit(ErrorAsistencia('Error registrando asistencia: ${e.toString()}'));
    }
  }

  /// Cargar asistencia del día
  Future<void> _onCargarAsistenciaDelDia(
    CargarAsistenciaDiaEvent event,
    Emitter<AsistenciaState> emit,
  ) async {
    emit(const AsistenciaCargando());

    try {
      final hoy = DateTime.now();
      var asistencia = await _firestoreService.obtenerAsistenciaDelDia(
        idTrabajador: event.idTrabajador,
        fecha: hoy,
      );

      // Si no existe, crear registro vacío
      asistencia ??= AsistenciaModel(
        id: '${event.idTrabajador}_${hoy.toIso8601String().split('T')[0]}',
        idTrabajador: event.idTrabajador,
        dni: '',
        nombreTrabajador: '',
        idSede: '',
        nombreSede: '',
        fecha: hoy,
      );

      emit(
        AsistenciaDiaLoaded(
          asistencia: asistencia,
          proximaMarca: asistencia.proximaMarca,
          marcasCompletadas: asistencia.marcasCompletadas,
          diarioCompleto: asistencia.estaCompleto,
        ),
      );
    } catch (e) {
      emit(ErrorAsistencia('Error cargando asistencia: ${e.toString()}'));
    }
  }

  /// Cargar historial de asistencias
  Future<void> _onCargarHistorial(
    CargarHistorialAsistenciasEvent event,
    Emitter<AsistenciaState> emit,
  ) async {
    emit(const AsistenciaCargando());

    try {
      final asistencias = await _firestoreService.obtenerAsistenciasRango(
        idTrabajador: event.idTrabajador,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );

      int diasCompletos = 0;
      int diasIncompletos = 0;

      for (final asistencia in asistencias) {
        if (asistencia.estaCompleto) {
          diasCompletos++;
        } else if (asistencia.marcasCompletadas > 0) {
          diasIncompletos++;
        }
      }

      emit(
        HistorialAsistenciaLoaded(
          asistencias: asistencias,
          totalDias: asistencias.length,
          diasCompletos: diasCompletos,
          diasIncompletos: diasIncompletos,
        ),
      );
    } catch (e) {
      emit(ErrorAsistencia('Error cargando historial: ${e.toString()}'));
    }
  }

  /// Actualizar asistencia con la nueva marca
  AsistenciaModel _actualizarAsistencia(
    AsistenciaModel asistencia,
    String tipoMarca,
    DateTime ahora,
  ) {
    switch (tipoMarca) {
      case 'inicio':
        return asistencia.copyWith(horaInicio: ahora);
      case 'receso':
        return asistencia.copyWith(horaReceso: ahora);
      case 'fin_receso':
        return asistencia.copyWith(horaFinReceso: ahora);
      case 'salida':
        return asistencia.copyWith(horaSalida: ahora);
      default:
        return asistencia;
    }
  }
}
