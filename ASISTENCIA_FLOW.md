# 📋 Flujo de Asistencia - Guía Completa

## 🎯 Resumen del Sistema

El sistema requiere exactamente **4 marcas obligatorias** por día en **orden estricto**:

```
1️⃣ Hora de Inicio      (08:00)
        ↓
2️⃣ Hora de Receso      (13:00)
        ↓
3️⃣ Fin de Receso       (14:00)
        ↓
4️⃣ Hora de Salida      (17:00)
```

Si el trabajador se salta algún paso, **no puede registrar la siguiente marca**.

---

## 🔄 Flujo Completo de Asistencia

### **Parte 1: Generación de QR (APP SEDE)**

```
┌─────────────────────────────────────────────────────┐
│         PANTALLA PRINCIPAL DE SEDE                   │
└─────────────────────────────────────────────────────┘
                      ↓
            QRDinamicoBloc inicia
                      ↓
   Genera QR encriptado cada 30 segundos:
   {
     idSede: "SEDE_001",
     nombreSede: "Tienda Centro",
     timestamp: 1708192536000,
     salt: "aleatorio"
   }
                      ↓
   ┌─────────────────────────────────┐
   │ QR Válido por: 60 segundos      │
   │ Próximo cambio en: 25 seg       │
   │ Asistencias hoy: 34             │
   └─────────────────────────────────┘
                      ↓
      (Sede muestra QR en pantalla)
```

**Código relevante:**
```dart
// En app_sede, BLoC escucha IniciarQRAutomaticoEvent
// Timer genera nuevo QR cada X segundos
// Estado QRAutomaticoEnProgreso muestra countdown
```

---

### **Parte 2: Registro en APP TRABAJADOR**

#### **Paso 1: Acceso a Scanner**

```
┌──────────────────────────────────┐
│    PANTALLA HOME TRABAJADOR       │
│                                  │
│  Estado actual de asistencia:    │
│  ✅ Entrada: 08:00               │
│  ✅ Receso: 13:00                │
│  ⏳ Fin Receso: No registrado     │
│  ⏳ Salida: No registrado         │
│                                  │
│  [PRÓXIMA MARCA: Fin de Receso]  │
│  [   ABRIR ESCÁNER   ]           │
└──────────────────────────────────┘
                ↓
        Toca botón ESCANEAR
```

**Lógica:**
```dart
// Obtener asistencia de hoy
final asistencia = await obtenerAsistenciaDelDia(trabajadorId);

// Mostrar próxima marca esperada
String proximaMarca = asistencia?.proximaMarca ?? 'Hora de Inicio';
```

---

#### **Paso 2: Escaneo de QR**

```
┌──────────────────────────────────────┐
│      PANTALLA DE ESCÁNER             │
│                                      │
│  🎥 Cámara apuntando al QR           │
│                                      │
│  [  👁️  CAPTURANDO QR...  ]          │
│                                      │
│  📷 Apunta la cámara al código QR    │
└──────────────────────────────────────┘
                ↓
    Detecta código QR
                ↓
    Desencripta: EncryptionService.decrypt()
                ↓
    Valida timestamp (máx 60 seg)
                ↓
    ✅ QR VÁLIDO
```

**Código:**
```dart
// AsistenciaBloc recibe EscanearQREvent
final qrData = EncryptionService.decryptQRData(codigoEncriptado);

if (!EncryptionService.isQRValid(
  encryptedData: codigo,
  maxAgeSeconds: 60,
)) {
  emit(QRInvalido('QR expirado'));
  return;
}

emit(QRValido(
  idSede: qrData['idSede'],
  nombreSede: qrData['nombreSede'],
  proximaMarca: 'Fin de Receso',
));
```

---

#### **Paso 3: Validación de Orden**

```
LÓGICA DE VALIDACIÓN:

¿Primera vez del trabajador hoy?
├─ SÍ → Permite registrar "Hora de Inicio" ✅
└─ NO → Ir a siguiente validación

¿Ya tiene "Hora de Inicio"?
├─ NO → Rechaza, muestra error ❌
└─ SÍ → ¿Ya tiene "Hora de Receso"?

¿Ya tiene "Hora de Receso"?
├─ NO → Permite registrar "Hora de Receso" ✅
└─ SÍ → ¿Ya tiene "Fin de Receso"?

¿Ya tiene "Fin de Receso"?
├─ NO → Permite registrar "Fin de Receso" ✅
└─ SÍ → ¿Ya tiene "Hora de Salida"?

¿Ya tiene "Hora de Salida"?
├─ NO → Permite registrar "Hora de Salida" ✅
└─ SÍ → Día completo ✅ (Sin permitir más marcas)
```

