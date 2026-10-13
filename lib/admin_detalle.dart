import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'admin_shell.dart';
import 'repositories/usuario_repository.dart';
import 'repositories/cita_repository.dart';

class AdminDetallePage extends StatefulWidget {
  final UsuarioModel usuario;
  const AdminDetallePage({super.key, required this.usuario});

  @override
  State<AdminDetallePage> createState() => _AdminDetallePageState();
}

class _AdminDetallePageState extends State<AdminDetallePage> {
  late UsuarioModel _usuario;
  List<CitaModel> _citas = [];
  StreamSubscription<UsuarioModel?>? _usuarioSub;
  StreamSubscription<List<CitaModel>>? _citasSub;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
    final uid = widget.usuario.uid!;

    _usuarioSub = UsuarioRepository.stream(uid).listen((u) {
      if (mounted && u != null) setState(() => _usuario = u);
    });

    _citasSub = CitaRepository.stream(uid).listen((lista) {
      if (mounted) setState(() => _citas = lista);
    });
  }

  @override
  void dispose() {
    _usuarioSub?.cancel();
    _citasSub?.cancel();
    super.dispose();
  }

  void _agregarVacuna(MascotaModel mascota) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AdminVacunaSheet(
          onGuardar: (v) {
            UsuarioRepository.agregarVacuna(_usuario.uid!, mascota.id, v);
          },
        ),
      ),
    );
  }

  void _eliminarVacuna(MascotaModel mascota, int index) {
    UsuarioRepository.eliminarVacuna(_usuario.uid!, mascota.id, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      appBar: AppBar(
        title: Text('${_usuario.nombre} ${_usuario.apellido}'),
        backgroundColor: HuellitasTheme.arena,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // ── DATOS DEL USUARIO ──────────────────────────────────
          const SectionLabel('Datos del usuario'),
          const SizedBox(height: 12),
          _DatosUsuarioCard(usuario: _usuario),
          const SizedBox(height: 28),

          // ── MASCOTAS ───────────────────────────────────────────
          const SectionLabel('Mascotas'),
          const SizedBox(height: 12),
          if (_usuario.mascotas.isEmpty)
            Container(
              decoration: HuellitasTheme.cardBox(),
              padding: const EdgeInsets.all(20),
              child: Text(
                'Sin mascotas registradas',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: HuellitasTheme.inkSoft),
              ),
            )
          else
            ..._usuario.mascotas.map(
              (m) => _MascotaSection(
                mascota: m,
                citas: _citas.where((c) => c.mascota == m.nombre).toList(),
                onAgregarVacuna: () => _agregarVacuna(m),
                onEliminarVacuna: (i) => _eliminarVacuna(m, i),
              ),
            ),
        ],
      ),
    );
  }
}

// ── DATOS USUARIO ─────────────────────────────────────────────────────────────

class _DatosUsuarioCard extends StatelessWidget {
  final UsuarioModel usuario;
  const _DatosUsuarioCard({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HuellitasTheme.cardBox(),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          _Row(Icons.person_outline, '${usuario.nombre} ${usuario.apellido}'),
          const SizedBox(height: 8),
          _Row(Icons.mail_outline, usuario.correo),
          const SizedBox(height: 8),
          _Row(Icons.badge_outlined,
              '${usuario.tipoDocumento} · ${usuario.numeroDocumento}'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Row(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: HuellitasTheme.inkSoft),
      const SizedBox(width: 10),
      Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
    ]);
  }
}

// ── SECCIÓN POR MASCOTA ───────────────────────────────────────────────────────

class _MascotaSection extends StatelessWidget {
  final MascotaModel mascota;
  final List<CitaModel> citas;
  final VoidCallback onAgregarVacuna;
  final void Function(int) onEliminarVacuna;

  const _MascotaSection({
    required this.mascota,
    required this.citas,
    required this.onAgregarVacuna,
    required this.onEliminarVacuna,
  });

  @override
  Widget build(BuildContext context) {
    final vacunas = mascota.vacunas;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: HuellitasTheme.cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera mascota
          Container(
            decoration: const BoxDecoration(
              color: HuellitasTheme.lavanda,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(44),
                topRight: Radius.circular(44),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: HuellitasTheme.leche,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: HuellitasTheme.claySm,
                ),
                child: const Icon(Icons.pets, size: 22, color: HuellitasTheme.ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mascota.nombre,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${mascota.tipo} · ${mascota.raza} · ${mascota.edad} año${mascota.edad == 1 ? '' : 's'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: HuellitasTheme.inkSoft),
                    ),
                  ],
                ),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── CITAS ──────────────────────────────────────
                const SectionLabel('Citas'),
                const SizedBox(height: 10),
                if (citas.isEmpty)
                  Text('Sin citas registradas',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: HuellitasTheme.inkSoft))
                else
                  ...citas.map((c) => _CitaRow(cita: c)),

                const SizedBox(height: 20),

                // ── CARNET ─────────────────────────────────────
                Row(children: [
                  const Expanded(child: SectionLabel('Carnet de vacunas')),
                  GestureDetector(
                    onTap: onAgregarVacuna,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: HuellitasTheme.lima,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: HuellitasTheme.claySm,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 14, color: HuellitasTheme.ink),
                          SizedBox(width: 4),
                          Text('Agregar',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: HuellitasTheme.ink)),
                        ],
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                if (vacunas.isEmpty)
                  Text('Sin vacunas registradas',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: HuellitasTheme.inkSoft))
                else
                  ...List.generate(
                    vacunas.length,
                    (i) => _VacunaRow(
                      vacuna: vacunas[i],
                      onEliminar: () => onEliminarVacuna(i),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── FILA CITA ─────────────────────────────────────────────────────────────────

class _CitaRow extends StatelessWidget {
  final CitaModel cita;
  const _CitaRow({required this.cita});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cita.esProxima ? HuellitasTheme.leche : HuellitasTheme.arena,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: cita.esProxima ? HuellitasTheme.lavanda : HuellitasTheme.inkSoft,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cita.servicio,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: HuellitasTheme.ink)),
              Text('${cita.fechaFormateada} · ${cita.hora}',
                  style: const TextStyle(
                      fontSize: 12, color: HuellitasTheme.inkSoft)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── FILA VACUNA ───────────────────────────────────────────────────────────────

class _VacunaRow extends StatelessWidget {
  final VacunaModel vacuna;
  final VoidCallback onEliminar;
  const _VacunaRow({required this.vacuna, required this.onEliminar});

  Color get _chipColor {
    switch (vacuna.estado) {
      case 'vencida':    return HuellitasTheme.coral;
      case 'por_vencer': return const Color(0xFFF9CF87);
      default:           return HuellitasTheme.menta;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: HuellitasTheme.leche,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vacuna.nombre,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: HuellitasTheme.ink)),
              const SizedBox(height: 4),
              Text('Aplicada: ${vacuna.fechaAplicacionFmt}',
                  style: const TextStyle(
                      fontSize: 12, color: HuellitasTheme.inkSoft)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _chipColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(vacuna.estadoLabel,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: HuellitasTheme.ink)),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          color: HuellitasTheme.coral,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              title: const Text('Eliminar vacuna'),
              content: Text('¿Eliminar "${vacuna.nombre}"?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                TextButton(
                  onPressed: () { Navigator.pop(context); onEliminar(); },
                  child: const Text('Eliminar',
                      style: TextStyle(color: HuellitasTheme.coral)),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
