import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';

class FormularioRegistroPage extends StatefulWidget {
  const FormularioRegistroPage({super.key});

  @override
  State<FormularioRegistroPage> createState() => _FormularioRegistroPageState();
}

class _FormularioRegistroPageState extends State<FormularioRegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuario = UsuarioModel();
  final _mascota = MascotaModel();

  final _contrasena1Ctrl = TextEditingController();
  bool _tieneMascota = false;

  @override
  void dispose() {
    _contrasena1Ctrl.dispose();
    super.dispose();
  }

  void _registrar() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _usuario.tieneMascota = _tieneMascota;
      if (_tieneMascota) _usuario.mascota = _mascota;

      // TODO: enviar _usuario.toJson() a la API o base de datos
      debugPrint('Datos: ${_usuario.toJson()}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Registro exitoso',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: HuellitasTheme.menta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: HuellitasTheme.theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Crear cuenta')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [

              // ── SECCIÓN: DOCUMENTO ─────────────────────────────────────
              const _SectionLabel('Documento de identidad'),
              const SizedBox(height: 12),

              // TIPO DE DOCUMENTO
              DropdownButtonFormField<String>(
                initialValue: _usuario.tipoDocumento,
                decoration: HuellitasTheme.field('Tipo de documento'),
                items: [
                  'Cédula de ciudadanía',
                  'Cédula de extranjería',
                  'Tarjeta de identidad',
                  'Pasaporte',
                ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _usuario.tipoDocumento = v!),
                onSaved: (v) => _usuario.tipoDocumento = v!,
              ),
              const SizedBox(height: 12),

              // NÚMERO DE DOCUMENTO
              TextFormField(
                decoration: HuellitasTheme.field('Número de documento'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu número de documento' : null,
                onSaved: (v) => _usuario.numeroDocumento = v!,
              ),
              const SizedBox(height: 24),

              // ── SECCIÓN: DATOS PERSONALES ──────────────────────────────
              const _SectionLabel('Datos personales'),
              const SizedBox(height: 12),

              // NOMBRE
              TextFormField(
                decoration: HuellitasTheme.field('Nombre'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                onSaved: (v) => _usuario.nombre = v!.trim(),
              ),
              const SizedBox(height: 12),

              // APELLIDO
              TextFormField(
                decoration: HuellitasTheme.field('Apellido'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu apellido' : null,
                onSaved: (v) => _usuario.apellido = v!.trim(),
              ),
              const SizedBox(height: 12),

              // CORREO
              TextFormField(
                decoration: HuellitasTheme.field('Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                  if (!v.contains('@') || !v.contains('.')) return 'Correo no válido';
                  return null;
                },
                onSaved: (v) => _usuario.correo = v!.trim(),
              ),
              const SizedBox(height: 24),

              // ── SECCIÓN: CONTRASEÑA ────────────────────────────────────
              const _SectionLabel('Contraseña'),
              const SizedBox(height: 12),

              // CONTRASEÑA
              TextFormField(
                controller: _contrasena1Ctrl,
                decoration: HuellitasTheme.field('Contraseña'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
                onSaved: (v) => _usuario.contrasena = v!,
              ),
              const SizedBox(height: 12),

              // CONFIRMAR CONTRASEÑA
              TextFormField(
                decoration: HuellitasTheme.field('Confirmar contraseña'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v != _contrasena1Ctrl.text) ? 'Las contraseñas no coinciden' : null,
              ),
              const SizedBox(height: 24),

              // ── SECCIÓN: MASCOTA ───────────────────────────────────────
              Container(
                decoration: HuellitasTheme.cardBox(color: HuellitasTheme.leche, radius: 28),
                child: SwitchListTile(
                  title: const Text(
                    '¿Tienes mascota?',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  value: _tieneMascota,
                  activeThumbColor: HuellitasTheme.ink,
                  onChanged: (val) => setState(() => _tieneMascota = val),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                ),
              ),

              // DATOS DE LA MASCOTA (visible solo si tiene mascota)
              if (_tieneMascota) ...[
                const SizedBox(height: 20),
                const _SectionLabel('Datos de la mascota'),
                const SizedBox(height: 12),

                TextFormField(
                  decoration: HuellitasTheme.field('Nombre de la mascota'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
                  onSaved: (v) => _mascota.nombre = v!.trim(),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _mascota.tipo,
                  decoration: HuellitasTheme.field('Tipo'),
                  items: ['Perro', 'Gato', 'Otro']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _mascota.tipo = v!),
                  onSaved: (v) => _mascota.tipo = v ?? 'Perro',
                ),
                const SizedBox(height: 12),

                TextFormField(
                  decoration: HuellitasTheme.field('Edad (años)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa la edad' : null,
                  onSaved: (v) => _mascota.edad = int.tryParse(v ?? '') ?? 0,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  decoration: HuellitasTheme.field('Peso en kg', hint: 'Opcional'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (v) => _mascota.peso = double.tryParse(v ?? ''),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  decoration: HuellitasTheme.field('Raza'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa la raza o cruce' : null,
                  onSaved: (v) => _mascota.raza = v!.trim(),
                ),
              ],

              const SizedBox(height: 32),

              // ── BOTÓN REGISTRARSE ──────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: HuellitasTheme.claySm,
                ),
                child: ElevatedButton(
                  onPressed: _registrar,
                  child: const Text('Registrarse'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Etiqueta de sección con estilo micro (uppercase, inkSoft)
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: HuellitasTheme.inkSoft,
      ),
    );
  }
}
