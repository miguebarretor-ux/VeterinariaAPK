import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'login.dart';
import 'admin_usuarios.dart';
import 'admin_veterinarios.dart';
import 'admin_servicios.dart';
import 'admin_tienda.dart';
import 'services/auth_service.dart';
import 'repositories/servicio_repository.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _tab = 0;

  static const _labels = ['Usuarios', 'Veterinarios', 'Servicios', 'Tienda'];

  void _cerrarSesion(BuildContext context) async {
    await AuthService.cerrarSesion();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const IniciarSesionPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      AdminUsuariosPage(),
      _AdminVetsPage(),
      _AdminServiciosPage(),
      _AdminTiendaPage(),
    ];

    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      appBar: AppBar(
        backgroundColor: HuellitasTheme.ink,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: HuellitasTheme.lavanda,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: HuellitasTheme.ink,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _labels[_tab],
              style: const TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.w800,
                color: HuellitasTheme.leche,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _cerrarSesion(context),
            icon: const Icon(Icons.logout_rounded, color: HuellitasTheme.coral, size: 18),
            label: const Text(
              'Salir',
              style: TextStyle(color: HuellitasTheme.coral, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: HuellitasTheme.leche,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -4),
              blurRadius: 18,
              color: HuellitasTheme.ink.withAlpha(18),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: HuellitasTheme.leche,
          selectedItemColor: HuellitasTheme.ink,
          unselectedItemColor: HuellitasTheme.inkSoft,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Usuarios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              label: 'Veterinarios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build_circle_outlined),
              label: 'Servicios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              label: 'Tienda',
            ),
          ],
        ),
      ),
    );
  }
}

// ── PLACEHOLDERS ──────────────────────────────────────────────────────────────
// Reemplazados en las Fases 2, 5 y 6 respectivamente.

class _AdminVetsPage extends StatelessWidget {
  const _AdminVetsPage();

  @override
  Widget build(BuildContext context) => const AdminVeterinariosPage();
}

class _AdminServiciosPage extends StatelessWidget {
  const _AdminServiciosPage();

  @override
  Widget build(BuildContext context) => const AdminServiciosPage();
}

class _AdminTiendaPage extends StatelessWidget {
  const _AdminTiendaPage();

  @override
  Widget build(BuildContext context) => const AdminTiendaPage();
}

// ── HOJA DE VACUNA ─────────────────────────────────────────────────────────────
/// Hoja de vacuna reutilizable por el panel de admin.
class AdminVacunaSheet extends StatefulWidget {
  final void Function(VacunaModel) onGuardar;
  const AdminVacunaSheet({super.key, required this.onGuardar});

  @override
  State<AdminVacunaSheet> createState() => _AdminVacunaSheetState();
}

class _AdminVacunaSheetState extends State<AdminVacunaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  DateTime? _fechaAplicacion;
  DateTime? _fechaVencimiento;
  List<String> _catalogo = [];
  bool _catalogoCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogo() async {
    try {
      final lista = await ServicioRepository.streamVacunas()
          .first
          .timeout(const Duration(seconds: 6), onTimeout: () => []);
      if (mounted) {
        setState(() {
          _catalogo = lista.map((v) => v.nombre).toList();
          _catalogoCargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _catalogoCargando = false);
    }
  }

  Future<DateTime?> _pickDate({DateTime? initial, DateTime? first}) =>
      showDatePicker(
        context: context,
        initialDate: initial ?? DateTime.now(),
        firstDate: first ?? DateTime(2000),
        lastDate: DateTime(DateTime.now().year + 5),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: HuellitasTheme.lima,
                  onPrimary: HuellitasTheme.ink,
                ),
          ),
          child: child!,
        ),
      );

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaAplicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Selecciona la fecha de aplicación',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: HuellitasTheme.coral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ));
      return;
    }
    _formKey.currentState!.save();
    widget.onGuardar(VacunaModel(
      nombre: _nombreCtrl.text.trim(),
      fechaAplicacion: _fechaAplicacion!.toIso8601String().substring(0, 10),
      fechaVencimiento: _fechaVencimiento?.toIso8601String().substring(0, 10),
    ));
    Navigator.pop(context);
  }

  String _fmt(DateTime dt) {
    const m = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  Widget _dateRow({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool optional = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
            color: HuellitasTheme.arena,
            borderRadius: BorderRadius.circular(22)),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined,
              size: 18, color: HuellitasTheme.inkSoft),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value != null
                  ? '$label: ${_fmt(value)}'
                  : optional
                      ? '$label (opcional)'
                      : label,
              style: TextStyle(
                fontSize: 16,
                color: value != null
                    ? HuellitasTheme.ink
                    : HuellitasTheme.inkSoft.withAlpha(153),
              ),
            ),
          ),
          if (value != null && optional)
            GestureDetector(
              onTap: () => setState(() => _fechaVencimiento = null),
              child: const Icon(Icons.close,
                  size: 18, color: HuellitasTheme.inkSoft),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombreActual = _nombreCtrl.text.trim();

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
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: HuellitasTheme.lima,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 18),
            Text('Agregar vacuna / tratamiento',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),

            // ── Catálogo de vacunas ──────────────────────────────────
            if (_catalogoCargando)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Center(
                  child: SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: HuellitasTheme.lima),
                  ),
                ),
              )
            else if (_catalogo.isNotEmpty) ...[
              const Text(
                'DESDE EL CATÁLOGO',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: HuellitasTheme.inkSoft),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _catalogo.map((nombre) {
                    final seleccionada = nombreActual == nombre;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _nombreCtrl.text = nombre);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: seleccionada
                              ? HuellitasTheme.lima
                              : HuellitasTheme.arena,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow:
                              seleccionada ? HuellitasTheme.claySm : null,
                        ),
                        child: Text(
                          nombre,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: seleccionada
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: HuellitasTheme.ink,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'O ESCRIBE EL NOMBRE',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: HuellitasTheme.inkSoft),
              ),
              const SizedBox(height: 8),
            ],

            // ── Campo de nombre (libre) ────────────────────────────
            TextFormField(
              controller: _nombreCtrl,
              decoration: HuellitasTheme.field(
                  'Nombre de la vacuna o tratamiento'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // ── Fechas ────────────────────────────────────────────
            _dateRow(
              label: 'Fecha de aplicación',
              value: _fechaAplicacion,
              onTap: () async {
                final dt = await _pickDate();
                if (dt != null) setState(() => _fechaAplicacion = dt);
              },
            ),
            const SizedBox(height: 12),
            _dateRow(
              label: 'Fecha de vencimiento',
              value: _fechaVencimiento,
              optional: true,
              onTap: () async {
                final dt =
                    await _pickDate(first: _fechaAplicacion ?? DateTime.now());
                if (dt != null) setState(() => _fechaVencimiento = dt);
              },
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: HuellitasTheme.claySm),
              child: ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar vacuna'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
