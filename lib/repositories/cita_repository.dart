import 'package:cloud_firestore/cloud_firestore.dart';
import '../mascota_model.dart';

class CitaRepository {
  static CollectionReference _col(String uid) => FirebaseFirestore.instance
      .collection('usuarios')
      .doc(uid)
      .collection('citas');

  // ── Agregar ───────────────────────────────────────────────────────────────
  static Future<void> agregar(String uid, CitaModel c) =>
      _col(uid).add(c.toJson());

  // ── Stream en tiempo real (citas de un usuario) ───────────────────────────
  static Stream<List<CitaModel>> stream(String uid) =>
      _col(uid).snapshots().map((snap) => snap.docs
          .map((d) => CitaModel.fromJson(
              {'id': d.id, ...d.data() as Map<String, dynamic>}))
          .toList());

  // ── Stream collectionGroup: todas las citas de un veterinario ─────────────
  // Requiere índice en Firestore: collectionGroup 'citas' campo 'veterinarioId'.
  static Stream<List<CitaModel>> streamPorVeterinario(String vetId) =>
      FirebaseFirestore.instance
          .collectionGroup('citas')
          .where('veterinarioId', isEqualTo: vetId)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => CitaModel.fromJson({'id': d.id, ...d.data()}))
              .toList());

  // ── Eliminar ──────────────────────────────────────────────────────────────
  static Future<void> eliminar(String uid, String citaId) =>
      _col(uid).doc(citaId).delete();
}
