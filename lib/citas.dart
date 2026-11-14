import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'repositories/cita_repository.dart';
import 'repositories/db.dart';
import 'repositories/usuario_repository.dart';
import 'repositories/servicio_repository.dart';

class CitasPage extends StatefulWidget {
  final UsuarioModel usuario;
  const CitasPage({super.key, required this.usuario});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
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

  Future<void> _cancelar(CitaModel c) async {
    if (c.id == null) return;
    try {
      await CitaRepository.cancelar(c);
      if (mounted) mostrarAviso(context, 'Cita cancelada.');
    } catch (e) {
      if (mounted) mostrarAviso(context, mensajeDeError(e), error: true);
    }
  }

  void _abrirForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _CitaSheet(
          mascotas: widget.usuario.mascotas,
          onGuardar: (c) => CitaRepository.agendar(widget.usuario.uid!, c),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Próximas: pendientes de hoy en adelante. El resto (atendidas,
    // canceladas o pasadas) va al historial.
    final proximas = _citas.where((c) => c.esProxima).toList()
      ..sort((a, b) => a.claveOrden.compareTo(b.claveOrden));
    final pasadas = _citas.where((c) => !c.esProxima).toList()
      ..sort((a, b) => b.claveOrden.compareTo(a.claveOrden));

    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      appBar: AppBar(
        title: const Text('Mis citas'),
        backgroundColor: HuellitasTheme.arena,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirForm,
        backgroundColor: HuellitasTheme.lima,
        foregroundColor: HuellitasTheme.ink,
        elevation: 0,
        icon: const Icon(Icons.add),
        label: const Text(
          'Agendar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _citas.isEmpty
          ? _EmptyState(onTap: _abrirForm)
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                if (proximas.isNotEmpty) ...[
                  const SectionLabel('Próximas'),
                  const SizedBox(height: 12),
                  ...proximas.map(
                    (c) => _CitaCard(cita: c, onCancelar: () => _cancelar(c)),
                  ),
                ],
                if (pasadas.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const SectionLabel('Historial'),
                  const SizedBox(height: 12),
                  ...pasadas.map(
                    (c) => _CitaCard(cita: c, pasada: true),
                  ),
                ],
              ],
            ),
    );
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

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
                color: HuellitasTheme.lavanda,
                borderRadius: BorderRadius.circular(36),
                boxShadow: HuellitasTheme.claySm,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 36,
                color: HuellitasTheme.ink,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin citas agendadas',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Agenda la primera cita para tu mascota',
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

// ── TARJETA DE CITA ───────────────────────────────────────────────────────────

class _CitaCard extends StatelessWidget {
  final CitaModel cita;
  final bool pasada;

  /// Solo las citas próximas se pueden cancelar.
  final VoidCallback? onCancelar;
  const _CitaCard({required this.cita, this.pasada = false, this.onCancelar});

  @override
  Widget build(BuildContext context) {
    const suave = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: HuellitasTheme.inkSoft,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: HuellitasTheme.cardBox(
        color: pasada ? HuellitasTheme.arena : HuellitasTheme.leche,
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cita.servicio,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: pasada ? HuellitasTheme.inkSoft : HuellitasTheme.ink,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cita.fechaFormateada}  ·  ${cita.hora}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: HuellitasTheme.inkSoft, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(cita.mascota, style: suave),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.medical_services_outlined,
                      size: 13, color: HuellitasTheme.inkSoft),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      cita.sinAsignar
                          ? 'Veterinario por asignar'
                          : cita.veterinarioNombre ?? 'Veterinario asignado',
                      style: suave,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                EstadoChip(
                  // Una cita pendiente cuya fecha ya pasó no se atendió.
                  pasada && cita.estado == EstadoCita.pendiente
                      ? 'Sin atender'
                      : cita.estado.etiqueta,
                  color: pasada && cita.estado == EstadoCita.pendiente
                      ? HuellitasTheme.arena
                      : colorEstadoCita(cita.estado),
                ),
                if (cita.notas.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Notas del veterinario: ${cita.notas}',
                      style: suave.copyWith(fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
          if (onCancelar != null)
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  title: const Text('Cancelar cita'),
                  content: Text(
                      '¿Cancelar "${cita.servicio}" del ${cita.fechaFormateada} '
                      'a las ${cita.hora}? Quedará en tu historial.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Volver'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onCancelar!();
                      },
                      child: const Text('Cancelar cita',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              child: const Text('Cancelar'),
            ),
        ],
      ),
    );
  }
}

