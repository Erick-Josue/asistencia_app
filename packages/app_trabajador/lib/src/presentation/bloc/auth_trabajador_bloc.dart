import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asistencia_core/asistencia_core.dart';
import 'auth_trabajador_event.dart';
import 'auth_trabajador_state.dart';

/// BLoC para gestionar autenticación de trabajadores
class AuthTrabajadorBloc
    extends Bloc<AuthTrabajadorEvent, AuthTrabajadorState> {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthTrabajadorBloc({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const AuthTrabajadorInitial()) {
    on<RegistroTrabajadorEvent>(_onRegistroTrabajador);
    on<LoginTrabajadorEvent>(_onLoginTrabajador);
    on<VerificarSesionTrabajadorEvent>(_onVerificarSesion);
    on<LogoutTrabajadorEvent>(_onLogoutTrabajador);
  }

  /// Registrar trabajador
  Future<void> _onRegistroTrabajador(
    RegistroTrabajadorEvent event,
    Emitter<AuthTrabajadorState> emit,
  ) async {
    emit(const AuthTrabajadorCargando());

    try {
      // Registrar usuario en Firebase Auth
      final userCredential = await _authService.registerUser(
        correo: event.correo,
        contrasena: event.contrasena,
      );

      final usuarioId = userCredential.user!.uid;

      await _firestoreService.crearCuenta(
        usuarioId: usuarioId,
        correo: event.correo,
        tipo: 'trabajador',
      );

      // Guardar datos del trabajador en Firestore
      final trabajadorModel = TrabajadorModel(
        id: usuarioId,
        nombreCompleto: event.nombreCompleto,
        dni: event.dni,
        cargo: event.cargo,
        correo: event.correo,
        idSede: event.idSede,
        creadoEn: DateTime.now(),
        activo: true,
      );

      await _firestoreService.registrarTrabajador(usuarioId, trabajadorModel);

      emit(
        AuthTrabajadorAutenticado(
          usuarioId: usuarioId,
          nombreCompleto: event.nombreCompleto,
          dni: event.dni,
          cargo: event.cargo,
          correo: event.correo,
          idSede: event.idSede,
        ),
      );
    } catch (e) {
      emit(AuthTrabajadorError(e.toString()));
    }
  }

  /// Login de trabajador
  Future<void> _onLoginTrabajador(
    LoginTrabajadorEvent event,
    Emitter<AuthTrabajadorState> emit,
  ) async {
    emit(const AuthTrabajadorCargando());

    try {
      // Autenticar en Firebase
      final userCredential = await _authService.loginUser(
        correo: event.correo,
        contrasena: event.contrasena,
      );

      final usuarioId = userCredential.user!.uid;

      // Obtener datos del trabajador desde Firestore
      final trabajador = await _firestoreService.obtenerTrabajador(usuarioId);

      if (trabajador != null) {
        emit(
          AuthTrabajadorAutenticado(
            usuarioId: usuarioId,
            nombreCompleto: trabajador.nombreCompleto,
            dni: trabajador.dni,
            cargo: trabajador.cargo,
            correo: trabajador.correo,
            idSede: trabajador.idSede,
          ),
        );
      } else {
        emit(const AuthTrabajadorError(
            'Trabajador no encontrado en la base de datos'));
      }
    } catch (e) {
      emit(AuthTrabajadorError(e.toString()));
    }
  }

  /// Verificar sesión activa
  Future<void> _onVerificarSesion(
    VerificarSesionTrabajadorEvent event,
    Emitter<AuthTrabajadorState> emit,
  ) async {
    emit(const VerificandoSesionTrabajador());

    try {
      if (_authService.isAuthenticated()) {
        final usuarioId = _authService.getCurrentUserId()!;

        // Obtener datos del trabajador
        final trabajador = await _firestoreService.obtenerTrabajador(usuarioId);

        if (trabajador != null) {
          emit(
            AuthTrabajadorAutenticado(
              usuarioId: usuarioId,
              nombreCompleto: trabajador.nombreCompleto,
              dni: trabajador.dni,
              cargo: trabajador.cargo,
              correo: trabajador.correo,
              idSede: trabajador.idSede,
            ),
          );
        } else {
          emit(const AuthTrabajadorNoAutenticado());
        }
      } else {
        emit(const AuthTrabajadorNoAutenticado());
      }
    } catch (e) {
      emit(AuthTrabajadorError(e.toString()));
    }
  }

  /// Logout
  Future<void> _onLogoutTrabajador(
    LogoutTrabajadorEvent event,
    Emitter<AuthTrabajadorState> emit,
  ) async {
    try {
      await _authService.logout();
      emit(const AuthTrabajadorNoAutenticado());
    } catch (e) {
      emit(AuthTrabajadorError(e.toString()));
    }
  }
}
