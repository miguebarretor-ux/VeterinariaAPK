import 'package:flutter/material.dart';

import 'bienvenida.dart';
import 'huellitas_theme.dart';
import 'mascota_model.dart';
import 'registro_repository.dart';
import 'widgets/clay.dart';

/// Inicio con la sesión abierta. Por ahora solo saluda, muestra los datos de
/// la cuenta y permite cerrar sesión; aquí irán las citas y el carnet.
class InicioPage extends StatelessWidget {
  final UsuarioModel usuario;
  final RegistroRepository repository;

  const InicioPage({super.key, required this.usuario, required this.repository});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final mascota = usuario.tieneMascota ? usuario.mascota : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Hola, ${usuario.nombre}',
                      style: textos.displayLarge!.copyWith(fontSize: 34),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClayCard(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                    child: Column(
                      children: [
                        DatoCuenta(
                          icon: Icons.person_outline_rounded,
                          titulo: 'Tu cuenta',
                          valor: '${usuario.nombre} ${usuario.apellido}',
                          detalle: usuario.correo,
                        ),
                        const Divider(height: 1, color: HuellitasTheme.borde),
                        if (mascota != null)
                          DatoCuenta(
                            icon: Icons.pets_rounded,
                            titulo: 'Tu mascota',
                            valor: mascota.nombre,
                            detalle: mascota.resumen,
                          )
                        else
                          const DatoCuenta(
                            icon: Icons.pets_rounded,
                            titulo: 'Tu mascota',
                            valor: 'Aún no has registrado una',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ClayButton(
                    label: 'Cerrar sesión',
                    secundario: true,
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => BienvenidaPage(repository: repository),
                      ),
                      (_) => false,
                    ),
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