// ── FORMULARIO (bottom sheet) ─────────────────────────────────────────────────

class _CitaSheet extends StatefulWidget {
  final List<MascotaModel> mascotas;
  final Future<void> Function(CitaModel) onGuardar;
  const _CitaSheet({required this.mascotas, required this.onGuardar});

  @override
  State<_CitaSheet> createState() => _CitaSheetState();
}

class _CitaSheetState extends State<_CitaSheet> {
  static const _horas = [
    '08:00', '09:00', '10:00', '11:00',
    '12:00', '14:00', '15:00', '16:00', '17:00',
  ];

  // Servicios dinámicos desde Firestore; lista de respaldo por si no hay datos.
  static const _serviciosFallback = [
    'Control de rutina', 'Vacunación', 'Consulta general',
    'Peluquería', 'Urgencias',
  ];

  List<String> _servicios = _serviciosFallback;
  String? _servicio;
  DateTime? _fecha;
  String? _hora;
  String? _mascotaId;

  List<UsuarioModel> _vets = [];
  bool _cargandoVets = true;
  String? _vetId;

  /// Horas que el veterinario elegido ya tiene reservadas en la fecha elegida.
  Set<String> _ocupadas = {};
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.mascotas.isNotEmpty) _mascotaId = widget.mascotas.first.id;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    // Cada carga falla por separado: sin veterinarios aún se puede agendar
    // "sin preferencia", y sin servicios se usa la lista de respaldo.
    List<UsuarioModel> vets = [];
    List<ServicioModel> svcs = [];
    try {
      vets = await UsuarioRepository.veterinariosOnce();
    } catch (_) {}
    try {
      svcs = await ServicioRepository.streamActivos()
          .first
          .timeout(const Duration(seconds: 6), onTimeout: () => []);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _vets = vets;
      _cargandoVets = false;
      if (svcs.isNotEmpty) _servicios = svcs.map((s) => s.nombre).toList();
      _servicio = _servicios.first;
    });
  }

  String? get _fechaIso => _fecha == null
      ? null
      : '${_fecha!.year.toString().padLeft(4, '0')}-'
          '${_fecha!.month.toString().padLeft(2, '0')}-'
          '${_fecha!.day.toString().padLeft(2, '0')}';

  /// Hoy no se ofrecen horas que ya pasaron.
  bool _yaPaso(String hora) {
    final f = _fecha;
    if (f == null) return false;
    final p = hora.split(':');
    return DateTime(f.year, f.month, f.day, int.parse(p[0]), int.parse(p[1]))
        .isBefore(DateTime.now());
  }

  bool _disponible(String hora) => !_yaPaso(hora) && !_ocupadas.contains(hora);

  /// Recalcula las horas ocupadas al cambiar de fecha o de veterinario.
  Future<void> _actualizarOcupadas() async {
    final vet = _vetId;
    final fecha = _fechaIso;
    var ocupadas = <String>{};
    if (vet != null && fecha != null) {
      try {
        ocupadas = await CitaRepository.horasOcupadas(vet, fecha);
      } catch (_) {
        // Si no se pueden consultar, la reserva igual se valida al guardar.
      }
    }
    // Se ignora la respuesta si mientras tanto cambió la selección.
    if (!mounted || vet != _vetId || fecha != _fechaIso) return;
    setState(() {
      _ocupadas = ocupadas;
      if (_hora != null && !_disponible(_hora!)) _hora = null;
    });
  }

  Future<void> _pickDate() async {
    final hoy = DateTime.now();
    final dt = await showDatePicker(
      context: context,
      initialDate: _fecha ?? hoy,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: HuellitasTheme.lavanda,
                onPrimary: HuellitasTheme.ink,
              ),
        ),
        child: child!,
      ),
    );
    if (dt == null) return;
    setState(() {
      _fecha = dt;
      if (_hora != null && !_disponible(_hora!)) _hora = null;
    });
    _actualizarOcupadas();
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    final falta = _mascotaId == null
        ? 'Elige la mascota'
        : _fecha == null
            ? 'Selecciona una fecha'
            : _hora == null
                ? 'Elige una hora disponible'
                : null;
    if (falta != null) {
      setState(() => _error = falta);
      return;
    }
    final mascota = widget.mascotas.firstWhere((m) => m.id == _mascotaId);
    final vet = _vetId == null
        ? null
        : _vets.cast<UsuarioModel?>().firstWhere((v) => v?.uid == _vetId,
            orElse: () => null);

    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await widget.onGuardar(CitaModel(
        mascota: mascota.nombre,
        mascotaId: mascota.id,
        servicio: _servicio ?? _servicios.first,
        fecha: _fechaIso!,
        hora: _hora!,
        veterinarioId: vet?.uid,
        veterinarioNombre: vet?.nombreCompleto,
      ));
      if (!mounted) return;
      Navigator.pop(context);
      mostrarAviso(
        context,
        vet == null
            ? 'Cita agendada. Te asignaremos un veterinario.'
            : 'Cita agendada con ${vet.nombreCompleto}.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = mensajeDeError(e);
      });
      // Si alguien tomó el horario mientras tanto, se refrescan las horas.
      if (e is OperacionException) _actualizarOcupadas();
    }
  }

  String _fmtDate(DateTime dt) {
    const m = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final sinMascotas = widget.mascotas.isEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: HuellitasTheme.cardBox(radius: 36),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tirador
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HuellitasTheme.lavanda,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Agendar cita', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),

            if (sinMascotas)
              const AvisoEnLinea(
                  'Primero registra a tu mascota en el carnet para poder agendarle una cita.')
            else ...[
              // Mascota
              DropdownButtonFormField<String>(
                initialValue: _mascotaId,
                decoration: HuellitasTheme.field('Mascota'),
                items: widget.mascotas
                    .map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _mascotaId = v),
              ),
              const SizedBox(height: 12),

              // Servicio
              DropdownButtonFormField<String>(
                key: ValueKey('servicio-$_servicio-${_servicios.length}'),
                initialValue: _servicio,
                decoration: HuellitasTheme.field('Servicio'),
                items: _servicios
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _servicio = v),
              ),
              const SizedBox(height: 12),

              // Veterinario
              if (_cargandoVets)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: HuellitasTheme.lavanda),
                  ),
                )
              else
                DropdownButtonFormField<String?>(
                  initialValue: _vetId,
                  decoration: HuellitasTheme.field('Veterinario'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Sin preferencia')),
                    ..._vets.map((v) => DropdownMenuItem(
                          value: v.uid,
                          child: Text(
                            v.especialidad.isEmpty
                                ? v.nombreCompleto
                                : '${v.nombreCompleto} · ${v.especialidad}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                  onChanged: (id) {
                    setState(() => _vetId = id);
                    _actualizarOcupadas();
                  },
                ),
              if (!_cargandoVets && _vetId == null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 8),
                  child: Text(
                    'La clínica te asignará un veterinario disponible.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: HuellitasTheme.inkSoft, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 12),

              // Fecha
              Semantics(
                button: true,
                label: _fecha == null
                    ? 'Seleccionar fecha'
                    : 'Fecha: ${_fmtDate(_fecha!)}',
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      color: HuellitasTheme.arena,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: HuellitasTheme.inkSoft),
                      const SizedBox(width: 10),
                      ExcludeSemantics(
                        child: Text(
                          _fecha == null
                              ? 'Seleccionar fecha'
                              : _fmtDate(_fecha!),
                          style: TextStyle(
                            fontSize: 16,
                            color: _fecha == null
                                ? HuellitasTheme.inkSoft
                                : HuellitasTheme.ink,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Hora: todas a la vista; las ocupadas o pasadas, desactivadas.
              const SectionLabel('Hora'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final h in _horas)
                    ChoiceChip(
                      label: Text(h),
                      selected: _hora == h,
                      onSelected:
                          _disponible(h) ? (_) => setState(() => _hora = h) : null,
                      selectedColor: HuellitasTheme.lavanda,
                      backgroundColor: HuellitasTheme.arena,
                      disabledColor: HuellitasTheme.arena,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _disponible(h)
                            ? HuellitasTheme.ink
                            : HuellitasTheme.inkSoft.withAlpha(120),
                        decoration:
                            _disponible(h) ? null : TextDecoration.lineThrough,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                      side: BorderSide.none,
                    ),
                ],
              ),
              if (_ocupadas.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 8),
                  child: Text(
                    'Las horas tachadas ya están ocupadas con ese veterinario.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: HuellitasTheme.inkSoft, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              if (_error != null) ...[
                AvisoEnLinea(_error!),
                const SizedBox(height: 14),
              ],

              ClayButton(
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: HuellitasTheme.ink),
                        )
                      : const Text('Reservar cita'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
