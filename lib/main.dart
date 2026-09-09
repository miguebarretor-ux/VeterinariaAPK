import 'package:flutter/material.dart';
import 'registro.dart';

void main() {
  runApp(const HuellitasApp());
}

class HuellitasApp extends StatelessWidget {
  const HuellitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Huellitas Veterinaria',
      debugShowCheckedModeBanner: false,
      home: FormularioRegistroPage(),
    );
  }
}
