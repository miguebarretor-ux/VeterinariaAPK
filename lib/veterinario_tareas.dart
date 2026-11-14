import 'dart:async';
import 'package:flutter/material.dart';
import 'admin_shell.dart' show AdminVacunaSheet;
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'repositories/cita_repository.dart';
import 'repositories/usuario_repository.dart';

class VeterinarioTareasPage extends StatefulWidget {
  final UsuarioModel veterinario;
  const VeterinarioTareasPage({super.key, required this.veterinario});

  @override
  State<VeterinarioTareasPage> createState() => _VeterinarioTareasPageState();
}

class _VeterinarioTareasPageState extends State<VeterinarioTareasPage> {
  List<CitaModel> _citas = [];
  List<_CitaConDueno> _tareas = [];
  bool _cargando = true;
  String? _error;
  StreamSubscription<List<CitaModel>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = CitaRepository.streamPorVeterinario(widget.veterinario.uid!).listen(
      (citas) {
        _citas = citas;
        _cargarDuenos();
      },
      onError: (Object e) {
        // Antes un fallo aquí se veía igual que "no tienes citas".
        if (mounted) {
          setState(() {
            _cargando = false;
            _error = mensajeDeError(e);
          });
        }
      },
    );
  }

  /// Carga (en paralelo y una vez por persona) el perfil del dueño de cada
  /// cita, para mostrar sus datos y los de la mascota.
  Future<void> _cargarDuenos() async {
    final uids = _citas.map((c) => c.duenoUid).whereType<String>().toSet();
    final duenos = <String, UsuarioModel>{};
    await Future.wait(uids.map((uid) async {
      try {
        final u = await UsuarioRepository.obtener(uid);
        if (u != null) duenos[uid] = u;
      } catch (_) {
        // La cita se muestra igual, sin los datos del dueño.
      }
    }));
    if (!mounted) return;
    final items = [
      for (final c in _citas) _CitaConDueno(cita: c, dueno: duenos[c.duenoUid]),
    ]..sort((a, b) => a.cita.claveOrden.compareTo(b.cita.claveOrden));
    setState(() {
      _tareas = items;
      _cargando = false;
      _error = null;
    });
  }

  Future<void> _ejecutar(Future<void> Function() accion, String exito) async {
    try {
      await accion();
      if (mounted) mostrarAviso(context, exito);
    } catch (e) {
      if (mounted) mostrarAviso(context, mensajeDeError(e), error: true);
    }
  }

  /// Marca la cita como atendida, con notas opcionales para el dueño.
  Future<void> _atender(CitaModel c) async {
    final notasCtrl = TextEditingController();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Marcar como atendida'),
        content: TextField(
          controller: notasCtrl,
          maxLines: 4,
          maxLength: 500,
          decoration: HuellitasTheme.field('Notas para el dueño',
              hint: 'Diagnóstico, tratamiento, próxima visita… (opcional)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Volver')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Marcar atendida',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await _ejecutar(
      () => CitaRepository.marcarAtendida(c, notas: notasCtrl.text),
      'Cita marcada como atendida.',
    );
  }

  void _registrarVacuna(UsuarioModel dueno, MascotaModel mascota) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AdminVacunaSheet(
          onGuardar: (v) async {
            await _ejecutar(
              () => UsuarioRepository.agregarVacuna(dueno.uid!, mascota.id, v),
              'Vacuna registrada en el carnet de ${mascota.nombre}.',
            );
            // El carnet vive en el perfil del dueño: se vuelve a leer.
            _cargarDuenos();
          },
        ),
      ),
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
          ..sort((a, b) => b.cita.claveOrden.compareTo(a.cita.claveOrden));

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
          : _error != null
              ? EstadoVacio(
                  icono: Icons.cloud_off_rounded,
                  color: HuellitasTheme.coral,
                  titulo: 'No pudimos cargar tus citas',
                  detalle: _error!,
                )
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
                      ...proximas.map((t) => _TareaCard(
                            item: t,
                            onAtender: () => _atender(t.cita),
                            onVacuna: _registrarVacuna,
                          )),
                    ],
                    // Historial
                    if (historial.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const SectionLabel('Historial'),
                      const SizedBox(height: 12),
                      ...historial.map((t) => _TareaCard(
                            item: t,
                            pasada: true,
                            // Una cita pendiente que ya pasó aún se puede cerrar.
                            onAtender: t.cita.estado == EstadoCita.pendiente
                                ? () => _atender(t.cita)
                                : null,
                            onReabrir: t.cita.estado == EstadoCita.atendida
                                ? () => _ejecutar(
                                    () => CitaRepository.reabrir(t.cita),
                                    'Cita reabierta.')
                                : null,
                            onVacuna: _registrarVacuna,
                          )),
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
  final VoidCallback? onAtender;
  final VoidCallback? onReabrir;
  final void Function(UsuarioModel dueno, MascotaModel mascota)? onVacuna;
  const _TareaCard({
    required this.item,
    this.pasada = false,
    this.onAtender,
    this.onReabrir,
    this.onVacuna,
  });

  @override
  State<_TareaCard> createState() => _TareaCardState();
}

class _TareaCardState extends State<_TareaCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final cita = widget.item.cita;
    final dueno = widget.item.dueno;
    final mascota = dueno == null ? null : cita.mascotaEn(dueno.mascotas);

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
              if (dueno != null)
                _InfoChip(
                  icono: Icons.person_outline,
                  label: dueno.nombreCompleto,
                ),
              _InfoChip(
                icono: Icons.pets,
                label: cita.mascota,
              ),
              EstadoChip(
                widget.pasada && cita.estado == EstadoCita.pendiente
                    ? 'Sin atender'
                    : cita.estado.etiqueta,
                color: colorEstadoCita(cita.estado),
              ),
            ]),
            // Detalle expandible
            if (_expandido) ...[
              const SizedBox(height: 16),
              const Divider(color: HuellitasTheme.arena, thickness: 1.5),
              const SizedBox(height: 12),
              if (dueno != null) ...[
                const SectionLabel('Cliente'),
                const SizedBox(height: 8),
                _DetalleRow(
                    icono: Icons.email_outlined, texto: dueno.correo),
              ],
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
              if (cita.notas.isNotEmpty) ...[
                const SizedBox(height: 14),
                const SectionLabel('Notas de la atención'),
                const SizedBox(height: 8),
                Text(cita.notas,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
              ],
              // Acciones del veterinario
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.onAtender != null)
                    FilledButton.icon(
                      onPressed: widget.onAtender,
                      style: FilledButton.styleFrom(
                        backgroundColor: HuellitasTheme.lima,
                        foregroundColor: HuellitasTheme.ink,
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Marcar atendida'),
                    ),
                  if (dueno != null && mascota != null && widget.onVacuna != null)
                    OutlinedButton.icon(
                      onPressed: () => widget.onVacuna!(dueno, mascota),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: HuellitasTheme.ink),
                      icon: const Icon(Icons.vaccines_outlined, size: 18),
                      label: const Text('Registrar vacuna'),
                    ),
                  if (widget.onReabrir != null)
                    TextButton(
                      onPressed: widget.onReabrir,
                      child: const Text('Reabrir'),
                    ),
                ],
              ),
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
              'Cuando un cliente te elija o el admin\nte asigne una cita, aparecerá aquí.',
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
  final UsuarioModel? dueno; // null si no se pudo leer su perfil
  const _CitaConDueno({required this.cita, this.dueno});
}
