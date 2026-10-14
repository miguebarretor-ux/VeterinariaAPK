import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'repositories/cita_repository.dart';
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

  void _eliminar(CitaModel c) {
    if (c.id == null) return;
    CitaRepository.eliminar(widget.usuario.uid!, c.id!);
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
          onGuardar: (c) => CitaRepository.agregar(widget.usuario.uid!, c),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proximas = _citas.where((c) => c.esProxima).toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final pasadas = _citas.where((c) => !c.esProxima).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

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
                    (c) => _CitaCard(cita: c, onEliminar: () => _eliminar(c)),
                  ),
                ],
                if (pasadas.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const SectionLabel('Historial'),
                  const SizedBox(height: 12),
                  ...pasadas.map(
                    (c) => _CitaCard(
                      cita: c,
                      pasada: true,
                      onEliminar: () => _eliminar(c),
                    ),
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
  final VoidCallback onEliminar;
  const _CitaCard({
    required this.cita,
    this.pasada = false,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: HuellitasTheme.cardBox(
        color: pasada ? HuellitasTheme.arena : HuellitasTheme.leche,
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      child: Row(
        children: [
          // Dot de color
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 14, top: 4),
            decoration: BoxDecoration(
              color: pasada ? HuellitasTheme.inkSoft : HuellitasTheme.lavanda,
              shape: BoxShape.circle,
            ),
          ),
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
                Text(
                  cita.mascota,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HuellitasTheme.inkSoft,
                  ),
                ),
                if (cita.veterinarioNombre != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.medical_services_outlined,
                        size: 11, color: HuellitasTheme.inkSoft),
                    const SizedBox(width: 4),
                    Text(
                      cita.veterinarioNombre!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: HuellitasTheme.inkSoft,
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: HuellitasTheme.coral,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                title: const Text('Eliminar cita'),
                content: Text(
                    '¿Eliminar "${cita.servicio}" del ${cita.fechaFormateada}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onEliminar();
                    },
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: HuellitasTheme.coral),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── FORMULARIO (bottom sheet) ─────────────────────────────────────────────────

class _CitaSheet extends StatefulWidget {
  final List<MascotaModel> mascotas;
  final void Function(CitaModel) onGuardar;
  const _CitaSheet({required this.mascotas, required this.onGuardar});

  @override
  State<_CitaSheet> createState() => _CitaSheetState();
}

class _CitaSheetState extends State<_CitaSheet> {
  static const _horas = [
    '08:00', '09:00', '10:00', '10:30',
    '12:00', '14:00', '15:00', '16:30',
  ];

  // Servicios dinámicos desde Firestore; lista de respaldo por si no hay datos.
  static const _serviciosFallback = [
    'Control de rutina', 'Vacunación', 'Consulta general',
    'Peluquería', 'Urgencias',
  ];

  List<String> _servicios = _serviciosFallback;
  String? _servicio;
  DateTime? _fecha;
  String _hora = '09:00';
  String? _mascotaSeleccionada;

  List<UsuarioModel> _vets = [];
  bool _cargandoVets = true;
  String? _vetId;
  String? _vetNombre;

  @override
  void initState() {
    super.initState();
    if (widget.mascotas.isNotEmpty) {
      _mascotaSeleccionada = widget.mascotas.first.nombre;
    }
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final results = await Future.wait([
        UsuarioRepository.veterinariosOnce(),
        ServicioRepository.streamActivos()
            .first
            .timeout(const Duration(seconds: 6), onTimeout: () => []),
      ]);
      final vets = results[0] as List<UsuarioModel>;
      final svcs = results[1] as List<ServicioModel>;
      if (mounted) {
        setState(() {
          _vets = vets;
          _cargandoVets = false;
          if (svcs.isNotEmpty) {
            _servicios = svcs.map((s) => s.nombre).toList();
            _servicio = _servicios.first;
          } else {
            _servicio = _serviciosFallback.first;
          }
        });
      }
    } catch (_) {
      // Si falla Firestore, usamos la lista de respaldo para que el formulario cargue.
      if (mounted) {
        setState(() {
          _cargandoVets = false;
          _servicio = _serviciosFallback.first;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final hoy = DateTime.now();
    final dt = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 2),
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
    if (dt != null) setState(() => _fecha = dt);
  }

  void _guardar() {
    if (_fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona una fecha',
              style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: HuellitasTheme.coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }
    widget.onGuardar(CitaModel(
      mascota: _mascotaSeleccionada ?? '',
      servicio: _servicio ?? '',
      fecha: _fecha!.toIso8601String().substring(0, 10),
      hora: _hora,
      veterinarioId: _vetId,
      veterinarioNombre: _vetNombre,
    ));
    Navigator.pop(context);
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: HuellitasTheme.cardBox(radius: 36),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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

          // Mascota
          DropdownButtonFormField<String>(
            initialValue: _mascotaSeleccionada,
            decoration: HuellitasTheme.field('Mascota'),
            items: widget.mascotas
                .map((m) => DropdownMenuItem(value: m.nombre, child: Text(m.nombre)))
                .toList(),
            onChanged: (v) => setState(() => _mascotaSeleccionada = v),
          ),
          const SizedBox(height: 12),

          // Servicio
          DropdownButtonFormField<String>(
            initialValue: _servicio,
            decoration: HuellitasTheme.field('Servicio'),
            items: _servicios
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _servicio = v!),
          ),
          const SizedBox(height: 12),

          // Fecha
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: HuellitasTheme.arena,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: HuellitasTheme.inkSoft),
                const SizedBox(width: 10),
                Text(
                  _fecha == null ? 'Seleccionar fecha' : _fmtDate(_fecha!),
                  style: TextStyle(
                    fontSize: 16,
                    color: _fecha == null
                        ? HuellitasTheme.inkSoft.withAlpha(153)
                        : HuellitasTheme.ink,
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Hora
          DropdownButtonFormField<String>(
            initialValue: _hora,
            decoration: HuellitasTheme.field('Hora'),
            items: _horas
                .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                .toList(),
            onChanged: (v) => setState(() => _hora = v!),
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
              key: ValueKey(_vetId),
              initialValue: _vetId,
              decoration: HuellitasTheme.field('Veterinario'),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('Sin preferencia')),
                ..._vets.map((v) => DropdownMenuItem(
                      value: v.uid,
                      child: Text('${v.nombre} ${v.apellido}'),
                    )),
              ],
              onChanged: (id) {
                setState(() {
                  _vetId = id;
                  if (id == null) {
                    _vetNombre = null;
                  } else {
                    final vet = _vets.firstWhere((v) => v.uid == id);
                    _vetNombre = '${vet.nombre} ${vet.apellido}';
                  }
                });
              },
            ),
          const SizedBox(height: 24),

          ClayButton(
            child: ElevatedButton(
              onPressed: _guardar,
              child: const Text('Reservar cita'),
            ),
          ),
        ],
      ),
    );
  }
}
