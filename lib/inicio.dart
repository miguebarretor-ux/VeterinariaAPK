import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'repositories/cita_repository.dart';

class InicioDashboard extends StatefulWidget {
  final UsuarioModel usuario;
  final void Function(int tab) onNavigate;
  final VoidCallback onPerfil;

  const InicioDashboard({
    super.key,
    required this.usuario,
    required this.onNavigate,
    required this.onPerfil,
  });

  @override
  State<InicioDashboard> createState() => _InicioDashboardState();
}

class _InicioDashboardState extends State<InicioDashboard> {
  List<CitaModel> _citas = [];
  StreamSubscription<List<CitaModel>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = CitaRepository.stream(widget.usuario.uid!).listen((citas) {
      if (mounted) setState(() => _citas = citas);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String get _saludo {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días,';
    if (h < 19) return 'Buenas tardes,';
    return 'Buenas noches,';
  }

  CitaModel? get _proximaCita {
    final proximas = _citas.where((c) => c.esProxima).toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    return proximas.isEmpty ? null : proximas.first;
  }

  @override
  Widget build(BuildContext context) {
    final proxima = _proximaCita;

    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          children: [

            // ── CABECERA ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _saludo,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: HuellitasTheme.inkSoft),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.usuario.nombre,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onPerfil,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: HuellitasTheme.lavanda,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: HuellitasTheme.claySm,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: HuellitasTheme.ink,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── TARJETA MASCOTA ───────────────────────────────────
            _PetCard(usuario: widget.usuario),
            const SizedBox(height: 16),

            // ── ACCIONES RÁPIDAS ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.calendar_month_rounded,
                    label: 'Citas',
                    color: HuellitasTheme.lavanda,
                    onTap: () => widget.onNavigate(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.medical_services_outlined,
                    label: 'Carnet',
                    color: HuellitasTheme.lima,
                    onTap: () => widget.onNavigate(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── PRÓXIMA CITA ──────────────────────────────────────
            const SectionLabel('Próxima cita'),
            const SizedBox(height: 12),
            _ProximaCitaCard(cita: proxima, onVerCitas: () => widget.onNavigate(1)),
          ],
        ),
      ),
    );
  }
}

// ── TARJETA MASCOTA ───────────────────────────────────────────────────────────

class _PetCard extends StatelessWidget {
  final UsuarioModel usuario;
  const _PetCard({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final m = usuario.mascota;
    final tiene = usuario.tieneMascota && m != null;

    return Container(
      decoration: HuellitasTheme.cardBox(),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: HuellitasTheme.lavanda,
              borderRadius: BorderRadius.circular(28),
              boxShadow: HuellitasTheme.claySm,
            ),
            child: const Icon(Icons.pets, color: HuellitasTheme.ink, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: tiene
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.nombre,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${m.tipo} · ${m.raza} · ${m.edad} año${m.edad == 1 ? '' : 's'}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: HuellitasTheme.inkSoft),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sin mascota registrada',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Agrega una desde tu perfil',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: HuellitasTheme.inkSoft),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── ACCIÓN RÁPIDA ─────────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: HuellitasTheme.claySm,
        ),
        child: Column(
          children: [
            Icon(icon, color: HuellitasTheme.ink, size: 28),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: HuellitasTheme.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PRÓXIMA CITA ──────────────────────────────────────────────────────────────

class _ProximaCitaCard extends StatelessWidget {
  final CitaModel? cita;
  final VoidCallback onVerCitas;
  const _ProximaCitaCard({this.cita, required this.onVerCitas});

  @override
  Widget build(BuildContext context) {
    if (cita == null) {
      return Container(
        decoration: HuellitasTheme.cardBox(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sin citas agendadas',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: HuellitasTheme.inkSoft),
            ),
            const SizedBox(height: 16),
            ClayButton(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agendar ahora'),
                onPressed: onVerCitas,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onVerCitas,
      child: Container(
        decoration: HuellitasTheme.cardBox(color: HuellitasTheme.lavanda),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cita!.servicio,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${cita!.fechaFormateada}  ·  ${cita!.hora}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: HuellitasTheme.inkSoft),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cita!.mascota,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: HuellitasTheme.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: HuellitasTheme.leche,
                borderRadius: BorderRadius.circular(22),
                boxShadow: HuellitasTheme.claySm,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: HuellitasTheme.ink,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
