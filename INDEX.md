# 📑 Índice Completo del Proyecto

## 🗂️ Estructura Navegable

### **📄 Documentación Principal**
- [README.md](README.md) - Descripción general y estructura
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Resumen completo del proyecto
- [INSTALLATION.md](INSTALLATION.md) - Guía de instalación paso a paso
- [ARCHITECTURE.md](ARCHITECTURE.md) - Clean Architecture + BLoC explicado
- [ASISTENCIA_FLOW.md](ASISTENCIA_FLOW.md) - Flujo detallado de las 4 marcas
- [SECURITY.md](SECURITY.md) - Encriptación y medidas de seguridad
- [INDEX.md](INDEX.md) - Este archivo

---

### **📦 Monorepo Configuration**
```
melos.yaml              # Configuración del monorepo
.gitignore              # Archivos a ignorar
```

---

### **🔥 Firebase Configuration**
```
firebase/
├── FIRESTORE_STRUCTURE.md   # Esquema de base de datos
├── FIRESTORE_RULES.md       # Reglas de seguridad
└── firestore.rules          # Archivo de reglas para copiar
```

---

### **🟦 Core Package (Compartido)**

```
packages/core/
├── pubspec.yaml
└── lib/src/
    │
    ├── domain/                              # LÓGICA DE NEGOCIO
    │   ├── entities/
    │   │   ├── sede_entity.dart             # Entidad Sede
    │   │   ├── trabajador_entity.dart       # Entidad Trabajador
    │   │   ├── asistencia_entity.dart       # Entidad Asistencia (⭐ 4 marcas)
    │   │   └── usuario_entity.dart          # Entidad Usuario
    │   └── repositories/
    │       ├── sede_repository.dart         # Contrato de Sede
    │       ├── trabajador_repository.dart   # Contrato de Trabajador
    │       └── asistencia_repository.dart   # Contrato de Asistencia
    │
    ├── data/                                # CAPA DE DATOS
    │   ├── datasources/
    │   │   ├── firebase_auth_service.dart   # 🔌 Autenticación Firebase
    │   │   └── firestore_service.dart       # 🔌 Base de datos Firestore
    │   ├── models/
    │   │   ├── sede_model.dart              # DTO: Sede (mapeo Firestore)
    │   │   ├── trabajador_model.dart        # DTO: Trabajador
    │   │   └── asistencia_model.dart        # DTO: Asistencia
    │   └── repositories/
    │       ├── sede_repository_impl.dart    # Implementación Sede
    │       ├── trabajador_repository_impl.dart
    │       └── asistencia_repository_impl.dart
    │
    ├── presentation/
    │   └── bloc/                            # BLoCs generales
    │
    └── utils/
        ├── encryption/
        │   └── encryption_service.dart      # ⭐ AES-256 para QR
        └── constants/
            ├── app_strings.dart
            └── app_colors.dart
```

**Rutas Clave en Core:**
- [Entidad Asistencia](packages/core/lib/src/domain/entities/asistencia_entity.dart) - Define las 4 marcas y métodos
- [Servicio Firestore](packages/core/lib/src/data/datasources/firestore_service.dart) - Todas las operaciones CRUD
- [Servicio Encriptación](packages/core/lib/src/utils/encryption/encryption_service.dart) - AES-256 para QR

---

### **🟩 APP SEDE (Administrador)**

```
packages/app_sede/
├── pubspec.yaml                  # Dependencias de app_sede
├── lib/
│   ├── main.dart                 # 🚀 Punto de entrada
│   └── src/
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── auth_screen.dart           # Login/Registro sede
│       │   │   ├── home_screen.dart           # Home con QR
│       │   │   ├── qr_screen.dart             # Pantalla QR dinámico
│       │   │   ├── trabajadores_screen.dart   # Lista de trabajadores
│       │   │   └── reportes_screen.dart       # Reportes diarios
│       │   ├── bloc/
│       │   │   ├── auth_sede_event.dart       # Eventos autenticación
│       │   │   ├── auth_sede_state.dart       # Estados autenticación
│       │   │   ├── auth_sede_bloc.dart        # 🎯 BLoC autenticación
│       │   │   ├── qr_dinamico_event.dart     # Eventos QR
│       │   │   ├── qr_dinamico_state.dart     # Estados QR
│       │   │   └── qr_dinamico_bloc.dart      # ⭐ BLoC QR dinámico (cambia cada 30s)
│       │   └── widgets/
│       │       ├── qr_widget.dart             # Widget que muestra QR
│       │       ├── stats_widget.dart          # Widget estadísticas
│       │       └── custom_button.dart         # Botón personalizado
│       └── di/
│           └── service_locator.dart           # Inyección de dependencias
```

**Características:**
- ✅ Autenticación con email/contraseña
- ✅ QR dinámico que cambia cada 30 segundos
- ✅ QR encriptado con AES-256
- ✅ Visualización en tiempo real
- ✅ Contador regresivo

---

### **🟫 APP TRABAJADOR (Empleado)**

