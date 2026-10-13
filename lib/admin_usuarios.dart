import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'admin_detalle.dart';
import 'repositories/usuario_repository.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  List<UsuarioModel> _usuarios = [];
  StreamSubscription<List<UsuarioModel>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = UsuarioRepository.todos().listen((lista) {
      if (mounted) setState(() => _usuarios = lista);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _usuarios.isEmpty ? _EmptyState() : _Lista(usuarios: _usuarios);
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: HuellitasTheme.lavanda,
                borderRadius: BorderRadius.circular(36),
                boxShadow: HuellitasTheme.claySm,
              ),
              child: const Icon(Icons.people_outline_rounded,
                  size: 36, color: HuellitasTheme.ink),
            ),
            const SizedBox(height: 20),
            Text('Sin usuarios registrados',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Los usuarios aparecerán aquí cuando se registren',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: HuellitasTheme.inkSoft),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── LISTA ─────────────────────────────────────────────────────────────────────

class _Lista extends StatelessWidget {
  final List<UsuarioModel> usuarios;
  const _Lista({required this.usuarios});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Resumen
        Container(
          decoration: HuellitasTheme.cardBox(color: HuellitasTheme.lavanda),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.people_outline_rounded,
                  color: HuellitasTheme.ink, size: 28),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${usuarios.length}',
                      style: Theme.of(context).textTheme.displayLarge),
                  Text(
                    usuarios.length == 1 ? 'usuario registrado' : 'usuarios registrados',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: HuellitasTheme.inkSoft),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Usuarios'),
        const SizedBox(height: 12),
        ...usuarios.map((u) => _UsuarioCard(usuario: u)),
      ],
    );
  }
}

// ── TARJETA USUARIO ───────────────────────────────────────────────────────────

class _UsuarioCard extends StatelessWidget {
  final UsuarioModel usuario;
  const _UsuarioCard({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final nMascotas = usuario.mascotas.length;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => AdminDetallePage(usuario: usuario)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: HuellitasTheme.cardBox(),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: HuellitasTheme.lavanda,
                borderRadius: BorderRadius.circular(26),
                boxShadow: HuellitasTheme.claySm,
              ),
              child: Center(
                child: Text(
                  usuario.nombre.isNotEmpty
                      ? usuario.nombre[0].toUpperCase()
                      : '?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${usuario.nombre} ${usuario.apellido}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    usuario.correo,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: HuellitasTheme.inkSoft, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    _Chip(
                      icon: Icons.pets,
                      label: '$nMascotas mascota${nMascotas == 1 ? '' : 's'}',
                    ),
                  ]),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: HuellitasTheme.inkSoft),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: HuellitasTheme.arena,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: HuellitasTheme.inkSoft),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: HuellitasTheme.inkSoft)),
      ]),
    );
  }
}
