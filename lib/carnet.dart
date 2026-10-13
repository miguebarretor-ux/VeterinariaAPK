import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';

class CarnetPage extends StatefulWidget {
  final UsuarioModel usuario;
  const CarnetPage({super.key, required this.usuario});

  @override
  State<CarnetPage> createState() => _CarnetPageState();
}

class _CarnetPageState extends State<CarnetPage> {
  MascotaModel? _mascotaActual;
  List<VacunaModel> _vacunas = [];

  @override
  void initState() {
    super.initState();
    if (widget.usuario.mascotas.isNotEmpty) {
      _mascotaActual = widget.usuario.mascotas.first;
      _vacunas = _mascotaActual!.vacunas;
    }
  }

  @override
  void didUpdateWidget(covariant CarnetPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mascotaActual != null) {
      final updated = widget.usuario.mascotas.firstWhere(
        (m) => m.id == _mascotaActual!.id,
        orElse: () => _mascotaActual!,
      );
      setState(() {
        _mascotaActual = updated;
        _vacunas = updated.vacunas;
      });
    }
  }

  void _seleccionarMascota(MascotaModel m) {
    setState(() {
      _mascotaActual = m;
      _vacunas = m.vacunas;
    });
  }

  int get _alDia => _vacunas.where((v) => v.estado == 'al_dia').length;

  @override
  Widget build(BuildContext context) {
    final mascotas = widget.usuario.mascotas;

    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      appBar: AppBar(
        title: Text(
          _mascotaActual != null
              ? 'Carnet de ${_mascotaActual!.nombre}'
              : 'Carnet de vacunas',
        ),
        backgroundColor: HuellitasTheme.arena,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: mascotas.isEmpty
          ? _SinMascotas()
          : Column(
              children: [
                // Selector de mascota (solo si hay más de una)
                if (mascotas.length > 1)
                  _MascotaSelector(
                    mascotas: mascotas,
                    seleccionada: _mascotaActual,
                    onSeleccionar: _seleccionarMascota,
                  ),
                Expanded(
                  child: _vacunas.isEmpty
                      ? _EmptyState()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                          children: [
                            _ResumenCard(
                                total: _vacunas.length, alDia: _alDia),
                            const SizedBox(height: 20),
                            const SectionLabel('Vacunas y tratamientos'),
                            const SizedBox(height: 12),
                            ...List.generate(
                              _vacunas.length,
                              (i) => _VacunaCard(vacuna: _vacunas[i]),
                            ),
                            const SizedBox(height: 20),
                            _AdminNote(),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}

// ── SIN MASCOTAS ───────────────────────────────────────────────────────────────

class _SinMascotas extends StatelessWidget {
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
                Icons.pets,
                size: 36,
                color: HuellitasTheme.ink,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin mascotas registradas',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega una mascota desde tu perfil para ver el carnet',
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

// ── SELECTOR DE MASCOTA ────────────────────────────────────────────────────────

class _MascotaSelector extends StatelessWidget {
  final List<MascotaModel> mascotas;
  final MascotaModel? seleccionada;
  final void Function(MascotaModel) onSeleccionar;

  const _MascotaSelector({
    required this.mascotas,
    required this.seleccionada,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HuellitasTheme.arena,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: mascotas.map((m) {
            final activa = m.id == seleccionada?.id;
            return GestureDetector(
              onTap: () => onSeleccionar(m),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: activa
                      ? HuellitasTheme.lavanda
                      : HuellitasTheme.leche,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: HuellitasTheme.claySm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pets,
                        size: 14,
                        color: activa
                            ? HuellitasTheme.ink
                            : HuellitasTheme.inkSoft),
                    const SizedBox(width: 6),
                    Text(
                      m.nombre,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: activa
                            ? HuellitasTheme.ink
                            : HuellitasTheme.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: HuellitasTheme.lima,
                borderRadius: BorderRadius.circular(36),
                boxShadow: HuellitasTheme.claySm,
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 36,
                color: HuellitasTheme.ink,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Carnet vacío',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'El veterinario registrará las vacunas desde el panel admin',
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

// ── RESUMEN ───────────────────────────────────────────────────────────────────

class _ResumenCard extends StatelessWidget {
  final int total;
  final int alDia;
  const _ResumenCard({required this.total, required this.alDia});

  @override
  Widget build(BuildContext context) {
    final vencidas = total - alDia;
    final color =
        vencidas == 0 ? HuellitasTheme.menta : HuellitasTheme.coral;

    return Container(
      decoration: HuellitasTheme.cardBox(color: color),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado general',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                    color: HuellitasTheme.inkSoft,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$alDia de $total al día',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: HuellitasTheme.leche,
              borderRadius: BorderRadius.circular(26),
              boxShadow: HuellitasTheme.claySm,
            ),
            child: Icon(
              vencidas == 0
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_rounded,
              color: vencidas == 0
                  ? HuellitasTheme.menta
                  : HuellitasTheme.coral,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

// ── TARJETA VACUNA (solo lectura) ─────────────────────────────────────────────

class _VacunaCard extends StatelessWidget {
  final VacunaModel vacuna;
  const _VacunaCard({required this.vacuna});

  Color get _chipColor {
    switch (vacuna.estado) {
      case 'vencida':
        return HuellitasTheme.coral;
      case 'por_vencer':
        return const Color(0xFFF9CF87);
      default:
        return HuellitasTheme.menta;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: HuellitasTheme.cardBox(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vacuna.nombre,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Aplicada: ${vacuna.fechaAplicacionFmt}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: HuellitasTheme.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _chipColor,
              borderRadius: BorderRadius.circular(999),
              boxShadow: HuellitasTheme.claySm,
            ),
            child: Text(
              vacuna.estadoLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: HuellitasTheme.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── NOTA ADMIN ────────────────────────────────────────────────────────────────

class _AdminNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: HuellitasTheme.lavanda.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              size: 16, color: HuellitasTheme.inkSoft),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Solo el veterinario puede agregar o editar el carnet.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: HuellitasTheme.inkSoft, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
