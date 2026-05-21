import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Servicio de encriptación para QR dinámico
/// Proporciona métodos para encriptar/desencriptar datos del QR
class EncryptionService {
  // Clave de encriptación (en producción, usar variable de entorno)
  // Esta es una clave ejemplo de 256 bits (32 caracteres)
  static const String _encryptionKey = 'asistencia_qr_encrypt_key_256bit'; // ⚠️ Cambiar en producción

  // Obtener la clave encriptada de 32 bytes
  static encrypt.Key _getKey() {
    // Si la clave es menor a 32 caracteres, hashearla para obtener 32 bytes
    if (_encryptionKey.length < 32) {
      final hash = sha256.convert(utf8.encode(_encryptionKey));
      return encrypt.Key.fromBase64(base64Encode(hash.bytes));
    }
    return encrypt.Key.fromUtf8(_encryptionKey.substring(0, 32));
  }

  /// Encriptar datos del QR
  /// Incluye: idSede, nombreSede, y timestamp actual
  static String encryptQRData({
    required String idSede,
    required String nombreSede,
    DateTime? timestamp,
  }) {
    timestamp ??= DateTime.now();

    // Crear objeto JSON con datos a encriptar
    final data = {
      'idSede': idSede,
      'nombreSede': nombreSede,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'salt': _generateRandomSalt(), // Salt para evitar duplicados
    };

    final jsonString = jsonEncode(data);
    final key = _getKey();
    final iv = encrypt.IV.fromSecureRandom(16);

    // Encriptar usando AES
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(jsonString, iv: iv);

    // Retornar IV + datos encriptados en base64
    // Format: IV:ENCRYPTED_DATA
    final ivBase64 = base64Encode(iv.bytes);
    return '$ivBase64:${encrypted.base64}';
  }

  /// Desencriptar datos del QR
  static Map<String, dynamic>? decryptQRData(String encryptedData) {
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) return null;

      final ivBase64 = parts[0];
      final encryptedBase64 = parts[1];

      final iv = encrypt.IV(base64Decode(ivBase64));
      final key = _getKey();

      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);

      // Parsear JSON desencriptado
      return jsonDecode(decrypted);
    } catch (e) {
      print('Error desencriptando QR: $e');
      return null;
    }
  }

  /// Validar si el QR es reciente (no más de X segundos de antigüedad)
  static bool isQRValid({
    required String encryptedData,
    int maxAgeSeconds = 60, // QR válido por 1 minuto
  }) {
    final decrypted = decryptQRData(encryptedData);
    if (decrypted == null) return false;

    try {
      final timestamp = decrypted['timestamp'] as int;
      final qrDateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(qrDateTime).inSeconds;

      return difference >= 0 && difference <= maxAgeSeconds;
    } catch (e) {
      return false;
    }
  }

  /// Obtener información del QR sin desencriptar (para debugging)
  static Map<String, dynamic>? peekQRInfo(String encryptedData) {
    return decryptQRData(encryptedData);
  }

  /// Generar un salt aleatorio para mayor seguridad
  static String _generateRandomSalt() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _randomString(8);
  }

  /// Generar string aleatorio
  static String _randomString(int length) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[DateTime.now().microsecond % chars.length];
    }
    return result;
  }
}
