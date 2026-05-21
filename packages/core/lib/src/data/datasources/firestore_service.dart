import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sede_model.dart';
import '../models/trabajador_model.dart';
import '../models/asistencia_model.dart';

/// Servicio de Firestore para gestionar datos
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== CUENTAS ====================

  /// Crear metadata de cuenta. La contrasena no se guarda aqui: Firebase Auth
  /// la administra de forma segura.
  Future<void> crearCuenta({
    required String usuarioId,
    required String correo,
    required String tipo,
  }) async {
    try {
      await _firestore.collection('cuentas').doc(usuarioId).set({
        'uid': usuarioId,
        'correo': correo,
        'tipo': tipo,
        'creadaEn': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error creando cuenta: $e');
    }
  }

  // ==================== TIENDAS ====================

  /// Crear una nueva sede
  Future<void> crearSede(String sedeId, SedeModel sede) async {
    try {
      await _firestore.collection('tiendas').doc(sedeId).set(sede.toMap());
    } catch (e) {
      throw Exception('Error creando sede: $e');
    }
  }

  /// Obtener una sede por ID
  Future<SedeModel?> obtenerSede(String sedeId) async {
    try {
      final doc = await _firestore.collection('tiendas').doc(sedeId).get();
      if (doc.exists) {
        return SedeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error obteniendo sede: $e');
    }
  }

  /// Obtener todas las sedes de un usuario
  Future<List<SedeModel>> obtenerSedesUsuario(String usuarioId) async {
    try {
      final query = await _firestore
          .collection('tiendas')
          .where('usuarioId', isEqualTo: usuarioId)
          .get();

      return query.docs
          .map((doc) => SedeModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo sedes: $e');
    }
  }

  /// Stream de sedes de un usuario (en tiempo real)
  Stream<List<SedeModel>> obtenerSedesUsuarioStream(String usuarioId) {
    return _firestore
        .collection('tiendas')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map(
          (query) => query.docs
              .map((doc) => SedeModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ==================== TRABAJADORES ====================

  /// Registrar un nuevo trabajador
  Future<void> registrarTrabajador(
    String trabajadorId,
    TrabajadorModel trabajador,
  ) async {
    try {
      await _firestore
          .collection('trabajadores')
          .doc(trabajadorId)
          .set(trabajador.toMap());
    } catch (e) {
      throw Exception('Error registrando trabajador: $e');
    }
  }

  /// Obtener trabajador por ID
  Future<TrabajadorModel?> obtenerTrabajador(String trabajadorId) async {
    try {
      final doc = await _firestore
          .collection('trabajadores')
          .doc(trabajadorId)
          .get();
      if (doc.exists) {
        return TrabajadorModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error obteniendo trabajador: $e');
    }
  }

  /// Obtener trabajador por DNI y ID de Sede
  Future<TrabajadorModel?> obtenerTrabajadorPorDNI({
    required String dni,
    required String idSede,
  }) async {
    try {
      final query = await _firestore
          .collection('trabajadores')
          .where('dni', isEqualTo: dni)
          .where('idSede', isEqualTo: idSede)
          .where('activo', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return TrabajadorModel.fromMap(
          query.docs.first.data(),
          query.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error obteniendo trabajador por DNI: $e');
    }
  }

  /// Obtener trabajadores de una sede
  Future<List<TrabajadorModel>> obtenerTrabajadoresSede(String sedeId) async {
    try {
      final query = await _firestore
          .collection('trabajadores')
          .where('idSede', isEqualTo: sedeId)
          .where('activo', isEqualTo: true)
          .get();

      return query.docs
          .map((doc) => TrabajadorModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo trabajadores: $e');
    }
  }

  /// Stream de trabajadores de una sede
  Stream<List<TrabajadorModel>> obtenerTrabajadoresSedeStream(String sedeId) {
    return _firestore
        .collection('trabajadores')
        .where('idSede', isEqualTo: sedeId)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map(
          (query) => query.docs
              .map((doc) => TrabajadorModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ==================== ASISTENCIAS ====================

  /// Registrar o actualizar asistencia diaria
  /// Busca si existe registro del día, sino lo crea
  Future<void> registrarAsistencia(AsistenciaModel asistencia) async {
    try {
      final fecha = DateTime(
        asistencia.fecha.year,
        asistencia.fecha.month,
        asistencia.fecha.day,
      );
      final docId =
          '${asistencia.idTrabajador}_${fecha.toIso8601String().split('T')[0]}';

      final docRef = _firestore.collection('asistencias').doc(docId);
      final doc = await docRef.get();

      if (doc.exists) {
        // Actualizar documento existente
        await docRef.update(asistencia.toMap());
      } else {
        // Crear nuevo documento
        await docRef.set(asistencia.toMap());
      }
    } catch (e) {
      throw Exception('Error registrando asistencia: $e');
    }
  }

  /// Obtener asistencia de un trabajador para una fecha específica
  Future<AsistenciaModel?> obtenerAsistenciaDelDia({
    required String idTrabajador,
    required DateTime fecha,
  }) async {
    try {
      final fechaStr = fecha.toIso8601String().split('T')[0];
      final docId = '${idTrabajador}_$fechaStr';

      final doc = await _firestore.collection('asistencias').doc(docId).get();
      if (doc.exists) {
        return AsistenciaModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error obteniendo asistencia: $e');
    }
  }

  /// Obtener asistencias de un trabajador en un rango de fechas
  Future<List<AsistenciaModel>> obtenerAsistenciasRango({
    required String idTrabajador,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final query = await _firestore
          .collection('asistencias')
          .where('idTrabajador', isEqualTo: idTrabajador)
          .where('fecha', isGreaterThanOrEqualTo: fechaInicio)
          .where('fecha', isLessThanOrEqualTo: fechaFin)
          .orderBy('fecha', descending: true)
          .get();

      return query.docs
          .map((doc) => AsistenciaModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo asistencias: $e');
    }
  }

  /// Stream de asistencias de un trabajador por mes
  Stream<List<AsistenciaModel>> obtenerAsistenciasDelMesStream({
    required String idTrabajador,
    required DateTime fecha,
  }) {
    final primerDia = DateTime(fecha.year, fecha.month, 1);
    final ultimoDia = DateTime(fecha.year, fecha.month + 1, 0);

    return _firestore
        .collection('asistencias')
        .where('idTrabajador', isEqualTo: idTrabajador)
        .where('fecha', isGreaterThanOrEqualTo: primerDia)
        .where('fecha', isLessThanOrEqualTo: ultimoDia)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(
          (query) => query.docs
              .map((doc) => AsistenciaModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Obtener asistencias de una sede en un rango de fechas
  Future<List<AsistenciaModel>> obtenerAsistenciasSedeRango({
    required String idSede,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final query = await _firestore
          .collection('asistencias')
          .where('idSede', isEqualTo: idSede)
          .where('fecha', isGreaterThanOrEqualTo: fechaInicio)
          .where('fecha', isLessThanOrEqualTo: fechaFin)
          .orderBy('fecha', descending: true)
          .get();

      return query.docs
          .map((doc) => AsistenciaModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo asistencias de la sede: $e');
    }
  }
}
