import 'package:flutter/material.dart';

import 'huellitas_theme.dart';
import 'mascota_model.dart';
import 'registro.dart';
import 'registro_repository.dart';
import 'widgets/clay.dart';

/// Confirmación del registro: deja claro que la cuenta quedó creada y muestra
/// lo que se guardó, en vez de un aviso que desaparece a los pocos segundos.
class RegistroExitosoPage extends StatelessWidget {
  final UsuarioModel usuario;
  final RegistroRepository repository;

  /// Lleva al inicio de la app. Mientras no exista esa pantalla se deja en
  /// `null` y no se muestra el botón principal, para no prometer un destino
  /// que no hay.
  final VoidCallback? onContinuar;

  const RegistroExitosoPage({
    super.key,
    required this.usuario,
    this.repository = const RegistroSimuladoRepository(),
    this.onContinuar,
  });

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
                        _Dato(
                          icon: Icons.mail_outline_rounded,
                          titulo: 'Inicias sesión con',
                          valor: usuario.correo,
                        ),
                        if (mascota != null) ...[
                          const Divider(height: 1, color: HuellitasTheme.borde),
                          _Dato(
                            icon: Icons.pets_rounded,
                            titulo: 'Carnet creado para',
                            valor: mascota.nombre,
                            detalle: [
                              mascota.tipoLegible,
                              mascota.edadLegible,
                              if (mascota.raza.isNotEmpty) mascota.raza,
                              if (mascota.pesoLegible != null) mascota.pesoLegible!,
                            ].join(' · '),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (onContinuar != null) ...[
                    ClayButton(label: 'Ir al inicio', onPressed: onContinuar),
                    const SizedBox(height: 8),
                  ],
                  // Acción secundaria y con nombre explícito: abre un
                  // formulario nuevo, no "continúa" a ninguna parte.
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => FormularioRegistroPage(repository: repository),
                      ),
                    ),
                    child: const Text('Registrar otra cuenta'),
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

class _Dato extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  final String? detalle;

  const _Dato({
    required this.icon,
    required this.titulo,
    required this.valor,
    this.detalle,
  });

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: HuellitasTheme.arena,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: HuellitasTheme.ink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: textos.bodyMedium!.copyWith(
                      fontSize: 13,
                      color: HuellitasTheme.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valor,
                    style: textos.labelLarge!.copyWith(fontSize: 16),
                  ),
                  if (detalle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      detalle!,
                      style: textos.bodyMedium!.copyWith(color: HuellitasTheme.inkSoft),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
