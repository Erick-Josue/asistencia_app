# 🚀 Guía de Instalación y Configuración

## 📋 Requisitos Previos

- **Flutter 3.0+** instalado
- **Dart 2.19+**
- **Android Studio** o **Xcode** (para emulador)
- **Firebase Project** creado
- **Git** instalado

---

## 🔧 Pasos de Configuración

### 1️⃣ **Clonar el Repositorio**

```bash
cd app_aisitenciav2
```

### 2️⃣ **Instalar Melos** (gestor de monorepo)

```bash
dart pub global activate melos
```

### 3️⃣ **Configurar Monorepo**

```bash
melos bootstrap
```

Esto instalará todas las dependencias en todos los paquetes.

---

### 4️⃣ **Configurar Firebase**

#### **Para Android:**

1. Ir a [Firebase Console](https://console.firebase.google.com)
2. Crear nuevo proyecto o seleccionar existente
3. Agregar aplicación Android
4. Descargar `google-services.json`
5. Colocar en:
   - `packages/app_sede/android/app/google-services.json`
   - `packages/app_trabajador/android/app/google-services.json`

#### **Para iOS:**

1. Agregar aplicación iOS en Firebase
2. Descargar `GoogleService-Info.plist`
3. Abrir `packages/app_sede/ios/Runner.xcworkspace` en Xcode
4. Arrastrar `GoogleService-Info.plist` al proyecto
5. Repetir para `app_trabajador`

---

### 5️⃣ **Generar Configuración de Firebase**

```bash
# Instalar Firebase CLI (una sola vez)
npm install -g firebase-tools

# Configurar proyecto
firebase login
firebase init
```

---

### 6️⃣ **Crear Estructura en Firestore**

1. Ir a Firebase Console → Firestore Database
2. Crear colecciones:
   - `sedes`
   - `trabajadores`
   - `asistencias`

3. Copiar las **reglas de seguridad**:
   - Ir a **Rules** tab
   - Reemplazar con contenido de `firebase/firestore.rules`
   - Publicar

---

### 7️⃣ **Configurar Métodos de Autenticación**

1. Ir a Firebase Console → Authentication
2. **Sign-in method** → Habilitar "Email/Password"

---

## 🏃 Ejecutar las Aplicaciones

### **Ejecutar APP SEDE:**

```bash
# Listar devices disponibles
flutter devices

# Ejecutar
flutter run -d <device_id>

# O usar el atajo de melos
melos run app_sede
```

### **Ejecutar APP TRABAJADOR:**

```bash
flutter run packages/app_trabajador -d <device_id>

# O usar melos
melos run app_trabajador
```

---

## 📱 Pruebas Funcionales

### **Test 1: Registro de Sede**

1. Abrir app_sede
2. Hacer clic en "Registrar Sede"
3. Llenar datos:
   - Nombre: "Tienda Centro"
   - Dirección: "Calle Principal 123"
   - ID Sede: "SEDE_001"
   - Correo: test@sede.com
   - Contraseña: Test123456
4. ✅ Debe redirigir a pantalla de QR dinámico

### **Test 2: Registro de Trabajador**

1. Abrir app_trabajador
2. Hacer clic en "Registrar"
3. Llenar datos:
   - Nombre: "Juan Pérez"
   - DNI: "12345678"
   - Cargo: "Vendedor"
   - ID Sede: "SEDE_001" (el mismo de la sede)
   - Correo: juan@trabajador.com
   - Contraseña: Test123456
4. ✅ Debe redirigir a pantalla de scanner

### **Test 3: Escaneo de QR**

1. En app_sede, ver el QR dinámico (cambia cada 30 segundos)
2. En app_trabajador, abrir scanner
3. Apuntar a la pantalla del QR
4. ✅ Debe validar y permitir registrar marca

### **Test 4: Registro de 4 Marcas**

1. Escanear QR para "Hora de Inicio"
2. Escanear QR para "Hora de Receso"
3. Escanear QR para "Fin de Receso"
4. Escanear QR para "Hora de Salida"
5. ✅ Cada marca debe validarse en orden
6. ✅ Mostrar "Asistencia Completa" al final

---

## 🔐 Variables de Entorno

Crear archivo `.env` en la raíz del proyecto:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key

# Encryption (generar nuevas claves)
ENCRYPTION_KEY=asistencia_qr_encrypt_key_256bit_prod

# QR Configuration
QR_INTERVAL_SECONDS=30
QR_VALIDITY_SECONDS=60
```

---

## 🐛 Troubleshooting

### Error: "google-services.json no encontrado"

```bash
# Verificar ubicación correcta
ls packages/app_sede/android/app/google-services.json
ls packages/app_trabajador/android/app/google-services.json
```

### Error: "FirebaseException: No Firebase App"

- Verificar que Firebase está inicializado en `main.dart`
- Verificar que `google-services.json` tiene contenido válido

### Error: "Firestore rules rejected"

- Verificar reglas en Firebase Console
- Estar autenticado antes de acceder a datos
- Verificar que `idTrabajador` coincide con `request.auth.uid`

### Error: "Camera permissions denied"

1. Android: Verificar `AndroidManifest.xml`
2. iOS: Verificar `Info.plist`
3. Solicitar permisos en runtime con `permission_handler`

---

## 📦 Compilación para Producción

### **Android:**

```bash
flutter build apk --release
flutter build appbundle --release
```

### **iOS:**

```bash
flutter build ios --release
# Luego abrir en Xcode para uploads
open ios/Runner.xcworkspace
```

---

## 📚 Recursos Adicionales

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Flutter](https://firebase.google.com/docs/flutter/setup)
- [BLoC Pattern](https://bloclibrary.dev)
- [Clean Architecture](https://medium.com/flutter-community/clean-architecture-in-flutter)

---

## ✅ Checklist de Configuración

- [ ] Flutter 3.0+ instalado
- [ ] Melos instalado
- [ ] Firebase Project creado
- [ ] `google-services.json` descargado y colocado
- [ ] `GoogleService-Info.plist` descargado y colocado (iOS)
- [ ] Firestore colecciones creadas
- [ ] Reglas de Firestore implementadas
- [ ] Authentication habilitado
- [ ] Melos bootstrap ejecutado
- [ ] Emulador/device conectado
- [ ] Primera ejecución exitosa

---

## 🆘 Soporte

Para problemas:
1. Revisar logs: `flutter run -v`
2. Limpiar proyecto: `melos clean && melos bootstrap`
3. Verificar Firebase Console
4. Revisar reglas de Firestore
