import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'huellitas_theme.dart';
import 'registro.dart';
import 'home_shell.dart';
import 'admin_shell.dart';
import 'widgets.dart';
import 'repositories/usuario_repository.dart';
import 'services/auth_service.dart';

class IniciarSesionPage extends StatefulWidget {
  const IniciarSesionPage({super.key});

  @override
  State<IniciarSesionPage> createState() => _IniciarSesionPageState();
}

class _IniciarSesionPageState extends State<IniciarSesionPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
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

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    try {
      final correo = _correoCtrl.text.trim();
      final contra = _contrasenaCtrl.text;

      final credential = await AuthService.iniciarSesion(correo, contra);
      final uid = credential.user!.uid;

      final usuario = await UsuarioRepository.obtener(uid);
      if (usuario == null) {
        _mostrarError('No se encontró el perfil. Regístrate nuevamente.');
        return;
      }

      if (!mounted) return;

      if (usuario.rol == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminShell()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeShell(usuario: usuario)),
        );
      }
    } on FirebaseAuthException catch (e) {
      _mostrarError(AuthService.mensajeError(e.code));
    } catch (e) {
      _mostrarError('Error: ${e.toString()}');
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
        automaticallyImplyLeading: false,
        elevation: 0,
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

                    // ── ÍCONO ────────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: HuellitasTheme.lavanda,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: HuellitasTheme.claySm,
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 40,
                          color: HuellitasTheme.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── TÍTULO ───────────────────────────────────────────
                    Text(
                      'Hola de nuevo',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ingresa para ver a tu mascota',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: HuellitasTheme.inkSoft),
                    ),
                    const SizedBox(height: 28),

                    // ── SECCIÓN CREDENCIALES ──────────────────────────────
                    const SectionLabel('Tus datos'),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _correoCtrl,
                      decoration: HuellitasTheme.field('Correo electrónico'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ingresa tu correo' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _contrasenaCtrl,
                      decoration: HuellitasTheme.field('Contraseña'),
                      obscureText: true,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                    ),
                    const SizedBox(height: 28),

                    // ── BOTÓN ENTRAR ────────────────────────────────────
                    ClayButton(
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _entrar,
                        child: _cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: HuellitasTheme.ink,
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── ENLACE A REGISTRO ─────────────────────────────────
                    AuthLink(
                      prefixText: '¿No tienes cuenta? ',
                      linkText: 'Regístrate aquí',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FormularioRegistroPage()),
                      ),
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
