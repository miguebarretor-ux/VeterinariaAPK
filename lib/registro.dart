import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'huellitas_theme.dart';
import 'mascota_model.dart';
import 'registro_exitoso.dart';
import 'registro_repository.dart';
import 'validadores.dart';
import 'widgets/clay.dart';

/// Registro en tres pasos cortos: Sobre ti → Tu cuenta → Tu mascota.
///
/// Cada paso valida solo sus campos, así los errores siempre quedan a la
/// vista, y lo escrito se conserva al ir hacia atrás.
class FormularioRegistroPage extends StatefulWidget {
  final RegistroRepository repository;

  const FormularioRegistroPage({
    super.key,
    this.repository = const RegistroSimuladoRepository(),
  });

  @override
  State<FormularioRegistroPage> createState() => _FormularioRegistroPageState();
}

class _FormularioRegistroPageState extends State<FormularioRegistroPage> {
  static const _titulos = ['Sobre ti', 'Tu cuenta', 'Tu mascota'];
  static const _ayudas = [
    'Así sabremos cómo llamarte y a nombre de quién quedan las citas.',
    'Con estos datos vas a iniciar sesión.',
    'Dejamos listo su carnet desde el primer día.',
  ];

  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());
  final _scrollCtrl = ScrollController();

  // Paso 1 — Sobre ti
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController();
  String _tipoDocumento = Opciones.tiposDocumento.first;

  // Paso 2 — Tu cuenta
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _verContrasena = false;

  // Paso 3 — Tu mascota
  bool _tieneMascota = true;
  final _mascotaNombreCtrl = TextEditingController();
  final _mascotaEspecieCtrl = TextEditingController();
  final _mascotaEdadCtrl = TextEditingController();
  final _mascotaPesoCtrl = TextEditingController();
  final _mascotaRazaCtrl = TextEditingController();
  String _mascotaTipo = Opciones.tiposMascota.first;
  String _unidadEdad = Opciones.anios;

  int _paso = 0;
  bool _enviando = false;

  /// Pasos donde ya se intentó continuar con errores: desde ahí cada campo se
  /// revalida al corregirlo, para que el error desaparezca en el momento.
  final _pasosConIntento = <int>{};

  bool get _esUltimoPaso => _paso == _titulos.length - 1;
  bool get _esPasaporte => _tipoDocumento == Opciones.pasaporte;

  @override
  void initState() {
    super.initState();
    // La lista de requisitos de la contraseña se actualiza al escribir.
    _contrasenaCtrl.addListener(_alCambiarContrasena);
  }

  @override
  void dispose() {
    _contrasenaCtrl.removeListener(_alCambiarContrasena);
    for (final c in [
      _nombreCtrl,
      _apellidoCtrl,
      _documentoCtrl,
      _correoCtrl,
      _contrasenaCtrl,
      _confirmarCtrl,
      _mascotaNombreCtrl,
      _mascotaEspecieCtrl,
      _mascotaEdadCtrl,
      _mascotaPesoCtrl,
      _mascotaRazaCtrl,
    ]) {
      c.dispose();
    }
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _alCambiarContrasena() => setState(() {});

  // ─── NAVEGACIÓN ENTRE PASOS ────────────────────────────────────────────────

  void _irAlPaso(int paso) {
    FocusScope.of(context).unfocus();
    setState(() => _paso = paso);
    if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0);
  }

  void _atras() {
    if (_paso > 0 && !_enviando) _irAlPaso(_paso - 1);
  }

  void _continuar() {
    if (_enviando) return;
    final invalidos = _formKeys[_paso].currentState!.validateGranularly();
    if (invalidos.isNotEmpty) {
      setState(() => _pasosConIntento.add(_paso));
      _mostrarPrimerError(invalidos.first.context);
      return;
    }
    if (_esUltimoPaso) {
      _registrar();
    } else {
      _irAlPaso(_paso + 1);
    }
  }

  /// Lleva a la vista el primer campo con error y deja el cursor en él, para
  /// corregirlo sin tener que buscarlo.
  void _mostrarPrimerError(BuildContext campo) {
    Scrollable.ensureVisible(
      campo,
      alignment: 0.2,
      duration: const Duration(milliseconds: 250),
    );
    FocusNode? foco;
    void buscar(Element e) {
      if (foco != null) return;
      final w = e.widget;
      if (w is EditableText) {
        foco = w.focusNode;
      } else {
        e.visitChildren(buscar);
      }
    }

    (campo as Element).visitChildren(buscar);
    foco?.requestFocus();
  }

  // ─── ENVÍO ─────────────────────────────────────────────────────────────────

  UsuarioModel _armarUsuario() {
    return UsuarioModel(
      tipoDocumento: _tipoDocumento,
      numeroDocumento: _documentoCtrl.text.trim().toUpperCase(),
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      correo: _correoCtrl.text.trim().toLowerCase(),
      contrasena: _contrasenaCtrl.text,
      tieneMascota: _tieneMascota,
      mascota: !_tieneMascota
          ? null
          : MascotaModel(
              nombre: _mascotaNombreCtrl.text.trim(),
              tipo: _mascotaTipo,
              especie: _mascotaTipo == Opciones.otraMascota
                  ? _mascotaEspecieCtrl.text.trim()
                  : null,
              edad: int.parse(_mascotaEdadCtrl.text.trim()),
              unidadEdad: _unidadEdad,
              peso: Validadores.leerPeso(_mascotaPesoCtrl.text),
              raza: _mascotaRazaCtrl.text.trim(),
            ),
    );
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();
    final usuario = _armarUsuario();
    setState(() => _enviando = true);
    try {
      await widget.repository.registrar(usuario);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => RegistroExitosoPage(
            usuario: usuario,
            repository: widget.repository,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      final mensaje = e is RegistroException
          ? e.mensaje
          : 'No pudimos crear tu cuenta. Revisa tu conexión e inténtalo de nuevo.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(mensaje),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: HuellitasTheme.lima,
              onPressed: _continuar,
            ),
          ),
        );
    }
  }

  // ─── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return PopScope(
      // El "atrás" del sistema retrocede un paso en vez de salir y perder todo.
      canPop: _paso == 0 && !_enviando,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _atras();
      },
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  // En tablet y escritorio el formulario no se estira.
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Encabezado dentro de la columna: queda alineado con el
                      // formulario también en pantallas anchas.
                      Row(
                        children: [
                          if (_paso > 0)
                            // Desplazado para que la flecha quede alineada
                            // con el borde izquierdo del contenido.
                            Transform.translate(
                              offset: const Offset(-10, 0),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_rounded),
                                color: HuellitasTheme.ink,
                                tooltip: 'Volver al paso anterior',
                                onPressed: _enviando ? null : _atras,
                              ),
                            ),
                          // Alto fijo: el título no salta al aparecer la flecha.
                          const SizedBox(height: 48),
                          Expanded(
                            child: Semantics(
                              header: true,
                              child: Text(
                                'Crear cuenta',
                                style: textos.titleLarge!.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      PasoProgreso(actual: _paso, titulos: _titulos),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: MediaQuery.of(context).disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        // Solo se dibuja el paso actual: evita ver dos
                        // formularios superpuestos durante la transición.
                        layoutBuilder: (actual, _) => actual ?? const SizedBox.shrink(),
                        child: ClayCard(
                          key: ValueKey(_paso),
                          child: Form(
                            key: _formKeys[_paso],
                            autovalidateMode: _pasosConIntento.contains(_paso)
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            child: AutofillGroup(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Semantics(
                                    header: true,
                                    child: Text(_titulos[_paso], style: textos.titleLarge),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _ayudas[_paso],
                                    style: textos.bodyMedium!
                                        .copyWith(color: HuellitasTheme.inkSoft),
                                  ),
                                  const SizedBox(height: 22),
                                  ...switch (_paso) {
                                    0 => _camposSobreTi(),
                                    1 => _camposCuenta(),
                                    _ => _camposMascota(),
                                  },
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      ClayButton(
                        label: _esUltimoPaso ? 'Crear mi cuenta' : 'Continuar',
                        labelCargando: 'Creando tu cuenta…',
                        icon: _esUltimoPaso ? null : Icons.arrow_forward_rounded,
                        cargando: _enviando,
                        onPressed: _continuar,
                      ),
                      if (_paso > 0) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _enviando ? null : _atras,
                          child: const Text('Atrás'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _espacio = SizedBox(height: 14);

  // ── PASO 1: SOBRE TI ─────────────────────────────────────────────────────

  List<Widget> _camposSobreTi() {
    return [
      TextFormField(
        controller: _nombreCtrl,
        decoration: HuellitasTheme.field('Nombre'),
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.givenName],
        validator: (v) => Validadores.nombrePersona(v, queFalta: 'tu nombre'),
      ),
      _espacio,
      TextFormField(
        controller: _apellidoCtrl,
        decoration: HuellitasTheme.field('Apellido'),
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.familyName],
        validator: (v) => Validadores.nombrePersona(v, queFalta: 'tu apellido'),
      ),
      _espacio,
      DropdownButtonFormField<String>(
        initialValue: _tipoDocumento,
        decoration: HuellitasTheme.field('Tipo de documento'),
        isExpanded: true,
        borderRadius: BorderRadius.circular(HuellitasTheme.radiusField),
        dropdownColor: HuellitasTheme.leche,
        icon: const Icon(Icons.expand_more_rounded, color: HuellitasTheme.inkSoft),
        style: const TextStyle(
          fontFamily: HuellitasTheme.fontBody,
          fontSize: 16,
          color: HuellitasTheme.ink,
        ),
        items: [
          for (final t in Opciones.tiposDocumento)
            DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis)),
        ],
        onChanged: (v) {
          if (v == null || v == _tipoDocumento) return;
          setState(() => _tipoDocumento = v);
          // Las reglas del número cambian con el tipo: si ya había un error
          // a la vista, se vuelve a evaluar.
          if (_pasosConIntento.contains(0)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _paso == 0) _formKeys[0].currentState?.validate();
            });
          }
        },
      ),
      _espacio,
      TextFormField(
        controller: _documentoCtrl,
        decoration: HuellitasTheme.field(
          'Número de documento',
          helper: _esPasaporte ? 'Letras y números, sin espacios' : 'Solo números, sin puntos',
        ),
        keyboardType: _esPasaporte ? TextInputType.visiblePassword : TextInputType.number,
        textCapitalization:
            _esPasaporte ? TextCapitalization.characters : TextCapitalization.none,
        textInputAction: TextInputAction.done,
        autocorrect: false,
        enableSuggestions: false,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            _esPasaporte ? RegExp(r'[A-Za-z0-9]') : RegExp(r'\d'),
          ),
          LengthLimitingTextInputFormatter(12),
        ],
        validator: (v) => Validadores.documento(_tipoDocumento, v),
        onFieldSubmitted: (_) => _continuar(),
      ),
    ];
  }

  // ── PASO 2: TU CUENTA ────────────────────────────────────────────────────

  List<Widget> _camposCuenta() {
    final clave = _contrasenaCtrl.text;
    final botonVer = IconButton(
      icon: Icon(_verContrasena ? Icons.visibility_off_rounded : Icons.visibility_rounded),
      tooltip: _verContrasena ? 'Ocultar contraseña' : 'Mostrar contraseña',
      onPressed: () => setState(() => _verContrasena = !_verContrasena),
    );

    return [
      TextFormField(
        controller: _correoCtrl,
        decoration: HuellitasTheme.field(
          'Correo electrónico',
          hint: 'nombre@correo.com',
        ),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: const [AutofillHints.email],
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
        validator: Validadores.correo,
      ),
      _espacio,
      TextFormField(
        controller: _contrasenaCtrl,
        decoration: HuellitasTheme.field(
          'Contraseña',
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: botonVer,
          ),
        ),
        obscureText: !_verContrasena,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: const [AutofillHints.newPassword],
        validator: Validadores.contrasena,
      ),
      const SizedBox(height: 10),
      _Requisito('Mínimo ${Validadores.contrasenaMinima} caracteres',
          cumplido: Validadores.tieneLongitud(clave)),
      _Requisito('Al menos una letra', cumplido: Validadores.tieneLetra(clave)),
      _Requisito('Al menos un número', cumplido: Validadores.tieneNumero(clave)),
      _espacio,
      TextFormField(
        controller: _confirmarCtrl,
        decoration: HuellitasTheme.field('Repite la contraseña'),
        obscureText: !_verContrasena,
        textInputAction: TextInputAction.done,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: const [AutofillHints.newPassword],
        validator: (v) => Validadores.confirmacion(v, _contrasenaCtrl.text),
        onFieldSubmitted: (_) => _continuar(),
      ),
    ];
  }

  // ── PASO 3: TU MASCOTA ───────────────────────────────────────────────────

  List<Widget> _camposMascota() {
    final esOtro = _mascotaTipo == Opciones.otraMascota;

    return [
      const _EtiquetaGrupo('¿Tienes mascota?'),
      ClayChoice<bool>(
        semanticLabel: '¿Tienes mascota?',
        options: const [true, false],
        value: _tieneMascota,
        labelOf: (v) => v ? 'Sí' : 'Todavía no',
        onChanged: (v) => setState(() => _tieneMascota = v),
      ),
      if (!_tieneMascota) ...[
        const SizedBox(height: 16),
        Text(
          'No hay problema. Crea tu cuenta y listo.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: HuellitasTheme.inkSoft),
        ),
      ] else ...[
        const SizedBox(height: 18),
        TextFormField(
          controller: _mascotaNombreCtrl,
          decoration: HuellitasTheme.field('Nombre de tu mascota'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          validator: (v) =>
              Validadores.obligatorio(v, mensaje: 'Escribe el nombre de tu mascota'),
        ),
        const SizedBox(height: 18),
        const _EtiquetaGrupo('¿Qué es?'),
        ClayChoice<String>(
          semanticLabel: 'Tipo de mascota',
          options: Opciones.tiposMascota,
          value: _mascotaTipo,
          labelOf: (t) => t,
          onChanged: (t) => setState(() => _mascotaTipo = t),
        ),
        if (esOtro) ...[
          _espacio,
          TextFormField(
            controller: _mascotaEspecieCtrl,
            decoration: HuellitasTheme.field('¿Qué animal es?', hint: 'Conejo, ave, hámster…'),
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                Validadores.obligatorio(v, mensaje: 'Cuéntanos qué animal es'),
          ),
        ],
        const SizedBox(height: 18),
        const _EtiquetaGrupo('¿Qué edad tiene?'),
        // Un solo FormField para número + unidad: el mensaje de error ocupa
        // todo el ancho en vez de quedar apretado bajo el campo angosto.
        FormField<String>(
          initialValue: _mascotaEdadCtrl.text,
          validator: (_) => Validadores.edad(_mascotaEdadCtrl.text, _unidadEdad),
          builder: (estado) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _mascotaEdadCtrl,
                      decoration: HuellitasTheme.field('Edad').copyWith(
                        // Borde de error sin repetir el texto dentro del campo.
                        error: estado.hasError ? const SizedBox.shrink() : null,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      onChanged: estado.didChange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 7,
                    child: ClayChoice<String>(
                      semanticLabel: 'Unidad de la edad',
                      options: Opciones.unidadesEdad,
                      value: _unidadEdad,
                      labelOf: (u) => u == Opciones.anios ? 'Años' : 'Meses',
                      onChanged: (u) {
                        setState(() => _unidadEdad = u);
                        // La regla depende de la unidad: se reevalúa si ya
                        // había un error a la vista.
                        if (estado.hasError) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (estado.mounted) estado.validate();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (estado.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 22, top: 6),
                  child: Text(
                    estado.errorText!,
                    style: Theme.of(context).inputDecorationTheme.errorStyle,
                  ),
                ),
            ],
          ),
        ),
        _espacio,
        TextFormField(
          controller: _mascotaRazaCtrl,
          decoration: HuellitasTheme.field(
            'Raza (opcional)',
            helper: 'Si es criollo o no la sabes, déjalo vacío.',
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        _espacio,
        TextFormField(
          controller: _mascotaPesoCtrl,
          decoration: HuellitasTheme.field('Peso en kg (opcional)', hint: 'Ej.: 4,5'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            LengthLimitingTextInputFormatter(7),
          ],
          validator: Validadores.peso,
          onFieldSubmitted: (_) => _continuar(),
        ),
      ],
    ];
  }
}

/// Pregunta corta encima de un selector o grupo de campos.
class _EtiquetaGrupo extends StatelessWidget {
  final String text;
  const _EtiquetaGrupo(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: ExcludeSemantics(
        // El selector que sigue ya anuncia esta pregunta como su etiqueta.
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}

/// Requisito de la contraseña que se marca en vivo al cumplirse.
class _Requisito extends StatelessWidget {
  final String text;
  final bool cumplido;
  const _Requisito(this.text, {required this.cumplido});

  @override
  Widget build(BuildContext context) {
    final color = cumplido ? HuellitasTheme.mentaInk : HuellitasTheme.inkSoft;
    return Semantics(
      label: '$text: ${cumplido ? 'cumplido' : 'pendiente'}',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(left: 6, top: 4),
          child: Row(
            children: [
              Icon(
                cumplido ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: cumplido ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
