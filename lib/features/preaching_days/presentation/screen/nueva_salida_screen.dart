import 'package:flutter/material.dart';

class NuevaSalidaScreen extends StatelessWidget {
  const NuevaSalidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Salida')),
      body: const Center(child: Text('Nueva Salida')),
    );
  }
}