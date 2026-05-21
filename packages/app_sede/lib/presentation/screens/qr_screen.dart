import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../src/presentation/bloc/auth_sede_bloc.dart';
import '../../src/presentation/bloc/auth_sede_event.dart';

class QRScreen extends StatefulWidget {
  final String idCuentaSede;
  final String sedeId;
  final String nombreSede;
  final String direccionSede;
  final String correoSede;

  const QRScreen({
    super.key,
    required this.idCuentaSede,
    required this.sedeId,
    required this.nombreSede,
    required this.direccionSede,
    required this.correoSede,
  });

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  static const int _intervaloSegundos = 15;

  Timer? _timer;
  String _qrData = '';
  int _segundosRestantes = _intervaloSegundos;

  @override
  void initState() {
    super.initState();
    _generarQR();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_segundosRestantes <= 1) {
        _generarQR();
      } else {
        setState(() => _segundosRestantes--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generarQR() {
    final payload = {
      'idCuentaSede': widget.idCuentaSede,
      'sedeId': widget.sedeId,
      'idSede': widget.sedeId,
      'nombreSede': widget.nombreSede,
      'direccionSede': widget.direccionSede,
      'correoSede': widget.correoSede,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    setState(() {
      _qrData = base64Encode(utf8.encode(jsonEncode(payload)));
      _segundosRestantes = _intervaloSegundos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR de asistencia'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: () {
              context.read<AuthSedeBloc>().add(const LogoutSedeEvent());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.nombreSede,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('ID: ${widget.sedeId}'),
              const SizedBox(height: 4),
              Text(widget.direccionSede),
              const SizedBox(height: 28),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 16,
                      color: Color(0x22000000),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 260,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Nuevo QR en $_segundosRestantes s',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
