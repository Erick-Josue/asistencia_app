# Sistema de Control de Asistencia - Monorepo Flutter

## 🏗️ Arquitectura

Este proyecto utiliza una estructura de **Monorepo** con dos aplicaciones independientes y un paquete core compartido.

```
app_aisitenciav2/
├── packages/
│   ├── core/                 # Paquete compartido (modelos, servicios, utilidades)
│   ├── app_sede/             # APP Tienda/Sede (Generador QR)
│   └── app_trabajador/       # APP Trabajador (Scanner QR + Asistencia)
├── firebase/                 # Reglas Firestore y configuración
└── README.md
```

## 📱 Apps

### 1. **APP SEDE** (`packages/app_sede`)
- ✅ Autenticación con datos de la sede
- ✅ Generación de QR Dinámico (encriptado)
- ✅ Dashboard con estadísticas
- ✅ Gestión de trabajadores

### 2. **APP TRABAJADOR** (`packages/app_trabajador`)
- ✅ Registro y Login
- ✅ Scanner QR integrado
- ✅ Registro de 4 marcas obligatorias
- ✅ Historial de asistencia
- ✅ Notificaciones

## 🔧 Stack Tecnológico

- **Framework**: Flutter 3.0+
- **Backend**: Firebase (Auth + Firestore)
- **Encriptación**: encrypt, crypto
- **QR**: qr_flutter, mobile_scanner
- **State Management**: BLoC + Provider
- **Arquitectura**: Clean Architecture

## 🚀 Configuración Inicial

```bash
# Instalar melos
dart pub global activate melos

# Configurar monorepo
melos bootstrap

# Ejecutar app sede
melos run app_sede

# Ejecutar app trabajador
melos run app_trabajador
```

## 📊 Base de Datos Firestore

### Colecciones
- `sedes`: Información de sedes/tiendas
- `trabajadores`: Datos de empleados
- `asistencias`: Registros diarios de asistencia

Ver [firebase/FIRESTORE_STRUCTURE.md](firebase/FIRESTORE_STRUCTURE.md) para detalles completos.

## 🔐 Seguridad

- ✅ Encriptación de QR con salt dinámico
- ✅ Validación de timestamps
- ✅ Reglas Firestore restrictivas
- ✅ Validación de orden de marcas
# asistencia_app
