import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'huellitas_theme.dart';
import 'registro.dart';
import 'registro_repository.dart';

void main() {
  runApp(const HuellitasApp());
}

class HuellitasApp extends StatelessWidget {
  final RegistroRepository repository;

  const HuellitasApp({
    super.key,
    this.repository = const RegistroSimuladoRepository(),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huellitas Veterinaria',
      debugShowCheckedModeBanner: false,
      // El tema vive en MaterialApp para que también lo hereden los menús,
      // diálogos y avisos, que se dibujan fuera de la pantalla.
      theme: HuellitasTheme.theme,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: FormularioRegistroPage(repository: repository),
    );
  }
}
