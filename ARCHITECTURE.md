# 🏗️ Arquitectura Clean Architecture + BLoC

## 📊 Diagrama General

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (Screens, Widgets, BLoC - Lógica de presentación)          │
└─────────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                              │
│  (Entidades, Use Cases, Repositorio Abstracto)             │
└─────────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER                                │
│  (Models, DataSources, RepositorioImplementación)          │
└─────────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────────┐
│                    EXTERNAL APIs                             │
│  (Firebase Auth, Firestore, Device Camera, QR)             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Estructura de Carpetas

```
packages/core/
├── lib/src/
│   ├── domain/                          # 🔵 DOMAIN LAYER
│   │   ├── entities/                    # Objetos de negocio
│   │   │   ├── sede_entity.dart
│   │   │   ├── trabajador_entity.dart
│   │   │   ├── asistencia_entity.dart
│   │   │   └── usuario_entity.dart
│   │   └── repositories/                # Contratos abstractos
│   │       ├── sede_repository.dart
│   │       ├── trabajador_repository.dart
│   │       └── asistencia_repository.dart
│   │
│   ├── data/                            # 🟢 DATA LAYER
│   │   ├── datasources/                 # Conectores externos
│   │   │   ├── firebase_auth_service.dart
│   │   │   └── firestore_service.dart
│   │   ├── models/                      # DTOs (mapeados a Firestore)
│   │   │   ├── sede_model.dart
│   │   │   ├── trabajador_model.dart
│   │   │   └── asistencia_model.dart
│   │   └── repositories/                # Implementaciones de contratos
│   │       ├── sede_repository_impl.dart
│   │       ├── trabajador_repository_impl.dart
│   │       └── asistencia_repository_impl.dart
│   │
│   ├── presentation/                    # 🟠 PRESENTATION LAYER
│   │   └── bloc/                        # Gestión de estado
│   │       ├── qr_dinamico_bloc.dart
│   │       ├── auth_sede_bloc.dart
│   │       └── asistencia_bloc.dart
│   │
│   └── utils/                           # 🟡 UTILIDADES
│       ├── encryption/
│       │   └── encryption_service.dart
│       └── constants/
│           ├── app_strings.dart
│           └── app_colors.dart
│
packages/app_sede/
├── lib/
│   ├── main.dart                        # Punto de entrada
│   └── src/
│       ├── presentation/                # Screens y Widgets
│       │   ├── screens/
│       │   │   ├── auth_screen.dart
│       │   │   ├── home_screen.dart
│       │   │   ├── qr_screen.dart
│       │   │   ├── trabajadores_screen.dart
│       │   │   └── reportes_screen.dart
│       │   ├── bloc/                    # BLoCs específicos
│       │   │   ├── auth_sede_bloc.dart
│       │   │   ├── auth_sede_event.dart
│       │   │   ├── auth_sede_state.dart
│       │   │   ├── qr_dinamico_bloc.dart
│       │   │   ├── qr_dinamico_event.dart
│       │   │   └── qr_dinamico_state.dart
│       │   └── widgets/                 # Componentes reutilizables
│       │       ├── qr_widget.dart
│       │       ├── stats_widget.dart
│       │       └── custom_button.dart
│       └── di/                          # Inyección de dependencias
│           └── service_locator.dart
│
packages/app_trabajador/
├── lib/
│   ├── main.dart
│   └── src/
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── auth_screen.dart
│       │   │   ├── home_screen.dart
│       │   │   ├── scanner_screen.dart
│       │   │   ├── asistencia_screen.dart
│       │   │   └── historial_screen.dart
│       │   ├── bloc/
│       │   │   ├── auth_trabajador_bloc.dart
│       │   │   ├── auth_trabajador_event.dart
│       │   │   ├── auth_trabajador_state.dart
│       │   │   ├── asistencia_bloc.dart
│       │   │   ├── asistencia_event.dart
│       │   │   └── asistencia_state.dart
│       │   └── widgets/
│       │       ├── scanner_widget.dart
│       │       ├── marca_card.dart
│       │       └── historial_item.dart
│       └── di/
│           └── service_locator.dart
```

---

## 🔄 Flujo de Datos

### **Ejemplo: Registrar Asistencia**

```
                PRESENTATION
                     ↓
    UI Event: EscanearQREvent
                     ↓
              ┌──────────────┐
              │ AsistenciaBloc│
              └───────┬──────┘
                     ↓
    Emite: AsistenciaCargando
                     ↓
              ┌──────────────────┐
              │  FirestoreService │  ← DATA LAYER
              └────────┬─────────┘
                      ↓
    Lee Firestore: obtenerAsistenciaDelDia()
                      ↓
    Valida orden de marcas (DOMAIN LOGIC)
                      ↓
    Encripta con: EncryptionService
                      ↓
    Escribe: registrarAsistencia()
                      ↓
    Retorna AsistenciaModel
                      ↓
              ┌──────────────┐
              │ AsistenciaBloc│
              └───────┬──────┘
                     ↓
    Emite: AsistenciaRegistrada
                     ↓
               PRESENTATION
    Screen redibuja con estado actualizado
```

