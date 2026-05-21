import 'package:asistencia_core/asistencia_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'presentation/screens/qr_screen.dart';
import 'src/presentation/bloc/auth_sede_bloc.dart';
import 'src/presentation/bloc/auth_sede_event.dart';
import 'src/presentation/bloc/auth_sede_state.dart';
import 'src/presentation/bloc/qr_dinamico_bloc.dart';

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
            create: (context) => AuthSedeBloc(
              authService: context.read<FirebaseAuthService>(),
              firestoreService: context.read<FirestoreService>(),
            ),
          ),
          BlocProvider(
            create: (context) => QRDinamicoBloc(
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
      title: 'Asistencia Sede',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocBuilder<AuthSedeBloc, AuthSedeState>(
        builder: (context, state) {
          if (state is AuthSedeAutenticado) {
            return QRScreen(
              idCuentaSede: state.usuarioId,
              sedeId: state.idSede,
              nombreSede: state.nombreSede,
              direccionSede: state.direccionSede,
              correoSede: state.correo,
            );
          }

          return const SedeAuthScreen();
        },
      ),
    );
  }
}

class SedeAuthScreen extends StatefulWidget {
  const SedeAuthScreen({super.key});

  @override
  State<SedeAuthScreen> createState() => _SedeAuthScreenState();
}

class _SedeAuthScreenState extends State<SedeAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _sedeIdController = TextEditingController();
  bool _registro = false;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _sedeIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<AuthSedeBloc>();
    if (_registro) {
      bloc.add(
        RegistrarSedeEvent(
          correo: _correoController.text.trim(),
          contrasena: _passwordController.text,
          nombreSede: _nombreController.text.trim(),
          direccion: _direccionController.text.trim(),
          idSede: _sedeIdController.text.trim(),
        ),
      );
    } else {
      bloc.add(
        LoginSedeEvent(
          correo: _correoController.text.trim(),
          contrasena: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingreso sede')),
      body: BlocConsumer<AuthSedeBloc, AuthSedeState>(
        listener: (context, state) {
          if (state is AuthSedeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        builder: (context, state) {
          final cargando =
              state is AuthSedeCargando || state is VerificandoSesion;

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
                              labelText: 'Nombre de sede'),
                          validator: _required,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _direccionController,
                          decoration:
                              const InputDecoration(labelText: 'Direccion'),
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
                        child: Text(
                          cargando
                              ? 'Cargando...'
                              : _registro
                                  ? 'Crear cuenta de sede'
                                  : 'Ingresar',
                        ),
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
