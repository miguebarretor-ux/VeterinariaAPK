import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'login.dart';
import 'admin_usuarios.dart';
import 'services/auth_service.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

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
            const Text(
              'Huellitas',
              style: TextStyle(
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
      body: const AdminUsuariosPage(),
    );
  }
}

/// Hoja de vacuna reutilizable por el panel de admin.
class AdminVacunaSheet extends StatefulWidget {
  final void Function(VacunaModel) onGuardar;
  const AdminVacunaSheet({super.key, required this.onGuardar});

  @override
  State<AdminVacunaSheet> createState() => _AdminVacunaSheetState();
}

class _AdminVacunaSheetState extends State<AdminVacunaSheet> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  DateTime? _fechaAplicacion;
  DateTime? _fechaVencimiento;

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
      nombre: _nombre,
      fechaAplicacion: _fechaAplicacion!.toIso8601String().substring(0, 10),
      fechaVencimiento: _fechaVencimiento?.toIso8601String().substring(0, 10),
    ));
    Navigator.pop(context);
  }

  String _fmt(DateTime dt) {
    const m = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  Widget _dateRow({required String label, required DateTime? value,
      required VoidCallback onTap, bool optional = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
            color: HuellitasTheme.arena, borderRadius: BorderRadius.circular(22)),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined,
              size: 18, color: HuellitasTheme.inkSoft),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value != null
                  ? '$label: ${_fmt(value)}'
                  : optional ? '$label (opcional)' : label,
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
              child: const Icon(Icons.close, size: 18, color: HuellitasTheme.inkSoft),
            ),
        ]),
      ),
    );
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
                    color: HuellitasTheme.lima,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 18),
            Text('Agregar vacuna / tratamiento',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            TextFormField(
              decoration: HuellitasTheme.field('Nombre de la vacuna o tratamiento'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
              onSaved: (v) => _nombre = v!.trim(),
            ),
            const SizedBox(height: 12),
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
                final dt = await _pickDate(first: _fechaAplicacion ?? DateTime.now());
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