**Implementación:**
```dart
// En AsistenciaBloc._onRegistrarAsistencia()

if (tipoMarca == 'inicio' && asistencia.horaInicio != null) {
  emit(ErrorAsistencia('Ya registraste tu hora de inicio'));
  return;
}

if (tipoMarca == 'receso') {
  if (asistencia.horaInicio == null) {
    emit(ErrorAsistencia('Primero registra Hora de Inicio'));
    return;
  }
  if (asistencia.horaReceso != null) {
    emit(ErrorAsistencia('Ya registraste Hora de Receso'));
    return;
  }
}

// ... similar para fin_receso y salida
```

---

#### **Paso 4: Registrar en Firestore**

```
✅ Validación pasó
        ↓
Obtener hora actual: DateTime.now()
        ↓
Actualizar documento:
/asistencias/{trabajadorId_YYYY-MM-DD}
        ↓
Actualizar campo correspondiente:
- tipoMarca == 'fin_receso' → horaFinReceso = ahora
        ↓
Guardar en Firestore
        ↓
Retornar AsistenciaRegistrada
        ↓
Screen muestra confirmación
```

**Código:**
```dart
// Actualizar documento en Firestore
final asistenciaActualizada = asistencia.copyWith(
  horaFinReceso: DateTime.now(),
);

await firestoreService.registrarAsistencia(asistenciaActualizada);

// En FirestoreService
Future<void> registrarAsistencia(AsistenciaModel asistencia) async {
  final docId = '${asistencia.idTrabajador}_${fecha_sin_hora}';
  
  // Si existe, actualiza; si no, crea
  if (docExiste) {
    await _firestore.collection('asistencias').doc(docId).update(
      asistencia.toMap()
    );
  } else {
    await _firestore.collection('asistencias').doc(docId).set(
      asistencia.toMap()
    );
  }
}
```

---

#### **Paso 5: Confirmación al Trabajador**

```
¿Asistencia completa?
├─ NO (1-3 marcas)
│  └─ Screen muestra:
│     ✅ "Marca registrada"
│     📍 Próxima marca: "Hora de Receso"
│     ⏱️  Marcas completadas: 2/4
│
└─ SÍ (4 marcas)
   └─ Screen muestra:
      🎉 "¡ASISTENCIA COMPLETA!"
      ✅ Entrada: 08:00
      ✅ Receso: 13:00
      ✅ Fin Receso: 14:00
      ✅ Salida: 17:00
      📊 Vuelve a pantalla principal
```

**Estado del BLoC:**
```dart
// AsistenciaRegistrada
emit(
  AsistenciaRegistrada(
    asistencia: asistenciaActualizada,
    tipoMarcaRegistrada: 'fin_receso',
    proximaMarca: 'Hora de Salida',
    diarioCompleto: false, // solo 3 de 4
  ),
);

// Cuando completa 4 marcas
emit(
  AsistenciaRegistrada(
    asistencia: asistenciaCompleta,
    tipoMarcaRegistrada: 'salida',
    proximaMarca: 'Completo',
    diarioCompleto: true, // ¡4 de 4!
  ),
);
```

---

## 📊 Estructura de Datos en Firestore

### **Documento Inicial (Primer escaneo)**

```javascript
{
  id: "TRAB_001_2024-02-18",
  idTrabajador: "TRAB_001",
  dni: "12345678",
  nombreTrabajador: "Juan Pérez",
  idSede: "SEDE_001",
  nombreSede: "Tienda Centro",
  fecha: Timestamp(2024-02-18 00:00:00),
  horaInicio: Timestamp(2024-02-18 08:00:30),
  horaReceso: null,
  horaFinReceso: null,
  horaSalida: null
}
```

### **Documento Después de 2 Marcas**

