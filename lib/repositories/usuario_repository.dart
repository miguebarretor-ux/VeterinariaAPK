import 'package:cloud_firestore/cloud_firestore.dart';
import '../mascota_model.dart';
import 'db.dart';

class UsuarioRepository {
  static CollectionReference<Map<String, dynamic>> get _col =>
      Db.i.collection('usuarios');

  // ── Crear ─────────────────────────────────────────────────────────────────
  static Future<void> crear(String uid, UsuarioModel u) =>
      _col.doc(uid).set(u.toFirestore());

  // ── Leer uno ──────────────────────────────────────────────────────────────
  static Future<UsuarioModel?> obtener(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return UsuarioModel.fromFirestore(uid, doc.data()!);
  }

  // ── Stream de un usuario (tiempo real) ───────────────────────────────────
  static Stream<UsuarioModel?> stream(String uid) =>
      _col.doc(uid).snapshots().map((doc) =>
          doc.exists ? UsuarioModel.fromFirestore(uid, doc.data()!) : null);

  // ── Actualizar ────────────────────────────────────────────────────────────
  static Future<void> actualizar(String uid, UsuarioModel u) =>
      _col.doc(uid).update(u.toFirestore());

  // ── Stream de usuarios regulares (excluye admin y veterinario) ───────────
  static Stream<List<UsuarioModel>> todos() =>
      _col.snapshots().map((snap) => snap.docs
          .where((d) {
            final rol = d.data()['rol'] ?? 'usuario';
            return rol != 'admin' && rol != 'veterinario';
          })
          .map((d) => UsuarioModel.fromFirestore(d.id, d.data()))
          .toList());

  // ── Stream de veterinarios ────────────────────────────────────────────────
  static Stream<List<UsuarioModel>> veterinarios() =>
      _col.snapshots().map((snap) => snap.docs
          .where((d) => (d.data()['rol'] ?? 'usuario') == 'veterinario')
          .map((d) => UsuarioModel.fromFirestore(d.id, d.data()))
          .toList());

  // ── Veterinarios activos, una sola vez (para agendar y asignar) ───────────
  static Future<List<UsuarioModel>> veterinariosOnce() async {
    final snap = await _col.where('rol', isEqualTo: 'veterinario').get();
    return snap.docs
        .map((d) => UsuarioModel.fromFirestore(d.id, d.data()))
        .where((v) => v.activo)
        .toList()
      ..sort((a, b) => a.nombreCompleto.compareTo(b.nombreCompleto));
  }

  // ── Editar datos de un veterinario (admin) ────────────────────────────────
  static Future<void> actualizarVeterinario(
    String uid, {
    required String nombre,
    required String apellido,
    required String especialidad,
  }) =>
      _col.doc(uid).update({
        'nombre': nombre,
        'apellido': apellido,
        'especialidad': especialidad,
      });

  /// Activa o desactiva a un veterinario. Inactivo no aparece al agendar ni
  /// puede iniciar sesión; sus citas e historial se conservan.
  static Future<void> cambiarActivo(String uid, bool activo) =>
      _col.doc(uid).update({'activo': activo});

  // ── Agregar vacuna a una mascota ──────────────────────────────────────────
  static Future<void> agregarVacuna(
      String uid, String mascotaId, VacunaModel v) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return;
    final usuario = UsuarioModel.fromFirestore(uid, doc.data()!);
    final idx = usuario.mascotas.indexWhere((m) => m.id == mascotaId);
    if (idx < 0) return;
    usuario.mascotas[idx].vacunas.add(v);
    await _col.doc(uid).update(
        {'mascotas': usuario.mascotas.map((m) => m.toFirestore()).toList()});
  }

  // ── Eliminar vacuna de una mascota ────────────────────────────────────────
  static Future<void> eliminarVacuna(
      String uid, String mascotaId, int index) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return;
    final usuario = UsuarioModel.fromFirestore(uid, doc.data()!);
    final idx = usuario.mascotas.indexWhere((m) => m.id == mascotaId);
    if (idx < 0) return;
    usuario.mascotas[idx].vacunas.removeAt(index);
    await _col.doc(uid).update(
        {'mascotas': usuario.mascotas.map((m) => m.toFirestore()).toList()});
  }
}
