# 🔐 Seguridad y Encriptación

## 🛡️ Estrategias de Seguridad Implementadas

### 1️⃣ **Encriptación de QR Dinámico**

El QR cambia cada 30 segundos y está encriptado para evitar fraude.

#### **Componentes del QR Encriptado:**

```javascript
{
  idSede: "SEDE_001",              // ID único de la sede
  nombreSede: "Tienda Centro",     // Nombre referencial
  timestamp: 1708192536000,        // Milisegundos desde epoch
  salt: "a1b2c3d4"                 // Random para evitar duplicados
}
```

#### **Proceso de Encriptación:**

```
Datos originales
        ↓
JSON.stringify()
        ↓
AES-256 (Encrypt library)
        ↓
IV (16 bytes random) + Datos encriptados
        ↓
Base64.encode()
        ↓
"iv_base64:datos_encriptados_base64"
        ↓
Mostrar en QR
```

**Código:**
```dart
// Generar QR
String qrEncriptado = EncryptionService.encryptQRData(
  idSede: 'SEDE_001',
  nombreSede: 'Tienda Centro',
);

// Validar QR
bool esValido = EncryptionService.isQRValid(
  encryptedData: qrEscaneado,
  maxAgeSeconds: 60,  // Solo válido por 60 segundos
);

// Desencriptar (para debugging)
Map<String, dynamic>? datos = EncryptionService.decryptQRData(qrEscaneado);
```

---

### 2️⃣ **Protecciones Contra Fraude**

#### **A) QR Dinámico (Cambia cada 30 segundos)**

**Problema:** Un trabajador podría fotografiar un QR válido y usarlo más tarde.

**Solución:** 
- QR cambia cada 30 segundos
- QR solo válido por 60 segundos (2 ciclos máximo)
- Timestamp incluido en datos encriptados

```dart
// En QRDinamicoBloc
Timer.periodic(Duration(seconds: 30), (_) {
  // Generar nuevo QR cada 30 segundos
  final nuevoQR = EncryptionService.encryptQRData(...);
});

// Validación en AsistenciaBloc
if (!EncryptionService.isQRValid(encryptedData, maxAgeSeconds: 60)) {
  emit(QRInvalido('QR expirado'));
}
```

#### **B) Salt Aleatorio**

**Problema:** Dos QRs con los mismos datos encriptarían igual.

**Solución:**
- Agregar salt random en cada QR
- Incluso si se crean 2 QRs en el mismo segundo, serán diferentes

```dart
'salt': _generateRandomSalt(),  // Único cada vez

// Resultado: Cada QR es único incluso si los datos son iguales
```

#### **C) Validación de Orden Estricto**

**Problema:** Trabajador intenta registrar marcas en desorden.

**Solución:**
- Validar que cada marca se registre en orden
- Primera validación en app (UX)
- Segunda validación en Firestore (seguridad)

```dart
if (tipoMarca == 'receso' && asistencia.horaInicio == null) {
  emit(ErrorAsistencia('Primero registra Hora de Inicio'));
  return;
}
```

#### **D) Documento por Día**

**Problema:** Cambiar registros de días anteriores.

**Solución:**
- Cada día tiene su propio documento
- ID: `${trabajadorId}_YYYY-MM-DD`
- Imposible mezclar registros

```javascript
// Documento diario
Documento ID: "TRAB_001_2024-02-18"
       → Inmodificable después del día
       
// Documento histórico
Documento ID: "TRAB_001_2024-02-17"
       → Protegido por Firestore rules
```

---

### 3️⃣ **Autenticación y Autorización**

#### **A) Firebase Authentication**

- ✅ Email/Password con validación fuerte
- ✅ Tokens seguros manejados automáticamente
- ✅ Sesiones persistentes encriptadas

```dart
// Solo usuarios autenticados acceden
if (!_authService.isAuthenticated()) {
  redirect(LoginScreen);
}

final uid = _authService.getCurrentUserId();  // UID único de Firebase
```

#### **B) Firestore Security Rules**

Validaciones a nivel de base de datos:

```javascript
// Regla 1: Solo el usuario puede leer sus datos
allow read: if request.auth.uid == documentId;

// Regla 2: Validar estructura de datos
allow write: if validarAsistenciaData(request.resource.data);

// Regla 3: No permitir eliminaciones
allow delete: if false;
```

#### **C) Validación de Datos**

```dart
// Validar en Entity
if (dni.length != 8) throw InvalidDNI();
if (!correo.contains('@')) throw InvalidEmail();

// Validar en BLoC
if (horaInicio == null) throw RequiredField();

// Validar en Firestore rules
&& data.dni is string
&& data.dni.matches('^[0-9]{8}$')
&& data.correo is string
&& data.correo.size() > 0
```

---

### 4️⃣ **Protección de Comunicación**

#### **A) HTTPS/TLS**

- Firebase usa HTTPS por defecto
- Comunicación encriptada end-to-end
- Certificados válidos verificados

#### **B) Credenciales Seguras**

- Contraseñas jamás se guardan en código
- Usar `.env` y variables de entorno
- Firebase gestiona contraseñas de forma segura

