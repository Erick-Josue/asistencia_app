# 🔐 Reglas de Seguridad de Firestore

Este documento describe las reglas de seguridad para Firebase Firestore.

## 📋 Resumen de Reglas

### Autenticación Requerida
- ✅ Solo usuarios autenticados pueden acceder
- ✅ Tiendas acceden solo a sus propios datos
- ✅ Trabajadores acceden solo a sus propios datos de asistencia

### Control de Acceso Granular
- Tiendas: Lectura/escritura de su propia tienda y asistencias de su sede
- Trabajadores: Lectura/escritura de su propia asistencia
- Ningún usuario accede a datos de otros usuarios

---

## 📝 Reglas de Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ====================== CUENTAS ======================
    match /cuentas/{cuentaId} {
      allow read: if request.auth != null && request.auth.uid == cuentaId;
      allow create: if request.auth != null
                    && request.auth.uid == cuentaId
                    && validarCuentaData(request.resource.data);
      allow update, delete: if false;
    }

    // ====================== TIENDAS ======================
    // Colección: tiendas
    match /tiendas/{sedeId} {
      // Lectura: Solo el propietario puede leer su sede
      allow read: if request.auth.uid == sedeId;
      
      // Escritura: Solo el propietario puede escribir (crear/actualizar)
      allow write: if request.auth.uid == sedeId 
                   && validarTiendaData(request.resource.data);
    }
    
    // ====================== TRABAJADORES ======================
    // Colección: trabajadores
    match /trabajadores/{trabajadorId} {
      // Lectura: Solo el propietario puede leer su perfil
      allow read: if request.auth.uid == trabajadorId;
      
      // Escritura: Solo el propietario durante registro
      allow create: if request.auth.uid == trabajadorId 
                    && validarTrabajadorData(request.resource.data);
      
      // Actualización: Solo cambios menores permitidos
      allow update: if request.auth.uid == trabajadorId 
                    && validarActualizacionTrabajador(request.resource.data, 
                                                       resource.data);
      
      // Eliminación: No permitida
      allow delete: if false;
    }
    
    // ====================== ASISTENCIAS ======================
    // Colección: asistencias (acceso según rol)
    match /asistencias/{asistenciaId} {
      // Permitir a trabajadores acceder su propia asistencia
      allow read: if request.auth != null
                  && (
                    request.auth.uid == resource.data.idTrabajador
                    || (
                      existeTienda(request.auth.uid)
                      && resource.data.idSede ==
                         get(/databases/$(database)/documents/tiendas/$(request.auth.uid)).data.idSede
                    )
                  );

      allow create: if request.auth != null
                    && request.auth.uid == request.resource.data.idTrabajador
                    && validarAsistenciaData(request.resource.data);

      allow update: if request.auth != null
                    && request.auth.uid == resource.data.idTrabajador
                    && request.auth.uid == request.resource.data.idTrabajador
                    && validarAsistenciaData(request.resource.data);
    }
    
    // ====================== FUNCIONES DE VALIDACIÓN ======================
    
    function validarCuentaData(data) {
      return data.uid is string
        && data.uid == request.auth.uid
        && data.correo is string
        && data.correo.size() > 0
        && data.tipo in ['tienda', 'trabajador']
        && data.creadaEn is timestamp;
    }

    // Validar datos de tienda
    function validarTiendaData(data) {
      return data.nombre is string
        && data.nombre.size() > 0
        && data.direccion is string
        && data.direccion.size() > 0
        && data.idSede is string
        && data.idSede.size() > 0
        && data.creadaEn is timestamp
        && data.usuarioId is string;
    }
    
    // Validar datos de trabajador
    function validarTrabajadorData(data) {
      return data.nombreCompleto is string
        && data.nombreCompleto.size() > 0
        && data.dni is string
        && data.dni.matches('^[0-9]{8}$')  // 8 dígitos
        && data.cargo is string
        && data.cargo.size() > 0
        && data.correo is string
        && data.correo.size() > 0
        && data.idSede is string
        && data.idSede.size() > 0
        && data.creadoEn is timestamp
        && data.activo is bool;
    }
    
    // Validar actualización de trabajador (solo ciertos campos)
    function validarActualizacionTrabajador(newData, oldData) {
      let camposPermitidos = ['correo', 'cargo'];
      return newData.keys().hasOnly(oldData.keys().concat(camposPermitidos).removeValue(''))
        && newData.nombreCompleto == oldData.nombreCompleto  // No cambiar nombre
        && newData.dni == oldData.dni                        // No cambiar DNI
        && newData.idSede == oldData.idSede                  // No cambiar sede
        && newData.creadoEn == oldData.creadoEn;             // No cambiar fecha creación
    }
    
    // Validar datos de asistencia
    function validarAsistenciaData(data) {
      return data.idTrabajador is string
        && data.idTrabajador.size() > 0
        && data.dni is string
        && data.nombreTrabajador is string
        && data.idSede is string
        && data.nombreSede is string
        && data.fecha is timestamp
        && (data.horaInicio == null || data.horaInicio is timestamp)
        && (data.horaReceso == null || data.horaReceso is timestamp)
        && (data.horaFinReceso == null || data.horaFinReceso is timestamp)
        && (data.horaSalida == null || data.horaSalida is timestamp);
    }
    
    // Verificar si es tienda
    function existeTienda(uid) {
      return exists(/databases/$(database)/documents/tiendas/$(uid));
    }
  }
}
```

---

## 🚀 Despliegue en Firebase Console

1. **Ir a Firebase Console** → Proyecto
2. **Firestore Database** → **Reglas**
3. **Reemplazar** el contenido con las reglas anteriores
4. **Publicar**

---

## ✅ Casos de Uso Permitidos

### ✅ Sede puede:
- Leer su propia información de sede
- Actualizar su propia sede
- Leer asistencias de su sede (es.nombreSede == su sede)
- Ver reportes de trabajadores en su sede

### ✅ Trabajador puede:
- Leer su propia información personal
- Registrar su propia asistencia
- Actualizar su propia asistencia
- Leer su historial de asistencias

### ❌ Nadie puede:
- Leer datos de otros usuarios
- Eliminar registros
- Modificar datos de otros usuarios
- Acceder a información sensible sin autenticación

---

## 🔒 Protecciones Implementadas

| Protección | Descripción |
|------------|-------------|
| Autenticación obligatoria | Solo usuarios autenticados acceden |
| Isolamiento por UID | Cada usuario solo ve sus datos |
| Validación de datos | Campos requeridos y tipos correcto |
| Restricción de campos | Ciertos campos no pueden modificarse |
| No eliminación | Registros no pueden eliminarse (solo desactivar) |

---

## 📊 Auditoría y Monitoreo

Para auditar accesos, usar **Firestore Audit Logs**:
```bash
gcloud logging read "resource.type=cloud_firestore" --limit 50
```

---

## 🔄 Versiones de Reglas

- **v1.0** (Inicial): Estructura básica con control granular por UID
- Cambios futuros documentados aquí

---

## 📝 Notas Importantes

1. **Timestamps**: Las reglas no validan que los timestamps sean "razonables" (en el pasado). Considerar validar en backend.

2. **DNI Uniqueness**: Las reglas no previenen duplicación de DNI. Usar una función de trigger en Cloud Functions o validar en la app.

3. **Performance**: Los índices en Firestore están configurados automáticamente basándose en las consultas.

4. **Testing**: Usar **Firebase Emulator** para probar reglas localmente:
   ```bash
   firebase emulators:start
   ```
