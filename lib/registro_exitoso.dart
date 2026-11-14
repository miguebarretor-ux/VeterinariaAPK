import 'package:flutter/material.dart';

import 'huellitas_theme.dart';
import 'mascota_model.dart';
import 'inicio.dart';
import 'registro_repository.dart';
import 'widgets/clay.dart';

/// Confirmación del registro: deja claro que la cuenta quedó creada y muestra
/// lo que se guardó, en vez de un aviso que desaparece a los pocos segundos.
class RegistroExitosoPage extends StatelessWidget {
  final UsuarioModel usuario;
  final RegistroRepository repository;

  const RegistroExitosoPage({super.key, required this.usuario, required this.repository});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final mascota = usuario.tieneMascota ? usuario.mascota : null;

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
                      width: 84, // --icon-chip-size
                      height: 84,
                      decoration: HuellitasTheme.chipBox(color: HuellitasTheme.menta),
                      child: const Icon(Icons.check_rounded, size: 44, color: HuellitasTheme.ink),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Semantics(
                    header: true,
                    liveRegion: true,
                    child: Text(
                      '¡Listo, ${usuario.nombre}!',
                      textAlign: TextAlign.center,
                      style: textos.displayLarge!.copyWith(fontSize: 34),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tu cuenta en Huellitas ya está creada.',
                    textAlign: TextAlign.center,
                    style: textos.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  ClayCard(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                    child: Column(
                      children: [
                        DatoCuenta(
                          icon: Icons.mail_outline_rounded,
                          titulo: 'Inicias sesión con',
                          valor: usuario.correo,
                        ),
                        if (mascota != null) ...[
                          const Divider(height: 1, color: HuellitasTheme.borde),
                          DatoCuenta(
                            icon: Icons.pets_rounded,
                            titulo: 'Carnet creado para',
                            valor: mascota.nombre,
                            detalle: mascota.resumen,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ClayButton(
                    label: 'Ir al inicio',
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => InicioPage(usuario: usuario, repository: repository),
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
