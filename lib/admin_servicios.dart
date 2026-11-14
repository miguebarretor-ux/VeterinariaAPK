import 'dart:async';
import 'package:flutter/material.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'repositories/servicio_repository.dart';

class AdminServiciosPage extends StatefulWidget {
  const AdminServiciosPage({super.key});

  @override
  State<AdminServiciosPage> createState() => _AdminServiciosPageState();
}

class _AdminServiciosPageState extends State<AdminServiciosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<ServicioModel> _servicios = [];
  List<VacunaCatalogoModel> _vacunas = [];
  bool _cargando = true;
  StreamSubscription<List<ServicioModel>>? _subS;
  StreamSubscription<List<VacunaCatalogoModel>>? _subV;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _subS = ServicioRepository.stream().listen(
      (lista) {
        if (mounted) setState(() { _servicios = lista; _cargando = false; });
      },
      onError: (_) {
        if (mounted) setState(() => _cargando = false);
      },
    );
    _subV = ServicioRepository.streamVacunas().listen(
      (lista) {
        if (mounted) setState(() => _vacunas = lista);
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _subS?.cancel();
    _subV?.cancel();
    super.dispose();
  }

  void _sembrar() async {
    await ServicioRepository.sembrarDatosIniciales();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Catálogo inicial cargado.',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: HuellitasTheme.lima,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ));
    }
  }

  void _nuevoServicio() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _ServicioSheet(
            onGuardar: (s) => ServicioRepository.agregar(s),
          ),
        ),
      );

  void _editarServicio(ServicioModel s) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _ServicioSheet(
            servicio: s,
            onGuardar: (updated) => ServicioRepository.actualizar(updated),
          ),
        ),
      );

  void _nuevaVacuna() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _VacunaCatalogoSheet(
            onGuardar: (v) => ServicioRepository.agregarVacuna(v),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      body: Column(
        children: [
          // Tab bar
          Container(
            color: HuellitasTheme.leche,
            child: TabBar(
              controller: _tabs,
              labelColor: HuellitasTheme.ink,
              unselectedLabelColor: HuellitasTheme.inkSoft,
              indicatorColor: HuellitasTheme.lima,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'Servicios'),
                Tab(text: 'Vacunas'),
              ],
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(
                        color: HuellitasTheme.lima))
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _TabServicios(
                        servicios: _servicios,
                        onEditar: _editarServicio,
                        onToggle: (s, val) =>
                            ServicioRepository.toggleActivo(s.id!, val),
                        onEliminar: (s) =>
                            ServicioRepository.eliminar(s.id!),
                        onSembrar: _sembrar,
                      ),
                      _TabVacunas(
                        vacunas: _vacunas,
                        onEliminar: (v) =>
                            ServicioRepository.eliminarVacuna(v.id!),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabs,
        builder: (_, __) => FloatingActionButton.extended(
          onPressed: _tabs.index == 0 ? _nuevoServicio : _nuevaVacuna,
          backgroundColor: HuellitasTheme.ink,
          icon: const Icon(Icons.add, color: HuellitasTheme.leche),
          label: Text(
            _tabs.index == 0 ? 'Nuevo servicio' : 'Nueva vacuna',
            style: const TextStyle(
                color: HuellitasTheme.leche, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// ── TAB SERVICIOS ─────────────────────────────────────────────────────────────

class _TabServicios extends StatelessWidget {
  final List<ServicioModel> servicios;
  final void Function(ServicioModel) onEditar;
  final void Function(ServicioModel, bool) onToggle;
  final void Function(ServicioModel) onEliminar;
  final VoidCallback onSembrar;

  const _TabServicios({
    required this.servicios,
    required this.onEditar,
    required this.onToggle,
    required this.onEliminar,
    required this.onSembrar,
  });

  @override
  Widget build(BuildContext context) {
    if (servicios.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: HuellitasTheme.lima,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: HuellitasTheme.claySm,
                ),
                child: const Icon(Icons.build_circle_outlined,
                    size: 36, color: HuellitasTheme.ink),
              ),
              const SizedBox(height: 20),
              Text('Sin servicios',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ClayButton(
                child: ElevatedButton.icon(
                  onPressed: onSembrar,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Cargar catálogo inicial'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        const SectionLabel('Catálogo de servicios'),
        const SizedBox(height: 12),
        ...servicios.map((s) => _ServicioCard(
              servicio: s,
              onEditar: () => onEditar(s),
              onToggle: (val) => onToggle(s, val),
              onEliminar: () => onEliminar(s),
            )),
      ],
    );
  }
}

class _ServicioCard extends StatelessWidget {
  final ServicioModel servicio;
  final VoidCallback onEditar;
  final void Function(bool) onToggle;
  final VoidCallback onEliminar;

  const _ServicioCard({
    required this.servicio,
    required this.onEditar,
    required this.onToggle,
    required this.onEliminar,
  });

  String _formatPrecio(double p) {
    if (p == 0) return 'Sin precio';
    final s = p.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '\$${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: HuellitasTheme.cardBox(
        color: servicio.activo ? HuellitasTheme.leche : HuellitasTheme.arena,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(servicio.nombre,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: servicio.activo
                              ? HuellitasTheme.ink
                              : HuellitasTheme.inkSoft,
                        )),
                const SizedBox(height: 3),
                Text(
                  _formatPrecio(servicio.precio),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: servicio.activo
                        ? HuellitasTheme.lima
                        : HuellitasTheme.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: servicio.activo,
            onChanged: onToggle,
            activeThumbColor: HuellitasTheme.lima,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: HuellitasTheme.inkSoft,
            onPressed: onEditar,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: HuellitasTheme.coral,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                title: const Text('Eliminar servicio'),
                content:
                    Text('¿Eliminar "${servicio.nombre}"?'),
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
                    child: const Text('Eliminar',
                        style: TextStyle(color: HuellitasTheme.coral)),
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

// ── TAB VACUNAS ───────────────────────────────────────────────────────────────

class _TabVacunas extends StatelessWidget {
  final List<VacunaCatalogoModel> vacunas;
  final void Function(VacunaCatalogoModel) onEliminar;

  const _TabVacunas({required this.vacunas, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    if (vacunas.isEmpty) {
      return Center(
        child: Text('Sin vacunas en el catálogo',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: HuellitasTheme.inkSoft)),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        const SectionLabel('Catálogo de vacunas'),
        const SizedBox(height: 12),
        ...vacunas.map((v) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: HuellitasTheme.cardBox(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.vaccines_outlined,
                      size: 18, color: HuellitasTheme.inkSoft),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(v.nombre,
                        style: Theme.of(context).textTheme.labelLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: HuellitasTheme.coral,
                    onPressed: () => onEliminar(v),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ── SHEET SERVICIO ─────────────────────────────────────────────────────────────

class _ServicioSheet extends StatefulWidget {
  final ServicioModel? servicio;
  final void Function(ServicioModel) onGuardar;
  const _ServicioSheet({this.servicio, required this.onGuardar});

  @override
  State<_ServicioSheet> createState() => _ServicioSheetState();
}

class _ServicioSheetState extends State<_ServicioSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late String _descripcion;
  late double _precio;

  @override
  void initState() {
    super.initState();
    _nombre = widget.servicio?.nombre ?? '';
    _descripcion = widget.servicio?.descripcion ?? '';
    _precio = widget.servicio?.precio ?? 0;
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    widget.onGuardar(ServicioModel(
      id: widget.servicio?.id,
      nombre: _nombre,
      descripcion: _descripcion,
      precio: _precio,
      activo: widget.servicio?.activo ?? true,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.servicio != null;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: HuellitasTheme.leche,
        borderRadius: BorderRadius.circular(36),
        boxShadow: HuellitasTheme.clayXl,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: HuellitasTheme.lima,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 18),
            Text(esEdicion ? 'Editar servicio' : 'Nuevo servicio',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _nombre,
              decoration: HuellitasTheme.field('Nombre del servicio'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              onSaved: (v) => _nombre = v!.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _descripcion,
              decoration: HuellitasTheme.field('Descripción', hint: 'Opcional'),
              textCapitalization: TextCapitalization.sentences,
              onSaved: (v) => _descripcion = v?.trim() ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _precio > 0 ? _precio.toStringAsFixed(0) : '',
              decoration: HuellitasTheme.field('Precio (COP)', hint: 'Ej: 35000'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _precio = double.tryParse(v ?? '') ?? 0,
            ),
            const SizedBox(height: 24),
            ClayButton(
              child: ElevatedButton(
                onPressed: _guardar,
                child: Text(esEdicion ? 'Guardar cambios' : 'Crear servicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SHEET VACUNA CATÁLOGO ─────────────────────────────────────────────────────

class _VacunaCatalogoSheet extends StatefulWidget {
  final void Function(VacunaCatalogoModel) onGuardar;
  const _VacunaCatalogoSheet({required this.onGuardar});

  @override
  State<_VacunaCatalogoSheet> createState() => _VacunaCatalogoSheetState();
}

class _VacunaCatalogoSheetState extends State<_VacunaCatalogoSheet> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _descripcion = '';

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    widget.onGuardar(
        VacunaCatalogoModel(nombre: _nombre, descripcion: _descripcion));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: HuellitasTheme.leche,
        borderRadius: BorderRadius.circular(36),
        boxShadow: HuellitasTheme.clayXl,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: HuellitasTheme.menta,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 18),
            Text('Nueva vacuna al catálogo',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            TextFormField(
              decoration: HuellitasTheme.field('Nombre de la vacuna'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              onSaved: (v) => _nombre = v!.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration:
                  HuellitasTheme.field('Descripción breve', hint: 'Opcional'),
              textCapitalization: TextCapitalization.sentences,
              onSaved: (v) => _descripcion = v?.trim() ?? '',
            ),
            const SizedBox(height: 24),
            ClayButton(
              child: ElevatedButton(
                onPressed: _guardar,
                child: const Text('Agregar al catálogo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