```dart
// ❌ INCORRECTO
const apiKey = "AIzaSyABC123...";

// ✅ CORRECTO
final apiKey = String.fromEnvironment('FIREBASE_API_KEY');
```

#### **C) Tokens de Sesión**

- Firebase genera tokens automáticamente
- Tokens expiran periódicamente
- Auto-refresh transparente

```dart
// Firebase maneja automáticamente
// No necesitas guardar tokens manualmente
final user = _auth.currentUser;  // Siempre seguro
```

---

## 🔑 Gestión de Claves de Encriptación

### **Clave de Encriptación para QR**

```dart
// firebase/encryption_service.dart
static const String _encryptionKey = 'asistencia_qr_encrypt_key_256bit';

// ⚠️ EN PRODUCCIÓN:
// 1. Generar clave criptográficamente segura
// 2. Guardar en Firebase Cloud KMS o AWS KMS
// 3. NO guardar en código
```

### **Generar Nueva Clave (Producción)**

```bash
# Generar 32 bytes aleatorios
openssl rand -hex 32
# Resultado: a1b2c3d4e5f6g7h8...z0y1x2w3v4u5t6s7r8q9p0

# Guardar en:
# - Firebase Cloud KMS
# - Environment variable en servidor
# - AWS Secrets Manager
```

### **Rotación de Claves**

```dart
// Si necesitas cambiar la clave:
// 1. Generar nueva clave
// 2. Mantener clave antigua por 24h
// 3. Después, eliminar clave antigua

// Verificar ambas claves
bool qrValido = false;
qrValido = EncryptionService.isQRValid(qr, keyActual);
if (!qrValido) {
  qrValido = EncryptionService.isQRValid(qr, keyAnterior);
}
```

---

## 📋 Checklist de Seguridad

### **Antes de Producción**

- [ ] Clave de encriptación generada criptográficamente
- [ ] Clave no hardcodeada en código
- [ ] Firebase SSL/TLS habilitado
- [ ] Firestore rules implementadas y testadas
- [ ] Authentication habilitado en Firebase
- [ ] Rate limiting configurado
- [ ] Backup automático de Firestore
- [ ] Logs de auditoría habilitados
- [ ] DDoS protection habilitado
- [ ] 2FA para cuentas de administrador

### **Mantenimiento**

- [ ] Revisar logs de Firestore mensualmente
- [ ] Auditar accesos anómalo
- [ ] Actualizar dependencias de seguridad
- [ ] Rotación de claves cada 6 meses
- [ ] Penetration testing anualmente

---

## 🚨 Vulnerabilidades Conocidas y Mitigaciones

| Vulnerabilidad | Riesgo | Mitigación |
|---|---|---|
| QR fotografiado | Fraude si reutilizan foto | QR cambia cada 30 seg, válido 60 seg |
| Trabajador usa otro dispositivo | Acceso no autorizado | Login con contraseña |
| Modificar datos en Firestore | Falsificar asistencias | Firestore rules restrictivas |
| Man-in-the-middle | Interceptar datos | HTTPS/TLS siempre |
| Keylogger en dispositivo | Robar credenciales | No se puede prevenir, usar autenticación biométrica |
| Replay attack (reusar solicitud) | Registrar misma marca 2x | Timestamp en QR + validación de antigüedad |

---

## 🛡️ Mejoras Futuras de Seguridad

### **Fase 2: Autenticación Biométrica**

```dart
// Usar fingerprint/face recognition
final biometricAuth = BiometricAuth();
final canAuthenticate = await biometricAuth.canAuthenticate();

if (canAuthenticate) {
  final resultado = await biometricAuth.authenticate();
  if (resultado) {
    // Permitir acceso sin contraseña
  }
}
```

### **Fase 3: Geolocalización**

```dart
// Verificar que el trabajador está en la sede
final location = await _geoLocationService.getCurrentLocation();
final distancia = _calcularDistancia(
  location,
  sedeLocation,
);

if (distancia > 100) {  // 100 metros
  emit(ErrorAsistencia('No estás en la sede'));
}
```

### **Fase 4: Blockchain para Auditoría**

```dart
// Registrar cada asistencia en blockchain
// Para auditoría inmutable
await blockchain.registrarAsistencia({
  trabajador: id,
  timestamp: now,
  firma: cryptoSign(datos),
});
```

### **Fase 5: Hardware Security Module (HSM)**

```dart
// Guardar claves en HSM físico
// No pueden ser exportadas de forma directa
// Requerido en gobierno/banca
```

---

## 📞 Reportar Vulnerabilidades

Si encuentras una vulnerabilidad de seguridad:

1. **NO publicarla públicamente**
2. Enviar detalles a: `security@tuempresa.com`
3. Incluir:
   - Descripción del problema
   - Pasos para reproducir
   - Impacto potencial
   - Solución sugerida (opcional)

---

## 📚 Referencias de Seguridad

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Firebase Security Best Practices](https://firebase.google.com/docs/projects/best-practices)
- [Flutter Security](https://flutter.dev/docs/testing/deployment/security)
- [Cryptography in Dart](https://api.dart.dev/stable/dart-typed_data/dart-typed_data-library.html)
