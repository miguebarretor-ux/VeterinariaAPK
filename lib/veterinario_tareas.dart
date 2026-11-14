import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'repositories/usuario_repository.dart';

class VeterinarioTareasPage extends StatefulWidget {
  final UsuarioModel veterinario;
  const VeterinarioTareasPage({super.key, required this.veterinario});

  @override
  State<VeterinarioTareasPage> createState() => _VeterinarioTareasPageState();
}

class _VeterinarioTareasPageState extends State<VeterinarioTareasPage> {
  List<_CitaConDueno> _tareas = [];
  bool _cargando = true;
  StreamSubscription<QuerySnapshot>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FirebaseFirestore.instance
        .collectionGroup('citas')
        .where('veterinarioId', isEqualTo: widget.veterinario.uid)
        .snapshots()
        .listen(
      (snap) async {
        final items = <_CitaConDueno>[];
        for (final doc in snap.docs) {
          final cita = CitaModel.fromJson(
              {'id': doc.id, ...doc.data()});
          // El UID del dueño es el padre del documento: usuarios/{uid}/citas/{id}
          final duenoUid = doc.reference.parent.parent?.id;
          if (duenoUid == null) continue;
          final dueno = await UsuarioRepository.obtener(duenoUid);
          if (dueno != null) items.add(_CitaConDueno(cita: cita, dueno: dueno));
        }
        // Ordenar: próximas primero, luego historial
        items.sort((a, b) => a.cita.fecha.compareTo(b.cita.fecha));
        if (mounted) setState(() { _tareas = items; _cargando = false; });
      },
      onError: (_) {
        if (mounted) setState(() => _cargando = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proximas =
        _tareas.where((t) => t.cita.esProxima).toList();
    final historial =
        _tareas.where((t) => !t.cita.esProxima).toList()
          ..sort((a, b) => b.cita.fecha.compareTo(a.cita.fecha));

    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      appBar: AppBar(
        backgroundColor: HuellitasTheme.ink,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              'Mis Tareas',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.w800,
                color: HuellitasTheme.leche,
              ),
            ),
          ],
        ),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: HuellitasTheme.menta))
          : _tareas.isEmpty
              ? _EmptyState()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    // Resumen
                    Container(
                      decoration: HuellitasTheme.cardBox(
                          color: HuellitasTheme.menta),
                      padding: const EdgeInsets.all(20),
                      child: Row(children: [
                        const Icon(Icons.task_alt_rounded,
                            color: HuellitasTheme.ink, size: 28),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${proximas.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge),
                            Text(
                              proximas.length == 1
                                  ? 'cita próxima'
                                  : 'citas próximas',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: HuellitasTheme.inkSoft),
                            ),
                          ],
                        ),
                      ]),
                    ),
                    // Próximas
                    if (proximas.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const SectionLabel('Próximas'),
                      const SizedBox(height: 12),
                      ...proximas.map((t) => _TareaCard(item: t)),
                    ],
                    // Historial
                    if (historial.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const SectionLabel('Historial'),
                      const SizedBox(height: 12),
                      ...historial.map(
                          (t) => _TareaCard(item: t, pasada: true)),
                    ],
                  ],
                ),
    );
  }
}

// ── TARJETA DE TAREA ──────────────────────────────────────────────────────────

class _TareaCard extends StatefulWidget {
  final _CitaConDueno item;
  final bool pasada;
  const _TareaCard({required this.item, this.pasada = false});

  @override
  State<_TareaCard> createState() => _TareaCardState();
}

