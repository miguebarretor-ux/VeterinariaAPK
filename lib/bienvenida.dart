import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'login.dart';
import 'widgets.dart';
import 'repositories/usuario_repository.dart';
import 'services/auth_service.dart';

class BienvenidaPage extends StatefulWidget {
  final UsuarioModel usuario;
  const BienvenidaPage({super.key, required this.usuario});

  @override
  State<BienvenidaPage> createState() => _BienvenidaPageState();
}

class _BienvenidaPageState extends State<BienvenidaPage> {
  late UsuarioModel _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
  }

  void _mostrarFormMascota({MascotaModel? editar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _MascotaSheet(
          mascotaInicial: editar,
          onGuardar: (MascotaModel m) {
            setState(() {
              if (editar != null) {
                final idx =
                    _usuario.mascotas.indexWhere((x) => x.id == editar.id);
                if (idx >= 0) _usuario.mascotas[idx] = m;
              } else {
                _usuario.mascotas.add(m);
              }
            });
            UsuarioRepository.actualizar(_usuario.uid!, _usuario);
          },
        ),
      ),
    );
  }

  void _eliminarMascota(MascotaModel m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Eliminar mascota'),
        content: Text('¿Eliminar a ${m.nombre} del perfil?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() =>
                  _usuario.mascotas.removeWhere((x) => x.id == m.id));
              UsuarioRepository.actualizar(_usuario.uid!, _usuario);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: HuellitasTheme.coral)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: HuellitasTheme.arena,
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [

          // ── SALUDO ────────────────────────────────────────────────────
          Text(
            '¡Hola, ${_usuario.nombre}!',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Bienvenido/a a Huellitas',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: HuellitasTheme.inkSoft),
          ),
          const SizedBox(height: 28),

          // ── TARJETA: DATOS DEL USUARIO ────────────────────────────────
          Container(
            decoration: HuellitasTheme.cardBox(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Tu cuenta'),
                const SizedBox(height: 14),
                _InfoRow(
                    icono: Icons.person_outline,
                    texto: '${_usuario.nombre} ${_usuario.apellido}'),
                const SizedBox(height: 8),
                _InfoRow(icono: Icons.mail_outline, texto: _usuario.correo),
                const SizedBox(height: 8),
                _InfoRow(
                    icono: Icons.badge_outlined,
                    texto:
                        '${_usuario.tipoDocumento} · ${_usuario.numeroDocumento}'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── TARJETAS: MASCOTAS ────────────────────────────────────────
          Row(
            children: [
              const Expanded(child: SectionLabel('Mis mascotas')),
              Text(
                '${_usuario.mascotas.length} registrada${_usuario.mascotas.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HuellitasTheme.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lista de mascotas
          ..._usuario.mascotas.map(
            (m) => _MascotaCard(
              mascota: m,
              onEditar: () => _mostrarFormMascota(editar: m),
              onEliminar: () => _eliminarMascota(m),
            ),
          ),

          // Botón agregar mascota
          const SizedBox(height: 8),
          ClayButton(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Agregar mascota'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HuellitasTheme.lavanda,
                foregroundColor: HuellitasTheme.ink,
              ),
              onPressed: () => _mostrarFormMascota(),
            ),
          ),

          const SizedBox(height: 36),

          // ── BOTÓN CERRAR SESIÓN ───────────────────────────────────────
          ClayButton(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HuellitasTheme.arena,
                foregroundColor: HuellitasTheme.ink,
              ),
              onPressed: () async {
                await AuthService.cerrarSesion();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const IniciarSesionPage()),
                    (_) => false,
                  );
                }
              },
              child: const Text('Cerrar sesión'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── TARJETA MASCOTA ───────────────────────────────────────────────────────────

class _MascotaCard extends StatelessWidget {
  final MascotaModel mascota;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  const _MascotaCard({
    required this.mascota,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: HuellitasTheme.cardBox(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con botones
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: HuellitasTheme.lavanda,
                borderRadius: BorderRadius.circular(22),
                boxShadow: HuellitasTheme.claySm,
              ),
              child: const Icon(Icons.pets, size: 22, color: HuellitasTheme.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(mascota.nombre,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            // Editar
            GestureDetector(
              onTap: onEditar,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration:
                    HuellitasTheme.chipBox(color: HuellitasTheme.arena),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.edit_outlined,
                      size: 13, color: HuellitasTheme.inkSoft),
                  SizedBox(width: 4),
                  Text('Editar',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: HuellitasTheme.inkSoft)),
                ]),
              ),
            ),
            const SizedBox(width: 6),
            // Eliminar
            GestureDetector(
              onTap: onEliminar,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration:
                    HuellitasTheme.chipBox(color: HuellitasTheme.coral.withAlpha(40)),
                child: const Icon(Icons.delete_outline,
                    size: 15, color: HuellitasTheme.coral),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          // Detalles
          _InfoRow(icono: Icons.category_outlined, texto: mascota.tipo),
          const SizedBox(height: 6),
          _InfoRow(
              icono: Icons.cake_outlined,
              texto: '${mascota.edad} año${mascota.edad == 1 ? '' : 's'}'),
          if (mascota.peso != null) ...[
            const SizedBox(height: 6),
            _InfoRow(
                icono: Icons.monitor_weight_outlined,
                texto: '${mascota.peso} kg'),
          ],
          const SizedBox(height: 6),
          _InfoRow(icono: Icons.bookmark_border, texto: mascota.raza),
        ],
      ),
    );
  }
}

// ── BOTTOM SHEET: FORMULARIO DE MASCOTA ──────────────────────────────────────

class _MascotaSheet extends StatefulWidget {
  final MascotaModel? mascotaInicial;
  final void Function(MascotaModel) onGuardar;

  const _MascotaSheet({this.mascotaInicial, required this.onGuardar});

  @override
  State<_MascotaSheet> createState() => _MascotaSheetState();
}

class _MascotaSheetState extends State<_MascotaSheet> {
  final _formKey = GlobalKey<FormState>();
  late final MascotaModel _mascota;

  @override
  void initState() {
    super.initState();
    final ini = widget.mascotaInicial;
    // Preserve the original id when editing so CarnetRegistro keys stay valid
    _mascota = MascotaModel(
      id:     ini?.id,
      nombre: ini?.nombre ?? '',
      tipo:   ini?.tipo   ?? 'Perro',
      edad:   ini?.edad   ?? 0,
      peso:   ini?.peso,
      raza:   ini?.raza   ?? '',
    );
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onGuardar(_mascota);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.mascotaInicial != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: HuellitasTheme.cardBox(radius: 32),
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
                  color: HuellitasTheme.lavanda,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              esEdicion ? 'Editar mascota' : 'Agregar mascota',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            MascotaFormFields(mascota: _mascota),
            const SizedBox(height: 24),
            ClayButton(
              child: ElevatedButton(
                onPressed: _guardar,
                child: Text(esEdicion ? 'Guardar cambios' : 'Agregar mascota'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── COMPONENTES INTERNOS ──────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _InfoRow({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 18, color: HuellitasTheme.inkSoft),
        const SizedBox(width: 10),
        Expanded(
          child: Text(texto, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
