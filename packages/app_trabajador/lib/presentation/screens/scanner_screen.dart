import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../src/presentation/bloc/asistencia_bloc.dart';
import '../../src/presentation/bloc/asistencia_event.dart';
import '../../src/presentation/bloc/asistencia_state.dart';

class ScannerScreen extends StatefulWidget {
  final String idTrabajador;
  final String dni;
  final String nombreTrabajador;

  const ScannerScreen({
    super.key,
    required this.idTrabajador,
    required this.dni,
    required this.nombreTrabajador,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    context.read<AsistenciaBloc>().add(
          CargarAsistenciaDiaEvent(idTrabajador: widget.idTrabajador),
        );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_procesando) return;

    final codigo =
        capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (codigo == null || codigo.isEmpty) return;

    setState(() => _procesando = true);
    _procesarQR(codigo);
  }

  void _procesarQR(String codigo) {
    try {
      final jsonString = utf8.decode(base64Decode(codigo));
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final timestamp = data['timestamp'];
      final generadoEn = DateTime.fromMillisecondsSinceEpoch(
        timestamp is int ? timestamp : int.parse(timestamp.toString()),
      );
      final edadSegundos = DateTime.now().difference(generadoEn).inSeconds;

      if (edadSegundos < 0 || edadSegundos > 15) {
        _mostrarMensaje('QR expirado. Solicita uno nuevo.');
        return;
      }

      final tipoMarca = _tipoMarcaActual(context.read<AsistenciaBloc>().state);
      if (tipoMarca == null) {
        _mostrarMensaje('Ya registraste las 4 marcas de hoy.');
        return;
      }

      context.read<AsistenciaBloc>().add(
            RegistrarAsistenciaEvent(
              idTrabajador: widget.idTrabajador,
              dni: widget.dni,
              nombreTrabajador: widget.nombreTrabajador,
              idSede: (data['idSede'] ?? data['sedeId']).toString(),
              nombreSede: (data['nombreSede'] ?? 'Sede').toString(),
              tipoMarca: tipoMarca,
            ),
          );
    } catch (_) {
      _mostrarMensaje('QR invalido.');
    }
  }

  String? _tipoMarcaActual(AsistenciaState state) {
    if (state is AsistenciaDiaLoaded) {
      return _tipoDesdeCampos(
        horaInicio: state.asistencia.horaInicio,
        horaReceso: state.asistencia.horaReceso,
        horaFinReceso: state.asistencia.horaFinReceso,
        horaSalida: state.asistencia.horaSalida,
      );
    }

    if (state is AsistenciaRegistrada) {
      return _tipoDesdeCampos(
        horaInicio: state.asistencia.horaInicio,
        horaReceso: state.asistencia.horaReceso,
        horaFinReceso: state.asistencia.horaFinReceso,
        horaSalida: state.asistencia.horaSalida,
      );
    }

    return 'inicio';
  }

  String? _tipoDesdeCampos({
    required DateTime? horaInicio,
    required DateTime? horaReceso,
    required DateTime? horaFinReceso,
    required DateTime? horaSalida,
  }) {
    if (horaInicio == null) return 'inicio';
    if (horaReceso == null) return 'receso';
    if (horaFinReceso == null) return 'fin_receso';
    if (horaSalida == null) return 'salida';
    return null;
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _procesando = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear asistencia')),
      body: BlocConsumer<AsistenciaBloc, AsistenciaState>(
        listener: (context, state) {
          if (state is AsistenciaRegistrada) {
            _mostrarMensaje(
              'Marca registrada. Proxima: ${state.proximaMarca}',
            );
            context.read<AsistenciaBloc>().add(
                  CargarAsistenciaDiaEvent(idTrabajador: widget.idTrabajador),
                );
          }

          if (state is ErrorAsistencia) {
            _mostrarMensaje(state.mensaje);
          }
        },
        builder: (context, state) {
          final proximaMarca = _proximaMarcaTexto(state);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      widget.nombreTrabajador,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text('DNI: ${widget.dni}'),
                    const SizedBox(height: 8),
                    Text('Proxima marca: $proximaMarca'),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(onDetect: _onDetect),
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    if (_procesando)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Color(0x66000000),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _proximaMarcaTexto(AsistenciaState state) {
    if (state is AsistenciaDiaLoaded) return state.proximaMarca;
    if (state is AsistenciaRegistrada) return state.proximaMarca;
    if (state is AsistenciaCargando) return 'Cargando...';
    return 'Hora de Inicio';
  }
}
