import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'repositories/cita_repository.dart';
import 'repositories/usuario_repository.dart';

/// Agenda del administrador: todas las citas próximas, con las que aún no
/// tienen veterinario primero para asignarlas.
class AdminCitasPage extends StatefulWidget {
  const AdminCitasPage({super.key});

  @override
  State<AdminCitasPage> createState() => _AdminCitasPageState();
}

class _AdminCitasPageState extends State<AdminCitasPage> {
  List<CitaModel> _citas = [];
  final Map<String, UsuarioModel> _duenos = {};
  bool _cargando = true;
  String? _error;
  StreamSubscription<List<CitaModel>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = CitaRepository.streamTodas().listen(
      (citas) {
        if (!mounted) return;
        setState(() {
          _citas = citas;
          _cargando = false;
          _error = null;
        });
        _cargarDuenos();
      },
      onError: (Object e) {
        if (mounted) {
          setState(() {
            _cargando = false;
            _error = mensajeDeError(e);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Lee una sola vez el perfil de cada dueño para mostrar su nombre.
  Future<void> _cargarDuenos() async {
    final faltan = _citas
        .map((c) => c.duenoUid)
        .whereType<String>()
        .where((uid) => !_duenos.containsKey(uid))
        .toSet();
    if (faltan.isEmpty) return;
    await Future.wait(faltan.map((uid) async {
      try {
        final u = await UsuarioRepository.obtener(uid);
        if (u != null) _duenos[uid] = u;
      } catch (_) {}
    }));
    if (mounted) setState(() {});
  }

  Future<void> _asignar(CitaModel c) async {
    final vet = await showModalBottomSheet<UsuarioModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ElegirVetSheet(cita: c),
    );
    if (vet == null) return;
    try {
      await CitaRepository.asignar(c, vet);
      if (mounted) {
        mostrarAviso(context, 'Cita asignada a ${vet.nombreCompleto}.');
      }
    } catch (e) {
      if (mounted) mostrarAviso(context, mensajeDeError(e), error: true);
    }
  }

  Future<void> _cancelar(CitaModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Cancelar cita'),
        content: Text(
            '¿Cancelar "${c.servicio}" de ${c.mascota} el ${c.fechaFormateada} a las ${c.hora}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Volver')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar cita',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await CitaRepository.cancelar(c);
      if (mounted) mostrarAviso(context, 'Cita cancelada.');
    } catch (e) {
      if (mounted) mostrarAviso(context, mensajeDeError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(
          child: CircularProgressIndicator(color: HuellitasTheme.lavanda));
    }
    if (_error != null) {
      return EstadoVacio(
        icono: Icons.cloud_off_rounded,
        color: HuellitasTheme.coral,
        titulo: 'No pudimos cargar las citas',
        detalle: _error!,
      );
    }

    final proximas = _citas.where((c) => c.esProxima).toList()
      ..sort((a, b) => a.claveOrden.compareTo(b.claveOrden));
    final sinVet = proximas.where((c) => c.sinAsignar).toList();
    final conVet = proximas.where((c) => !c.sinAsignar).toList();

    if (proximas.isEmpty) {
      return const EstadoVacio(
        icono: Icons.event_available_rounded,
        titulo: 'Sin citas próximas',
        detalle: 'Cuando un cliente agende una cita, aparecerá aquí.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Container(
          decoration: HuellitasTheme.cardBox(
              color:
                  sinVet.isEmpty ? HuellitasTheme.menta : HuellitasTheme.lima),
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Icon(
              sinVet.isEmpty
                  ? Icons.task_alt_rounded
                  : Icons.assignment_ind_outlined,
              color: HuellitasTheme.ink,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                sinVet.isEmpty
                    ? 'Todas las citas próximas tienen veterinario.'
                    : sinVet.length == 1
                        ? '1 cita espera que le asignes veterinario.'
                        : '${sinVet.length} citas esperan que les asignes veterinario.',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ]),
        ),
        if (sinVet.isNotEmpty) ...[
          const SizedBox(height: 24),
          const SectionLabel('Sin veterinario'),
          const SizedBox(height: 12),
          ...sinVet.map(_tarjeta),
        ],
        if (conVet.isNotEmpty) ...[
          const SizedBox(height: 24),
          const SectionLabel('Asignadas'),
          const SizedBox(height: 12),
          ...conVet.map(_tarjeta),
        ],
      ],
    );
  }

  Widget _tarjeta(CitaModel c) {
    final dueno = _duenos[c.duenoUid];
    final suave = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: HuellitasTheme.inkSoft, fontSize: 13);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: HuellitasTheme.cardBox(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.servicio, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text('${c.fechaFormateada}  ·  ${c.hora}', style: suave),
          const SizedBox(height: 2),
          Text(
            dueno == null
                ? c.mascota
                : '${c.mascota} · ${dueno.nombreCompleto}',
            style: suave,
          ),
          const SizedBox(height: 8),
          EstadoChip(
            c.sinAsignar
                ? 'Sin veterinario'
                : c.veterinarioNombre ?? 'Asignada',
            color: c.sinAsignar ? HuellitasTheme.lima : HuellitasTheme.menta,
            icono: Icons.medical_services_outlined,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(
                onPressed: () => _asignar(c),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      c.sinAsignar ? HuellitasTheme.lima : HuellitasTheme.arena,
                  foregroundColor: HuellitasTheme.ink,
                ),
                child: Text(c.sinAsignar ? 'Asignar veterinario' : 'Cambiar'),
              ),
              TextButton(
                onPressed: () => _cancelar(c),
                child: const Text('Cancelar cita'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Lista de veterinarios activos para una cita, indicando quién tiene ese
/// horario ocupado.
class _ElegirVetSheet extends StatefulWidget {
  final CitaModel cita;
  const _ElegirVetSheet({required this.cita});

  @override
  State<_ElegirVetSheet> createState() => _ElegirVetSheetState();
}

class _ElegirVetSheetState extends State<_ElegirVetSheet> {
  List<UsuarioModel> _vets = [];
  final Set<String> _ocupados = {};
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final vets = await UsuarioRepository.veterinariosOnce();
      await Future.wait(vets.map((v) async {
        final horas =
            await CitaRepository.horasOcupadas(v.uid!, widget.cita.fecha);
        if (horas.contains(widget.cita.hora)) _ocupados.add(v.uid!);
      }));
      if (mounted) {
        setState(() {
          _vets = vets;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargando = false;
          _error = mensajeDeError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cita;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: HuellitasTheme.cardBox(radius: 36),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Asignar veterinario',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${c.servicio} · ${c.fechaFormateada} a las ${c.hora}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: HuellitasTheme.inkSoft),
            ),
            const SizedBox(height: 16),
            if (_cargando)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: HuellitasTheme.lavanda)),
              )
            else if (_error != null)
              AvisoEnLinea(_error!)
            else if (_vets.isEmpty)
              const AvisoEnLinea(
                  'No hay veterinarios activos. Registra o activa uno en la pestaña Veterinarios.')
            else
              for (final v in _vets)
                // Material propio: el fondo de la hoja taparía el efecto al tocar.
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled:
                        !_ocupados.contains(v.uid) || v.uid == c.veterinarioId,
                    leading: CircleAvatar(
                      backgroundColor: HuellitasTheme.menta,
                      child: Text(
                        v.nombre.isNotEmpty ? v.nombre[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: HuellitasTheme.ink,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    title: Text(v.nombreCompleto,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      v.uid == c.veterinarioId
                          ? 'Asignado actualmente'
                          : _ocupados.contains(v.uid)
                              ? 'Ocupado a esa hora'
                              : v.especialidad.isEmpty
                                  ? 'Disponible'
                                  : '${v.especialidad} · Disponible',
                    ),
                    trailing: v.uid == c.veterinarioId
                        ? const Icon(Icons.check_rounded,
                            color: HuellitasTheme.ink)
                        : null,
                    onTap: () => Navigator.pop(context, v),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
