import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asistencia_core/asistencia_core.dart';
import 'auth_sede_event.dart';
import 'auth_sede_state.dart';

/// BLoC para gestionar autenticación de sedes
class AuthSedeBloc extends Bloc<AuthSedeEvent, AuthSedeState> {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthSedeBloc({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const AuthSedeInitial()) {
    on<LoginSedeEvent>(_onLoginSede);
    on<VerificarSesionEvent>(_onVerificarSesion);
    on<LogoutSedeEvent>(_onLogoutSede);
    on<RegistrarSedeEvent>(_onRegistrarSede);
  }

  /// Login de sede
  Future<void> _onLoginSede(
    LoginSedeEvent event,
    Emitter<AuthSedeState> emit,
  ) async {
    emit(const AuthSedeCargando());

    try {
      // Autenticar usuario en Firebase
      final userCredential = await _authService.loginUser(
        correo: event.correo,
        contrasena: event.contrasena,
      );

      final usuarioId = userCredential.user!.uid;
      final sede = await _firestoreService.obtenerSede(usuarioId);

      if (sede == null) {
        emit(const AuthSedeError(
            'No existe una sede registrada para esta cuenta'));
        return;
      }

      emit(
        AuthSedeAutenticado(
          usuarioId: usuarioId,
          correo: sede.correo.isEmpty ? event.correo : sede.correo,
          nombreSede: sede.nombre,
          direccionSede: sede.direccion,
          idSede: sede.idSede,
        ),
      );
    } catch (e) {
      emit(AuthSedeError(e.toString()));
    }
  }

  /// Registrar nueva sede
  Future<void> _onRegistrarSede(
    RegistrarSedeEvent event,
    Emitter<AuthSedeState> emit,
  ) async {
    emit(const AuthSedeCargando());

    try {
      // Registrar usuario en Firebase
      final userCredential = await _authService.registerUser(
        correo: event.correo,
        contrasena: event.contrasena,
      );

      final usuarioId = userCredential.user!.uid;

      await _firestoreService.crearCuenta(
        usuarioId: usuarioId,
        correo: event.correo,
        tipo: 'tienda',
      );

      // Guardar datos de la sede en Firestore
      final sedeModel = SedeModel(
        id: usuarioId,
        nombre: event.nombreSede,
        direccion: event.direccion,
        correo: event.correo,
        idSede: event.idSede,
        creadaEn: DateTime.now(),
        usuarioId: usuarioId,
      );

      await _firestoreService.crearSede(usuarioId, sedeModel);

      emit(
        AuthSedeAutenticado(
          usuarioId: usuarioId,
          correo: event.correo,
          nombreSede: event.nombreSede,
          direccionSede: event.direccion,
          idSede: event.idSede,
        ),
      );
    } catch (e) {
      emit(AuthSedeError(e.toString()));
    }
  }

  /// Verificar si hay sesión activa
  Future<void> _onVerificarSesion(
    VerificarSesionEvent event,
    Emitter<AuthSedeState> emit,
  ) async {
    emit(const VerificandoSesion());

    try {
      if (_authService.isAuthenticated()) {
        final usuarioId = _authService.getCurrentUserId()!;
        final correo = _authService.getCurrentUserEmail()!;

        // Obtener datos de la sede
        final sede = await _firestoreService.obtenerSede(usuarioId);

        if (sede != null) {
          emit(
            AuthSedeAutenticado(
              usuarioId: usuarioId,
              correo: sede.correo.isEmpty ? correo : sede.correo,
              nombreSede: sede.nombre,
              direccionSede: sede.direccion,
              idSede: sede.idSede,
            ),
          );
        } else {
          emit(const AuthSedeNoAutenticado());
        }
      } else {
        emit(const AuthSedeNoAutenticado());
      }
    } catch (e) {
      emit(AuthSedeError(e.toString()));
    }
  }

  /// Logout
  Future<void> _onLogoutSede(
    LogoutSedeEvent event,
    Emitter<AuthSedeState> emit,
  ) async {
    try {
      await _authService.logout();
      emit(const AuthSedeNoAutenticado());
    } catch (e) {
      emit(AuthSedeError(e.toString()));
    }
  }
}