class _TareaCardState extends State<_TareaCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final cita = widget.item.cita;
    final dueno = widget.item.dueno;
    final mascota = dueno.mascotas
        .cast<MascotaModel?>()
        .firstWhere((m) => m?.nombre == cita.mascota, orElse: () => null);

    return GestureDetector(
      onTap: () => setState(() => _expandido = !_expandido),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: HuellitasTheme.cardBox(
          color: widget.pasada
              ? HuellitasTheme.arena
              : HuellitasTheme.leche,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila principal
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 12, top: 4),
                  decoration: BoxDecoration(
                    color: widget.pasada
                        ? HuellitasTheme.inkSoft
                        : HuellitasTheme.menta,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cita.servicio,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: widget.pasada
                                  ? HuellitasTheme.inkSoft
                                  : HuellitasTheme.ink,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${cita.fechaFormateada}  ·  ${cita.hora}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: HuellitasTheme.inkSoft,
                                fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expandido
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: HuellitasTheme.inkSoft,
                ),
              ],
            ),
            // Chips cliente + mascota (siempre visibles)
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 6, children: [
              _InfoChip(
                icono: Icons.person_outline,
                label: '${dueno.nombre} ${dueno.apellido}',
              ),
              _InfoChip(
                icono: Icons.pets,
                label: cita.mascota,
              ),
            ]),
            // Detalle expandible
            if (_expandido) ...[
              const SizedBox(height: 16),
              const Divider(color: HuellitasTheme.arena, thickness: 1.5),
              const SizedBox(height: 12),
              const SectionLabel('Cliente'),
              const SizedBox(height: 8),
              _DetalleRow(
                  icono: Icons.email_outlined, texto: dueno.correo),
              if (dueno.numeroDocumento.isNotEmpty)
                _DetalleRow(
                  icono: Icons.badge_outlined,
                  texto:
                      '${dueno.tipoDocumento}: ${dueno.numeroDocumento}',
                ),
              if (mascota != null) ...[
                const SizedBox(height: 14),
                const SectionLabel('Mascota'),
                const SizedBox(height: 8),
                _DetalleRow(
                    icono: Icons.pets,
                    texto:
                        '${mascota.nombre} · ${mascota.tipo} · ${mascota.raza}'),
                _DetalleRow(
                    icono: Icons.cake_outlined,
                    texto: '${mascota.edad} año${mascota.edad == 1 ? '' : 's'}'),
                if (mascota.peso != null)
                  _DetalleRow(
                      icono: Icons.monitor_weight_outlined,
                      texto: '${mascota.peso} kg'),
                if (mascota.vacunas.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: mascota.vacunas
                        .map((v) => _VacunaChip(vacuna: v))
                        .toList(),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ── SUBWIDGETS ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icono;
  final String label;
  const _InfoChip({required this.icono, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: HuellitasTheme.arena,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icono, size: 12, color: HuellitasTheme.inkSoft),
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

class _DetalleRow extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _DetalleRow({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icono, size: 15, color: HuellitasTheme.inkSoft),
        const SizedBox(width: 8),
        Expanded(
          child: Text(texto,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}

class _VacunaChip extends StatelessWidget {
  final VacunaModel vacuna;
  const _VacunaChip({required this.vacuna});

  Color get _color {
    switch (vacuna.estado) {
      case 'vencida':
        return HuellitasTheme.coral;
      case 'por_vencer':
        return HuellitasTheme.lima;
      default:
        return HuellitasTheme.menta;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: _color, borderRadius: BorderRadius.circular(999)),
      child: Text(
        '${vacuna.nombre} · ${vacuna.fechaAplicacionFmt}',
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: HuellitasTheme.ink),
      ),
    );
  }
}

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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: HuellitasTheme.menta,
                borderRadius: BorderRadius.circular(36),
                boxShadow: HuellitasTheme.claySm,
              ),
              child: const Icon(Icons.task_alt_rounded,
                  size: 36, color: HuellitasTheme.ink),
            ),
            const SizedBox(height: 20),
            Text('Sin citas asignadas',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Cuando el admin te asigne una cita\naparecerá aquí.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: HuellitasTheme.inkSoft),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── DATA CLASS ────────────────────────────────────────────────────────────────

class _CitaConDueno {
  final CitaModel cita;
  final UsuarioModel dueno;
  const _CitaConDueno({required this.cita, required this.dueno});
}
