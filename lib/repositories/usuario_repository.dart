import 'package:cloud_firestore/cloud_firestore.dart';
import '../mascota_model.dart';

class UsuarioRepository {
  static final _col = FirebaseFirestore.instance.collection('usuarios');

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

  // ── Stream de todos los usuarios (solo admin) ─────────────────────────────
  static Stream<List<UsuarioModel>> todos() =>
      _col.snapshots().map((snap) => snap.docs
          .where((d) => (d.data()['rol'] ?? 'usuario') != 'admin')
          .map((d) => UsuarioModel.fromFirestore(d.id, d.data()))
          .toList());

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