---

## 🎯 Responsabilidades por Capa

### **DOMAIN LAYER (Lógica de Negocio)**

✅ Responsable de:
- Definir reglas de negocio
- Validar orden de marcas (inicio → receso → fin_receso → salida)
- Validar timestamps válidos
- Definir entidades principales

```dart
// Ejemplo: Validar orden en Entity
if (horaInicio == null) {
  throw 'Primero registra inicio';
}
if (horaReceso == null) {
  throw 'Luego registra receso';
}
```

### **DATA LAYER (Comunicación con APIs)**

✅ Responsable de:
- Conectar con Firebase Auth
- Leer/escribir en Firestore
- Transformar datos (Models)
- Encriptación de QR
- Manejo de errores de red

```dart
// FirestoreService
Future<void> registrarAsistencia(AsistenciaModel asistencia) async {
  await _firestore.collection('asistencias').doc(docId).set(asistencia.toMap());
}
```

### **PRESENTATION LAYER (Interfaz de Usuario)**

✅ Responsable de:
- Renderizar UI
- Manejar interacciones del usuario
- Mostrar estados (cargando, error, éxito)
- Gestionar navegación

```dart
// BLoC Event
add(EscanearQREvent(codigoQREncriptado: data))

// BLoC State → Widget redibuja
if (state is QRValido) {
  showSnackBar('QR válido');
}
```

---

## 🔐 Inyección de Dependencias

Usando **GetIt** (recomendado) o **Provider**:

```dart
// service_locator.dart
final getIt = GetIt.instance;

void setupServiceLocator() {
  // Firebase Services
  getIt.registerSingleton<FirebaseAuthService>(
    FirebaseAuthService(),
  );
  
  getIt.registerSingleton<FirestoreService>(
    FirestoreService(),
  );
  
  // BLoCs
  getIt.registerFactory<AuthSedeBloc>(
    () => AuthSedeBloc(
      authService: getIt<FirebaseAuthService>(),
      firestoreService: getIt<FirestoreService>(),
    ),
  );
  
  getIt.registerFactory<QRDinamicoBloc>(
    () => QRDinamicoBloc(
      firestoreService: getIt<FirestoreService>(),
    ),
  );
}

// En main.dart
setupServiceLocator();
```

---

## 🧪 Testing

### **Estructura de Tests**

```
test/
├── domain/
│   ├── entities/
│   │   └── asistencia_entity_test.dart
│   └── repositories/
│       └── asistencia_repository_test.dart
├── data/
│   ├── models/
│   │   └── asistencia_model_test.dart
│   ├── datasources/
│   │   └── firestore_service_test.dart
│   └── repositories/
│       └── asistencia_repository_impl_test.dart
└── presentation/
    └── bloc/
        └── asistencia_bloc_test.dart
```

### **Ejemplo: Test de BLoC**

```dart
void main() {
  group('AsistenciaBloc', () {
    late MockFirestoreService mockFirestore;
    late AsistenciaBloc bloc;

    setUp(() {
      mockFirestore = MockFirestoreService();
      bloc = AsistenciaBloc(firestoreService: mockFirestore);
    });

    blocTest<AsistenciaBloc, AsistenciaState>(
      'emits [Cargando, Registrada] cuando registra correctamente',
      build: () => bloc,
      act: (bloc) => bloc.add(
        RegistrarAsistenciaEvent(
          idTrabajador: 'TRAB_001',
          dni: '12345678',
          nombreTrabajador: 'Juan',
          idSede: 'SEDE_001',
          nombreSede: 'Centro',
          tipoMarca: 'inicio',
        ),
      ),
      expect: () => [
        const AsistenciaCargando(),
        isA<AsistenciaRegistrada>(),
      ],
    );
  });
}
```

---

## 📐 Principios SOLID Aplicados

| Principio | Implementación |
|-----------|---|
| **S** Single Responsibility | Cada clase tiene una responsabilidad |
| **O** Open/Closed | Abierto a extensión, cerrado a modificación |
| **L** Liskov Substitution | Usar interfaces abstractas |
| **I** Interface Segregation | Interfaces pequeñas y específicas |
| **D** Dependency Inversion | Depender de abstracciones, no implementaciones |

---

## 🔄 Ciclo de Vida de Request

```
USER ACTION
    ↓
Widget emite Event
    ↓
BLoC recibe Event
    ↓
BLoC emite State(Loading)
    ↓
Repository/Service hace operación
    ↓
BLoC emite State(Success) o State(Error)
    ↓
Widget escucha cambios
    ↓
Widget redibuja con nuevo estado
```

---

## 💡 Beneficios de esta Arquitectura

✅ **Separación de Responsabilidades**: Fácil de entender y mantener
✅ **Testabilidad**: Cada capa puede testearse independientemente
✅ **Escalabilidad**: Fácil agregar nuevas funciones
✅ **Reutilización**: Core package usado por ambas apps
✅ **Modularidad**: Monorepo con paquetes independientes
✅ **Independencia**: UI no conoce detalles de BD
