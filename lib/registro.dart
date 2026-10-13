import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'home_shell.dart';
import 'widgets.dart';
import 'repositories/usuario_repository.dart';
import 'services/auth_service.dart';

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
  bool _cargando = false;

  @override
  void dispose() {
    _contrasena1Ctrl.dispose();
    super.dispose();
  }

  void _mostrarError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: HuellitasTheme.coral,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    if (_tieneMascota) _usuario.mascotas = [_mascota];

    setState(() => _cargando = true);
    try {
      final credential = await AuthService.registrar(
        _usuario.correo,
        _usuario.contrasena,
      );
      final uid = credential.user!.uid;
      _usuario.uid = uid;

      await UsuarioRepository.crear(uid, _usuario);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeShell(usuario: _usuario)),
      );
    } on FirebaseAuthException catch (e) {
      _mostrarError(AuthService.mensajeError(e.code));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HuellitasTheme.lavanda,
      appBar: AppBar(
        backgroundColor: HuellitasTheme.lavanda,
        foregroundColor: HuellitasTheme.ink,
        elevation: 0,
        title: const Text('Crear cuenta'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                decoration: HuellitasTheme.cardBox(radius: 36),
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ── SECCIÓN: DOCUMENTO ─────────────────────────────────
                    const SectionLabel('Documento de identidad'),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: _usuario.tipoDocumento,
                      decoration: HuellitasTheme.field('Tipo de documento'),
                      items: [
                        'Cédula de ciudadanía',
                        'Cédula de extranjería',
                        'Tarjeta de identidad',
                        'Pasaporte',
                      ]
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _usuario.tipoDocumento = v!),
                      onSaved: (v) => _usuario.tipoDocumento = v!,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      decoration: HuellitasTheme.field('Número de documento'),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa tu número de documento'
                          : null,
                      onSaved: (v) => _usuario.numeroDocumento = v!,
                    ),
                    const SizedBox(height: 24),

                    // ── SECCIÓN: DATOS PERSONALES ──────────────────────────
                    const SectionLabel('Datos personales'),
                    const SizedBox(height: 12),

                    TextFormField(
                      decoration: HuellitasTheme.field('Nombre'),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                      onSaved: (v) => _usuario.nombre = v!.trim(),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      decoration: HuellitasTheme.field('Apellido'),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ingresa tu apellido' : null,
                      onSaved: (v) => _usuario.apellido = v!.trim(),
                    ),
                    const SizedBox(height: 12),

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

                    // ── SECCIÓN: CONTRASEÑA ────────────────────────────────
                    const SectionLabel('Contraseña'),
                    const SizedBox(height: 12),

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

                    TextFormField(
                      decoration: HuellitasTheme.field('Confirmar contraseña'),
                      obscureText: true,
                      validator: (v) => (v == null || v != _contrasena1Ctrl.text)
                          ? 'Las contraseñas no coinciden'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // ── SECCIÓN: MASCOTA ───────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: HuellitasTheme.arena,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          '¿Tienes mascota?',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        value: _tieneMascota,
                        onChanged: (val) => setState(() => _tieneMascota = val),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      ),
                    ),

                    if (_tieneMascota) ...[
                      const SizedBox(height: 20),
                      const SectionLabel('Datos de la mascota'),
                      const SizedBox(height: 12),
                      MascotaFormFields(mascota: _mascota),
                    ],

                    const SizedBox(height: 28),

                    // ── BOTÓN REGISTRARSE ──────────────────────────────────
                    ClayButton(
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _registrar,
                        child: _cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: HuellitasTheme.ink,
                                ),
                              )
                            : const Text('Registrarse'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── ENLACE A LOGIN ─────────────────────────────────────
                    AuthLink(
                      prefixText: '¿Ya tienes cuenta? ',
                      linkText: 'Inicia sesión',
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