```
packages/app_trabajador/
├── pubspec.yaml                  # Dependencias de app_trabajador
├── lib/
│   ├── main.dart                 # 🚀 Punto de entrada
│   └── src/
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── auth_screen.dart           # Login/Registro trabajador
│       │   │   ├── home_screen.dart           # Home con estado asistencia
│       │   │   ├── scanner_screen.dart        # Pantalla escáner QR
│       │   │   ├── asistencia_screen.dart     # Detalles de hoy
│       │   │   └── historial_screen.dart      # Historial mensual
│       │   ├── bloc/
│       │   │   ├── auth_trabajador_event.dart
│       │   │   ├── auth_trabajador_state.dart
│       │   │   ├── auth_trabajador_bloc.dart  # 🎯 BLoC autenticación
│       │   │   ├── asistencia_event.dart      # Eventos asistencia
│       │   │   ├── asistencia_state.dart      # Estados asistencia
│       │   │   └── asistencia_bloc.dart       # ⭐ BLoC asistencia (valida 4 marcas)
│       │   └── widgets/
│       │       ├── scanner_widget.dart        # Widget escáner
│       │       ├── marca_card.dart            # Tarjeta de marca
│       │       └── historial_item.dart        # Item en historial
│       └── di/
│           └── service_locator.dart
```

**Características:**
- ✅ Registro con: Nombre, DNI, Cargo, Correo
- ✅ Login con Correo/Contraseña
- ✅ Escáner de QR integrado
- ✅ Validación de orden (4 marcas obligatorias)
- ✅ Historial de asistencias

---

## 🔍 Cómo Navegar por el Código

### **Si quieres entender la seguridad:**
1. [SECURITY.md](SECURITY.md) - Conceptos
2. [encryption_service.dart](packages/core/lib/src/utils/encryption/encryption_service.dart) - Implementación
3. [firestore.rules](firebase/firestore.rules) - Reglas BD

### **Si quieres entender el flujo de asistencia:**
1. [ASISTENCIA_FLOW.md](ASISTENCIA_FLOW.md) - Diagrama completo
2. [asistencia_entity.dart](packages/core/lib/src/domain/entities/asistencia_entity.dart) - Lógica entidad
3. [asistencia_bloc.dart](packages/app_trabajador/lib/src/presentation/bloc/asistencia_bloc.dart) - Implementación

### **Si quieres entender la arquitectura:**
1. [ARCHITECTURE.md](ARCHITECTURE.md) - Visión general
2. [firestore_service.dart](packages/core/lib/src/data/datasources/firestore_service.dart) - Data layer
3. [qr_dinamico_bloc.dart](packages/app_sede/lib/src/presentation/bloc/qr_dinamico_bloc.dart) - Presentation layer

### **Si quieres implementar UI:**
1. [INSTALLATION.md](INSTALLATION.md) - Configurar proyecto
2. `packages/app_sede/lib/src/presentation/screens/` - Copiar estructura
3. Flutter Material Design docs

---

## 📊 Mapa de Dependencias

```
app_trabajador/          app_sede/
      ↓                       ↓
      └─────── core ──────────┘
               ↓
    Entities + Models + Services
               ↓
      Firebase + Encryption
```

---

## 🗝️ Clases Principales

### **Entidades (domain/entities/)**
- `SedeEntity` - Información de la tienda
- `TrabajadorEntity` - Información del empleado
- `AsistenciaEntity` ⭐ - **Contiene las 4 marcas diarias**
- `UsuarioEntity` - Usuario autenticado

### **Servicios (data/datasources/)**
- `FirebaseAuthService` - Login/Registro
- `FirestoreService` - CRUD en BD
- `EncryptionService` ⭐ - **Encriptación AES-256**

### **BLoCs**
- `AuthSedeBloc` - Autenticación sede
- `QRDinamicoBloc` ⭐ - **Genera QR cada 30s**
- `AuthTrabajadorBloc` - Autenticación trabajador
- `AsistenciaBloc` ⭐ - **Valida 4 marcas en orden**

---

## 📋 Tareas Recomendadas

### **Corto Plazo** (1-2 semanas)
- [ ] Descargar google-services.json
- [ ] Ejecutar `melos bootstrap`
- [ ] Crear screens en app_sede
- [ ] Crear screens en app_trabajador
- [ ] Integrar mobile_scanner

### **Mediano Plazo** (2-4 semanas)
- [ ] Tests unitarios
- [ ] Tests de BLoC
- [ ] Ajustes UI/UX
- [ ] Validaciones adicionales

### **Largo Plazo** (1-2 meses)
- [ ] Deploy en Play Store
- [ ] Deploy en App Store
- [ ] Geolocalización
- [ ] Reportes avanzados

---

## 🆘 Troubleshooting Rápido

| Problema | Archivo a revisar |
|----------|---|
| "Firebase no inicializa" | `main.dart` en cada app |
| "Error en BLoC" | `*_bloc.dart` relevante |
| "QR no muestra" | `qr_dinamico_bloc.dart` |
| "Asistencia no valida" | `asistencia_bloc.dart` |
| "Error Firestore rules" | `firebase/firestore.rules` |
| "Encriptación falla" | `encryption_service.dart` |

---

## 📞 Referencias Rápidas

| Necesidad | Archivo/Link |
|---|---|
| "¿Cómo instalar?" | [INSTALLATION.md](INSTALLATION.md) |
| "¿Cómo funciona el QR?" | [ASISTENCIA_FLOW.md](ASISTENCIA_FLOW.md) |
| "¿Cómo está estructurada la BD?" | [firebase/FIRESTORE_STRUCTURE.md](firebase/FIRESTORE_STRUCTURE.md) |
| "¿Cómo es segura?" | [SECURITY.md](SECURITY.md) |
| "¿Cuál es la arquitectura?" | [ARCHITECTURE.md](ARCHITECTURE.md) |
| "¿Qué se creó?" | [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) |

---

**¡Ahora estás listo para explorar y desarrollar!** 🚀
