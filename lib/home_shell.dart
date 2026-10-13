import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'inicio.dart';
import 'citas.dart';
import 'carnet.dart';
import 'bienvenida.dart';
import 'tienda.dart';
import 'repositories/usuario_repository.dart';

class HomeShell extends StatefulWidget {
  final UsuarioModel usuario;
  const HomeShell({super.key, required this.usuario});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
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

  void _irPerfil() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BienvenidaPage(usuario: _usuario)),
      );

  @override
  Widget build(BuildContext context) {
    final pages = [
      InicioDashboard(
        key: const ValueKey(0),
        usuario: _usuario,
        onNavigate: (i) => setState(() => _tab = i),
        onPerfil: _irPerfil,
      ),
      CitasPage(key: const ValueKey(1), usuario: _usuario),
      CarnetPage(key: const ValueKey(2), usuario: _usuario),
      TiendaPage(key: const ValueKey(3), usuario: _usuario),
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
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Citas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              label: 'Carnet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              label: 'Tienda',
            ),
          ],
        ),
      ),
    );
  }
}
