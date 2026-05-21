import 'package:firebase_auth/firebase_auth.dart';

/// Servicio de autenticación Firebase
/// Gestiona login, registro y sesiones
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  /// Registro de usuario
  Future<UserCredential> registerUser({
    required String correo,
    required String contrasena,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Login de usuario
  Future<UserCredential> loginUser({
    required String correo,
    required String contrasena,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Resetear contraseña
  Future<void> resetPassword(String correo) async {
    try {
      await _auth.sendPasswordResetEmail(email: correo);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Manejar errores de autenticación
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'email-already-in-use':
        return 'El correo ya está registrado.';
      case 'user-not-found':
        return 'Usuario no encontrado.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'Correo inválido.';
      case 'operation-not-allowed':
        return 'Operación no permitida.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }

  /// Verificar si el usuario está autenticado
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Obtener el ID del usuario actual
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Obtener el correo del usuario actual
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }
}
