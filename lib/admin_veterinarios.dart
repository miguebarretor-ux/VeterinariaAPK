import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'services/auth_service.dart';
import 'repositories/usuario_repository.dart';

class AdminVeterinariosPage extends StatefulWidget {
  const AdminVeterinariosPage({super.key});

  @override
  State<AdminVeterinariosPage> createState() => _AdminVeterinariosPageState();
}

class _AdminVeterinariosPageState extends State<AdminVeterinariosPage> {
  List<UsuarioModel> _vets = [];
  bool _cargando = true;
  StreamSubscription<List<UsuarioModel>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = UsuarioRepository.veterinarios().listen(
      (lista) {
        if (mounted) {
          setState(() {
            _vets = lista;
            _cargando = false;
          });
        }
      },
      onError: (_) {
        if (mounted) setState(() => _cargando = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Abre el formulario: vacío para registrar, o con [vet] para editarlo.
  void _agregarVet([UsuarioModel? vet]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _NuevoVetSheet(vet: vet),
      ),
    );
  }

  Future<void> _cambiarActivo(UsuarioModel vet, bool activo) async {
    try {
      await UsuarioRepository.cambiarActivo(vet.uid!, activo);
      if (mounted) {
        mostrarAviso(
          context,
          activo
              ? '${vet.nombreCompleto} vuelve a recibir citas.'
              : '${vet.nombreCompleto} ya no recibe citas nuevas ni puede entrar.',
        );
      }
    } catch (e) {
      if (mounted) mostrarAviso(context, mensajeDeError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: HuellitasTheme.menta),
      );
    }

    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      body: _vets.isEmpty ? _emptyState(context) : _lista(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarVet,
        backgroundColor: HuellitasTheme.ink,
        icon: const Icon(Icons.person_add_outlined,
            color: HuellitasTheme.leche),
        label: const Text(
          'Nuevo vet',
          style: TextStyle(
              color: HuellitasTheme.leche, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _lista(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Container(
          decoration:
              HuellitasTheme.cardBox(color: HuellitasTheme.menta),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.medical_services_outlined,
                  color: HuellitasTheme.ink, size: 28),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_vets.length}',
                      style: Theme.of(context).textTheme.displayLarge),
                  Text(
                    _vets.length == 1
                        ? 'veterinario registrado'
                        : 'veterinarios registrados',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: HuellitasTheme.inkSoft),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Equipo veterinario'),
        const SizedBox(height: 12),
        ..._vets.map((v) => _VetCard(
              vet: v,
              onEditar: () => _agregarVet(v),
              onActivo: (a) => _cambiarActivo(v, a),
            )),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
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
                color: HuellitasTheme.menta,
                borderRadius: BorderRadius.circular(36),
                boxShadow: HuellitasTheme.claySm,
              ),
              child: const Icon(Icons.medical_services_outlined,
                  size: 36, color: HuellitasTheme.ink),
            ),
            const SizedBox(height: 20),
            Text('Sin veterinarios registrados',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Pulsa el botón para registrar\nel primer veterinario del equipo.',
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

// ── TARJETA VET ────────────────────────────────────────────────────────────────

class _VetCard extends StatelessWidget {
  final UsuarioModel vet;
  final VoidCallback onEditar;
  final ValueChanged<bool> onActivo;
  const _VetCard({
    required this.vet,
    required this.onEditar,
    required this.onActivo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: HuellitasTheme.cardBox(
          color: vet.activo ? HuellitasTheme.leche : HuellitasTheme.arena),
      padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: vet.activo ? HuellitasTheme.menta : HuellitasTheme.arena,
              borderRadius: BorderRadius.circular(26),
              boxShadow: HuellitasTheme.claySm,
            ),
            child: Center(
              child: Text(
                vet.nombre.isNotEmpty ? vet.nombre[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vet.nombre} ${vet.apellido}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 3),
                Text(
                  vet.correo,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: HuellitasTheme.inkSoft, fontSize: 13),
                ),
                if (vet.especialidad.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: HuellitasTheme.menta,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 12, color: HuellitasTheme.ink),
                        const SizedBox(width: 4),
                        Text(
                          vet.especialidad,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: HuellitasTheme.ink),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: vet.activo,
                onChanged: onActivo,
                activeThumbColor: HuellitasTheme.menta,
              ),
              Text(
                vet.activo ? 'Activo' : 'Inactivo',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: HuellitasTheme.inkSoft),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: HuellitasTheme.inkSoft,
                tooltip: 'Editar',
                onPressed: onEditar,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── FORMULARIO NUEVO VET ───────────────────────────────────────────────────────

class _NuevoVetSheet extends StatefulWidget {
  /// Con [vet] el formulario edita a ese veterinario (sin correo ni clave,
  /// que pertenecen a su cuenta de acceso).
  final UsuarioModel? vet;
  const _NuevoVetSheet({this.vet});

  @override
  State<_NuevoVetSheet> createState() => _NuevoVetSheetState();
}

class _NuevoVetSheetState extends State<_NuevoVetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _contrasenaCtrl = TextEditingController();
  String _nombre = '';
  String _apellido = '';
  String _correo = '';
  String _especialidad = '';
  bool _cargando = false;

  @override
  void dispose() {
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  void _mostrarError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: HuellitasTheme.coral,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  bool get _editando => widget.vet != null;

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _cargando = true);

    try {
      if (_editando) {
        await UsuarioRepository.actualizarVeterinario(
          widget.vet!.uid!,
          nombre: _nombre,
          apellido: _apellido,
          especialidad: _especialidad,
        );
        if (!mounted) return;
        Navigator.pop(context);
        mostrarAviso(context, 'Datos de $_nombre actualizados.');
        return;
      }

      // Crear cuenta Firebase Auth sin cerrar la sesión del admin,
      // usando una instancia secundaria de la app.
      final secondaryApp = await Firebase.initializeApp(
        name: 'vetCreation_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      try {
        final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
        final credential =
            await secondaryAuth.createUserWithEmailAndPassword(
          email: _correo,
          password: _contrasenaCtrl.text,
        );
        final uid = credential.user!.uid;

        // Guardar perfil veterinario en Firestore
        final vet = UsuarioModel(
          uid: uid,
          nombre: _nombre,
          apellido: _apellido,
          correo: _correo,
          rol: 'veterinario',
          especialidad: _especialidad,
        );
        try {
          await UsuarioRepository.crear(uid, vet);
        } catch (_) {
          // Sin perfil la cuenta no sirve (no podría entrar): se elimina
          // para no dejar el correo ocupado.
          await credential.user!.delete();
          rethrow;
        }
      } finally {
        await secondaryApp.delete();
      }

      if (!mounted) return;
      Navigator.pop(context);
      mostrarAviso(context, 'Veterinario $_nombre creado correctamente.');
    } on FirebaseAuthException catch (e) {
      _mostrarError(AuthService.mensajeError(e.code));
    } catch (e) {
      _mostrarError(mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: HuellitasTheme.menta,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 18),
            Text(_editando ? 'Editar veterinario' : 'Registrar veterinario',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: widget.vet?.nombre,
              decoration: HuellitasTheme.field('Nombre'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresa el nombre'
                  : null,
              onSaved: (v) => _nombre = v!.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: widget.vet?.apellido,
              decoration: HuellitasTheme.field('Apellido'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresa el apellido'
                  : null,
              onSaved: (v) => _apellido = v!.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: widget.vet?.especialidad,
              decoration: HuellitasTheme.field('Especialidad',
                  hint: 'Ej: Cirugía, Dermatología'),
              textCapitalization: TextCapitalization.sentences,
              onSaved: (v) => _especialidad = v?.trim() ?? '',
            ),
            if (!_editando) ...[
            const SizedBox(height: 12),
            TextFormField(
              decoration: HuellitasTheme.field('Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa el correo';
                }
                if (!v.contains('@')) return 'Correo no válido';
                return null;
              },
              onSaved: (v) => _correo = v!.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contrasenaCtrl,
              decoration:
                  HuellitasTheme.field('Contraseña temporal'),
              obscureText: true,
              validator: (v) => (v == null || v.length < 6)
                  ? 'Mínimo 6 caracteres'
                  : null,
            ),
            ],
            const SizedBox(height: 24),
            ClayButton(
              child: ElevatedButton(
                onPressed: _cargando ? null : _crear,
                child: _cargando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: HuellitasTheme.ink),
                      )
                    : Text(_editando ? 'Guardar cambios' : 'Crear veterinario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
