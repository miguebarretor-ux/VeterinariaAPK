import 'package:flutter/material.dart';

import 'huellitas_theme.dart';
import 'inicio_sesion.dart';
import 'registro.dart';
import 'registro_repository.dart';
import 'widgets/clay.dart';

/// Primera pantalla: presenta la app y deja elegir entre iniciar sesión o
/// crear una cuenta.
class BienvenidaPage extends StatelessWidget {
  final RegistroRepository repository;

  const BienvenidaPage({super.key, required this.repository});

  void _abrir(BuildContext context, Widget pagina) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: HuellitasTheme.lavanda,
                        shape: BoxShape.circle,
                        boxShadow: HuellitasTheme.clay,
                      ),
                      child: const ExcludeSemantics(
                        child: Icon(Icons.pets_rounded, size: 56, color: HuellitasTheme.ink),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    header: true,
                    child: Text(
                      'Huellitas',
                      textAlign: TextAlign.center,
                      style: textos.displayLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'La veterinaria de tu mascota, siempre a la mano.',
                    textAlign: TextAlign.center,
                    style: textos.bodyLarge!.copyWith(color: HuellitasTheme.inkSoft),
                  ),
                  const SizedBox(height: 44),
                  ClayButton(
                    label: 'Crear cuenta',
                    onPressed: () =>
                        _abrir(context, FormularioRegistroPage(repository: repository)),
                  ),
                  const SizedBox(height: 16),
                  ClayButton(
                    label: 'Iniciar sesión',
                    secundario: true,
                    onPressed: () => _abrir(context, InicioSesionPage(repository: repository)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
