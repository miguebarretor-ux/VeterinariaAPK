import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'login.dart';
import 'veterinario_tareas.dart';
import 'repositories/usuario_repository.dart';
import 'services/auth_service.dart';

class VeterinarioShell extends StatefulWidget {
  final UsuarioModel usuario;
  const VeterinarioShell({super.key, required this.usuario});

  @override
  State<VeterinarioShell> createState() => _VeterinarioShellState();
}

class _VeterinarioShellState extends State<VeterinarioShell> {
  int _tab = 0;
  late UsuarioModel _usuario;
  StreamSubscription<UsuarioModel?>? _sub;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
    _sub = UsuarioRepository.stream(widget.usuario.uid!).listen((u) {
      if (mounted && u != null) setState(() => _usuario = u);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _cerrarSesion() async {
    await AuthService.cerrarSesion();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const IniciarSesionPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      VeterinarioTareasPage(veterinario: _usuario),
      _VetPerfilPage(usuario: _usuario, onCerrarSesion: _cerrarSesion),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: HuellitasTheme.leche,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -4),
              blurRadius: 18,
              color: HuellitasTheme.ink.withAlpha(18),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: HuellitasTheme.leche,
          selectedItemColor: HuellitasTheme.ink,
          unselectedItemColor: HuellitasTheme.inkSoft,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_rounded),
              label: 'Mis Tareas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

// ── TAB PERFIL ─────────────────────────────────────────────────────────────────

class _VetPerfilPage extends StatelessWidget {
  final UsuarioModel usuario;
  final VoidCallback onCerrarSesion;
  const _VetPerfilPage(
      {required this.usuario, required this.onCerrarSesion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      appBar: AppBar(
        backgroundColor: HuellitasTheme.ink,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: HuellitasTheme.menta,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'VET',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: HuellitasTheme.ink,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Mi Perfil',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.w800,
                color: HuellitasTheme.leche,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: onCerrarSesion,
            icon: const Icon(Icons.logout_rounded,
                color: HuellitasTheme.coral, size: 18),
            label: const Text(
              'Salir',
              style: TextStyle(
                  color: HuellitasTheme.coral, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar + nombre
            Container(
              decoration: HuellitasTheme.cardBox(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: HuellitasTheme.menta,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: HuellitasTheme.claySm,
                    ),
                    child: Center(
                      child: Text(
                        usuario.nombre.isNotEmpty
                            ? usuario.nombre[0].toUpperCase()
                            : '?',
                        style:
                            Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${usuario.nombre} ${usuario.apellido}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (usuario.especialidad.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: HuellitasTheme.menta,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: HuellitasTheme.claySm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: HuellitasTheme.ink),
                          const SizedBox(width: 6),
                          Text(
                            usuario.especialidad,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: HuellitasTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Datos de contacto
            Container(
              decoration: HuellitasTheme.cardBox(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icono: Icons.email_outlined,
                    label: 'Correo',
                    valor: usuario.correo,
                  ),
                  if (usuario.numeroDocumento.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icono: Icons.badge_outlined,
                      label: usuario.tipoDocumento,
                      valor: usuario.numeroDocumento,
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

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  const _InfoRow(
      {required this.icono, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 18, color: HuellitasTheme.inkSoft),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: HuellitasTheme.inkSoft,
                      letterSpacing: 0.5)),
              Text(valor,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
