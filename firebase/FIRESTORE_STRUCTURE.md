# 📊 Estructura de Base de Datos - Firestore

## Descripción

El sistema utiliza Cloud Firestore para almacenar datos de cuentas, tiendas, trabajadores y asistencias. La estructura está optimizada para consultas eficientes y mantenimiento seguro.

## 🏗️ Colecciones

### 1. **Colección: `cuentas`**
Almacena la metadata de cada cuenta autenticada. La contraseña no se guarda aquí porque Firebase Authentication ya la protege.

```javascript
{
  id: "uuid_usuario_firebase",                // Document ID = User ID
  uid: "uuid_usuario_firebase",               // string
  correo: "tienda@example.com",               // string
  tipo: "tienda",                             // "tienda" | "trabajador"
  creadaEn: Timestamp,                        // timestamp
}
```

---

### 2. **Colección: `tiendas`**
Almacena información de las tiendas/sedes registradas.

```javascript
{
  id: "uuid_usuario_firebase", // Document ID = User ID
  
  // Datos de la sede
  nombre: "Tienda Centro",                    // string
  direccion: "Calle Principal 123",           // string
  idSede: "SEDE_001",                         // string (único)
  
  // Metadata
  creadaEn: Timestamp,                        // timestamp
  usuarioId: "uuid_usuario_firebase",         // string (referencia a usuario)
}
```

**Índices Recomendados:**
- `idSede` (Ascendente)
- `usuarioId` (Ascendente)

---

### 3. **Colección: `trabajadores`**
Almacena información de los empleados registrados.

```javascript
{
  id: "uuid_usuario_firebase",                // Document ID = User ID
  
  // Datos personales
  nombreCompleto: "Juan Pérez García",        // string
  dni: "12345678",                            // string (clave de vinculación)
  cargo: "Vendedor",                          // string
  correo: "juan@example.com",                 // string
  
  // Relación
  idSede: "SEDE_001",                         // string (referencia)
  
  // Metadata
  creadoEn: Timestamp,                        // timestamp
  activo: true,                               // boolean
}
```

**Índices Recomendados:**
- `idSede + activo` (Compound)
- `dni + idSede` (Compound)

**Restricciones:**
- DNI debe ser único por sede
- Solo se retornan trabajadores activos en consultas públicas

---

### 4. **Colección: `asistencias`**
Almacena los registros diarios de asistencia de cada trabajador.

```javascript
{
  id: "idTrabajador_YYYY-MM-DD",              // Document ID (formato automático)
  
  // Identificación del trabajador
  idTrabajador: "uuid_usuario_firebase",      // string
  dni: "12345678",                            // string (desnormalizado)
  nombreTrabajador: "Juan Pérez García",      // string (desnormalizado)
  
  // Identificación de la sede
  idSede: "SEDE_001",                         // string
  nombreSede: "Tienda Centro",                // string (desnormalizado)
  
  // Fecha
  fecha: Timestamp,                           // timestamp (inicio del día)
  
  // Las 4 marcas obligatorias del día
  horaInicio: Timestamp,                      // timestamp | null (Marca 1)
  horaReceso: Timestamp,                      // timestamp | null (Marca 2)
  horaFinReceso: Timestamp,                   // timestamp | null (Marca 3)
  horaSalida: Timestamp,                      // timestamp | null (Marca 4)
}
```

**Índices Recomendados:**
- `idTrabajador + fecha` (Compound, DESC)
- `idSede + fecha` (Compound, DESC)

**Consultas Típicas:**
```javascript
// Asistencia de hoy para un trabajador
db.collection('asistencias')
  .where('idTrabajador', '==', 'ID_TRAB')
  .where('fecha', '>=', DateTime(today))
  .where('fecha', '<', DateTime(tomorrow))

// Asistencias de una sede en un rango
db.collection('asistencias')
  .where('idSede', '==', 'SEDE_001')
  .where('fecha', '>=', startDate)
  .where('fecha', '<=', endDate)
  .orderBy('fecha', descending: true)
```

---

## 📋 Notas de Implementación

### Desnormalización de Datos
Se denormalizan `nombreTrabajador`, `nombreSede`, etc. en la colección `asistencias` para:
- Consultas más rápidas (no requieren JOIN)
- Consultas offline más útiles
- Reducir llamadas a la base de datos

### Documentos Diarios
Cada trabajador tiene UN documento por día para asistencia:
- ID: `${idTrabajador}_YYYY-MM-DD`
- Permite actualizaciones parciales (agregar marcas sin reescribir el documento)
- Facilita reportes diarios y mensuales

### Timestamps
Todos los timestamps están en UTC en la base de datos:
```dart
// Flutter: Convertir timestamp
DateTime dt = timestamp.toDate();

// Firestore: Guardar timestamp
Timestamp.now()
```

---

## 🔍 Consultas Comunes

### 1. Obtener asistencia de hoy del trabajador
```dart
final hoy = DateTime.now();
final docId = '${trabajadorId}_${hoy.toIso8601String().split('T')[0]}';
final doc = await firestore.collection('asistencias').doc(docId).get();
```

### 2. Obtener historial mensual
```dart
final primerDia = DateTime(fecha.year, fecha.month, 1);
final ultimoDia = DateTime(fecha.year, fecha.month + 1, 0);

final query = firestore
  .collection('asistencias')
  .where('idTrabajador', isEqualTo: trabajadorId)
  .where('fecha', isGreaterThanOrEqualTo: primerDia)
  .where('fecha', isLessThanOrEqualTo: ultimoDia)
  .orderBy('fecha', descending: true);
```

### 3. Reporte de asistencias de la sede en un rango
```dart
final query = firestore
  .collection('asistencias')
  .where('idSede', isEqualTo: sedeId)
  .where('fecha', isGreaterThanOrEqualTo: inicio)
  .where('fecha', isLessThanOrEqualTo: fin)
  .orderBy('fecha', descending: true);
```

---

## ⚠️ Límites y Consideraciones

| Límite | Valor | Nota |
|--------|-------|------|
| Documentos por colección | 1,000,000+ | Sin límite práctico |
| Tamaño máximo documento | 1 MB | Bien dentro del límite |
| Operaciones/segundo | 10,000+ | Escala automática |
| Lectura por segundo (por usuario) | 100+ | Con índices |

---

## 🔐 Seguridad

Ver [FIRESTORE_RULES.md](./FIRESTORE_RULES.md) para las reglas de acceso.
