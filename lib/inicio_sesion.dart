import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'huellitas_theme.dart';
import 'inicio.dart';
import 'registro.dart';
import 'registro_repository.dart';
import 'validadores.dart';
import 'widgets/clay.dart';

/// Inicio de sesión con correo y contraseña.
class InicioSesionPage extends StatefulWidget {
  final RegistroRepository repository;

  const InicioSesionPage({super.key, required this.repository});

  @override
  State<InicioSesionPage> createState() => _InicioSesionPageState();
}

class _InicioSesionPageState extends State<InicioSesionPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  final _focoCorreo = FocusNode();
  final _focoContrasena = FocusNode();

  bool _verContrasena = false;
  bool _enviando = false;
  bool _huboIntento = false;
  String? _error;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    _focoCorreo.dispose();
    _focoContrasena.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_enviando) return;
    if (!_formKey.currentState!.validate()) {
      setState(() => _huboIntento = true);
      // El cursor va al primer campo por corregir.
      (Validadores.correo(_correoCtrl.text) != null ? _focoCorreo : _focoContrasena)
          .requestFocus();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      final usuario =
          await widget.repository.iniciarSesion(_correoCtrl.text, _contrasenaCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => InicioPage(usuario: usuario, repository: widget.repository),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _error = e is RegistroException
            ? e.mensaje
            : 'No pudimos iniciar sesión. Revisa tu conexión e inténtalo de nuevo.';
      });
    }
  }

  void _irACrearCuenta() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FormularioRegistroPage(repository: widget.repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: const Offset(-10, 0),
                        child: IconButton(
                          onPressed: _enviando ? null : () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: HuellitasTheme.ink,
                          tooltip: 'Volver',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AbsorbPointer(
                      absorbing: _enviando,
                      child: ClayCard(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _huboIntento
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text('Iniciar sesión', style: textos.titleLarge),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Qué bueno verte de nuevo.',
                                  style: textos.bodyMedium!
                                      .copyWith(color: HuellitasTheme.inkSoft),
                                ),
                                const SizedBox(height: 22),
                                TextFormField(
                                  controller: _correoCtrl,
                                  focusNode: _focoCorreo,
                                  decoration: HuellitasTheme.field(
                                    'Correo electrónico',
                                    hint: 'nombre@correo.com',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  autofillHints: const [AutofillHints.email],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                  ],
                                  validator: Validadores.correo,
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _contrasenaCtrl,
                                  focusNode: _focoContrasena,
                                  decoration: HuellitasTheme.field(
                                    'Contraseña',
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: IconButton(
                                        icon: Icon(
                                          _verContrasena
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                        ),
                                        tooltip: _verContrasena
                                            ? 'Ocultar contraseña'
                                            : 'Mostrar contraseña',
                                        onPressed: () =>
                                            setState(() => _verContrasena = !_verContrasena),
                                      ),
                                    ),
                                  ),
                                  obscureText: !_verContrasena,
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  autofillHints: const [AutofillHints.password],
                                  // Aquí no se repiten las reglas de creación:
                                  // basta con que no esté vacía.
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Escribe tu contraseña'
                                      : null,
                                  onFieldSubmitted: (_) => _entrar(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      AvisoError(_error!),
                      const SizedBox(height: 14),
                    ],
                    ClayButton(
                      label: 'Iniciar sesión',
                      labelCargando: 'Entrando…',
                      cargando: _enviando,
                      onPressed: _entrar,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _enviando ? null : _irACrearCuenta,
                      child: const Text('¿No tienes cuenta? Crear cuenta'),
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