```javascript
{
  // ... (mismo que arriba)
  horaInicio: Timestamp(2024-02-18 08:00:30),
  horaReceso: Timestamp(2024-02-18 13:05:15),
  horaFinReceso: null,
  horaSalida: null
}
```

### **Documento Completo**

```javascript
{
  // ... (datos básicos)
  horaInicio: Timestamp(2024-02-18 08:00:30),
  horaReceso: Timestamp(2024-02-18 13:05:15),
  horaFinReceso: Timestamp(2024-02-18 14:00:45),
  horaSalida: Timestamp(2024-02-18 17:30:10)
  // ✅ COMPLETO - 4/4 marcas
}
```

---

## 🚨 Casos de Error

### **Caso 1: QR Expirado**

```
Trabajador: Escanea QR que tiene 90 segundos
BLoC: Verifica timestamp
    → 90 segundos > 60 segundos máximo
    → isQRValid() retorna FALSE
BLoC: Emite QRInvalido("QR expirado. Solicite uno nuevo")
Screen: Muestra error rojo
Trabajador: Solicita nuevo QR a la sede
```

### **Caso 2: Orden Incorrecto**

```
Trabajador: Intenta registrar "Hora de Receso" sin "Hora de Inicio"
BLoC: Valida orden
    → asistencia.horaInicio == null
BLoC: Emite ErrorAsistencia("Primero debes registrar Hora de Inicio")
Screen: Muestra error con botón de ayuda
Trabajador: Lee instrucciones y registra en orden correcto
```

### **Caso 3: Marca Duplicada**

```
Trabajador: Escanea QR dos veces para la misma marca
BLoC: Verifica si la marca ya existe
    → asistencia.horaInicio != null
    → intento es 'inicio'
BLoC: Emite ErrorAsistencia("Ya registraste tu hora de inicio")
Screen: Muestra error
Trabajador: Sabe que ya registró esa marca
```

---

## 📱 Flujo Completo en Pantallas

```
DÍA 1 - TRABAJADOR

08:00 → Abre app → Ve: Ninguna marca registrada
        Abre escáner, escanea QR
        ✅ Hora de Inicio registrada
        Screen: 1/4 marcas

13:00 → Abre escáner, escanea QR
        ✅ Hora de Receso registrada
        Screen: 2/4 marcas

14:00 → Abre escáner, escanea QR
        ✅ Fin de Receso registrada
        Screen: 3/4 marcas

17:00 → Abre escáner, escanea QR
        ✅ Hora de Salida registrada
        Screen: 🎉 COMPLETO 4/4 marcas
        Firestore: Documento con 4 timestamps
```

---

## 🎯 Reglas de Negocio Clave

| Regla | Implementación |
|-------|---|
| **Orden obligatorio** | Validar en BLoC antes de guardar |
| **QR válido 60 seg** | `EncryptionService.isQRValid()` |
| **Una marca por tipo** | Validar `!= null` antes de permitir |
| **Documento por día** | ID: `${trabajadorId}_YYYY-MM-DD` |
| **Timestamps en UTC** | Usar `DateTime.now().toUtc()` |
| **No permitir cambios** | Reglas Firestore evitan sobrescribir |

---

## 📈 Reportes para SEDE

La sede puede ver:

1. **Resumen del Día**
   - Total trabajadores en sede
   - Asistencias completas
   - Asistencias incompletas
   - Ausentes

2. **Historial Mensual**
   - Cada trabajador + sus 4 marcas diarias
   - Horas trabajadas
   - Ausentismos
   - Puntualidad

3. **Reportes Específicos**
   - Trabajador que no marcó entrada
   - Trabajador que no cerró jornada
   - Variaciones de horario

---

## ✅ Checklist de Implementación

- [ ] `AsistenciaEntity` con métodos `proximaMarca` y `estaCompleto`
- [ ] Validaciones en `AsistenciaBloc`
- [ ] Encriptación de QR con timestamp
- [ ] Validación de expiración de QR (60 seg)
- [ ] Generación automática de QR cada 30 seg
- [ ] ID de documento: `${trabajadorId}_YYYY-MM-DD`
- [ ] Firestore con índices en `idTrabajador + fecha`
- [ ] Reglas Firestore restrictivas
- [ ] Tests de casos de error
- [ ] UI confirmación de cada marca
