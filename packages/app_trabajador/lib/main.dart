import 'package:asistencia_core/asistencia_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'presentation/screens/scanner_screen.dart';
import 'src/presentation/bloc/asistencia_bloc.dart';
import 'src/presentation/bloc/auth_trabajador_bloc.dart';
import 'src/presentation/bloc/auth_trabajador_event.dart';
import 'src/presentation/bloc/auth_trabajador_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AppWithBloCs());
}

class AppWithBloCs extends StatelessWidget {
  const AppWithBloCs({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => FirebaseAuthService()),
        RepositoryProvider(create: (_) => FirestoreService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthTrabajadorBloc(
              authService: context.read<FirebaseAuthService>(),
              firestoreService: context.read<FirestoreService>(),
            )..add(const VerificarSesionTrabajadorEvent()),
          ),
          BlocProvider(
            create: (context) => AsistenciaBloc(
              firestoreService: context.read<FirestoreService>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistencia Trabajador',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: BlocBuilder<AuthTrabajadorBloc, AuthTrabajadorState>(
        builder: (context, state) {
          if (state is AuthTrabajadorAutenticado) {
            return ScannerScreen(
              idTrabajador: state.usuarioId,
              dni: state.dni,
              nombreTrabajador: state.nombreCompleto,
            );
          }

          return const TrabajadorAuthScreen();
        },
      ),
    );
  }
}

class TrabajadorAuthScreen extends StatefulWidget {
  const TrabajadorAuthScreen({super.key});

  @override
  State<TrabajadorAuthScreen> createState() => _TrabajadorAuthScreenState();
}

class _TrabajadorAuthScreenState extends State<TrabajadorAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _dniController = TextEditingController();
  final _cargoController = TextEditingController();
  final _sedeIdController = TextEditingController();
  bool _registro = false;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _dniController.dispose();
    _cargoController.dispose();
    _sedeIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<AuthTrabajadorBloc>();
    if (_registro) {
      bloc.add(
        RegistroTrabajadorEvent(
          nombreCompleto: _nombreController.text.trim(),
          dni: _dniController.text.trim(),
          cargo: _cargoController.text.trim(),
          correo: _correoController.text.trim(),
          contrasena: _passwordController.text,
          idSede: _sedeIdController.text.trim(),
        ),
      );
    } else {
      bloc.add(
        LoginTrabajadorEvent(
          correo: _correoController.text.trim(),
          contrasena: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingreso trabajador')),
      body: BlocConsumer<AuthTrabajadorBloc, AuthTrabajadorState>(
        listener: (context, state) {
          if (state is AuthTrabajadorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        builder: (context, state) {
          final cargando = state is AuthTrabajadorCargando ||
              state is VerificandoSesionTrabajador;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('Login')),
                          ButtonSegment(value: true, label: Text('Registro')),
                        ],
                        selected: {_registro},
                        onSelectionChanged: (value) {
                          setState(() => _registro = value.first);
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_registro) ...[
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                              labelText: 'Nombre completo'),
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dniController,
                          decoration: const InputDecoration(labelText: 'DNI'),
                          keyboardType: TextInputType.number,
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cargoController,
                          decoration: const InputDecoration(labelText: 'Cargo'),
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _sedeIdController,
                          decoration:
                              const InputDecoration(labelText: 'ID de sede'),
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _correoController,
                        decoration: const InputDecoration(labelText: 'Correo'),
                        keyboardType: TextInputType.emailAddress,
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration:
                            const InputDecoration(labelText: 'Contrasena'),
                        obscureText: true,
                        validator: _required,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: cargando ? null : _submit,
                        child: Text(cargando
                            ? 'Cargando...'
                            : _registro
                                ? 'Crear cuenta'
                                : 'Ingresar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }
}
