import 'package:cloud_firestore/cloud_firestore.dart';
import '../mascota_model.dart';
import 'db.dart';

/// Citas y agenda.
///
/// Cada cita vive en `usuarios/{uid}/citas/{id}`. Cuando tiene veterinario,
/// además existe un documento en `agenda/{vetId}_{fecha}_{hora}` que reserva
/// ese horario: así dos personas no pueden agendar al mismo veterinario a la
/// misma hora. Cita y reserva se escriben siempre en la misma transacción.
class CitaRepository {
  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      Db.i.collection('usuarios').doc(uid).collection('citas');

  static CollectionReference<Map<String, dynamic>> get _agenda =>
      Db.i.collection('agenda');

  static String idAgenda(String vetId, String fecha, String hora) =>
      '${vetId}_${fecha}_$hora';

  static CitaModel _desde(DocumentSnapshot<Map<String, dynamic>> d) =>
      CitaModel.fromJson({
        ...d.data()!,
        'id': d.id,
        // El dueño es el abuelo del documento: usuarios/{uid}/citas/{id}
        'duenoUid': d.reference.parent.parent?.id,
      });

  static const _ocupado = OperacionException(
      'Ese horario ya está ocupado con ese veterinario. Elige otra hora.');

  // ── Agendar ───────────────────────────────────────────────────────────────

  /// Crea la cita. Si lleva veterinario, reserva su horario; lanza
  /// [OperacionException] si ya estaba ocupado.
  static Future<void> agendar(String uid, CitaModel c) async {
    final citaRef = _col(uid).doc();
    c.duenoUid = uid;
    c.estado = EstadoCita.pendiente;

    await Db.i.runTransaction((tx) async {
      if (!c.sinAsignar) {
        final cupo = _agenda.doc(idAgenda(c.veterinarioId!, c.fecha, c.hora));
        if ((await tx.get(cupo)).exists) throw _ocupado;
        tx.set(cupo, _datosCupo(c, uid, citaRef.id));
      }
      tx.set(citaRef, c.toJson());
    });
  }

  static Map<String, dynamic> _datosCupo(
          CitaModel c, String uid, String citaId) =>
      {
        'veterinarioId': c.veterinarioId,
        'fecha': c.fecha,
        'hora': c.hora,
        'duenoUid': uid,
        'citaId': citaId,
      };

  /// Horas ya reservadas de un veterinario en una fecha.
  static Future<Set<String>> horasOcupadas(String vetId, String fecha) async {
    final snap = await _agenda
        .where('veterinarioId', isEqualTo: vetId)
        .where('fecha', isEqualTo: fecha)
        .get();
    return snap.docs.map((d) => d.data()['hora'] as String).toSet();
  }

  // ── Cancelar (dueño o admin) ──────────────────────────────────────────────

  /// Marca la cita como cancelada y libera el horario del veterinario. La
  /// cita se conserva en el historial.
  static Future<void> cancelar(CitaModel c) async {
    final batch = Db.i.batch();
    batch.update(_col(c.duenoUid!).doc(c.id), {'estado': EstadoCita.cancelada.valor});
    if (!c.sinAsignar) {
      batch.delete(_agenda.doc(idAgenda(c.veterinarioId!, c.fecha, c.hora)));
    }
    await batch.commit();
  }

  // ── Asignar veterinario (admin) ───────────────────────────────────────────

  /// Asigna o cambia el veterinario de una cita. Lanza
  /// [OperacionException] si ese veterinario ya tiene ocupado el horario.
  static Future<void> asignar(CitaModel c, UsuarioModel vet) async {
    final citaRef = _col(c.duenoUid!).doc(c.id);
    final nuevo = _agenda.doc(idAgenda(vet.uid!, c.fecha, c.hora));

    await Db.i.runTransaction((tx) async {
      final actual = await tx.get(citaRef);
      if (!actual.exists) {
        throw const OperacionException('La cita ya no existe.');
      }
      final anteriorVet = actual.data()!['veterinarioId'] as String?;
      if (anteriorVet == vet.uid) return;
      if ((await tx.get(nuevo)).exists) throw _ocupado;

      if (anteriorVet != null && anteriorVet.isNotEmpty) {
        tx.delete(_agenda.doc(idAgenda(anteriorVet, c.fecha, c.hora)));
      }
      tx.set(nuevo, {
        'veterinarioId': vet.uid,
        'fecha': c.fecha,
        'hora': c.hora,
        'duenoUid': c.duenoUid,
        'citaId': c.id,
      });
      tx.update(citaRef, {
        'veterinarioId': vet.uid,
        'veterinarioNombre': vet.nombreCompleto,
      });
    });
  }

  // ── Atender (veterinario) ─────────────────────────────────────────────────

  static Future<void> marcarAtendida(CitaModel c, {String notas = ''}) =>
      _col(c.duenoUid!).doc(c.id).update({
        'estado': EstadoCita.atendida.valor,
        'notas': notas.trim(),
      });

  /// Deshace "atendida" si se marcó por error.
  static Future<void> reabrir(CitaModel c) => _col(c.duenoUid!)
      .doc(c.id)
      .update({'estado': EstadoCita.pendiente.valor});

  // ── Streams ───────────────────────────────────────────────────────────────

  /// Citas de un usuario.
  static Stream<List<CitaModel>> stream(String uid) =>
      _col(uid).snapshots().map((s) => s.docs.map(_desde).toList());

  /// Citas asignadas a un veterinario, de todos los usuarios.
  /// Requiere el índice de grupo de colecciones de `firestore.indexes.json`.
  static Stream<List<CitaModel>> streamPorVeterinario(String vetId) => Db.i
      .collectionGroup('citas')
      .where('veterinarioId', isEqualTo: vetId)
      .snapshots()
      .map((s) => s.docs.map(_desde).toList());

  /// Todas las citas (admin). Se filtra en el cliente para incluir también
  /// las citas antiguas que no tienen el campo `veterinarioId`.
  static Stream<List<CitaModel>> streamTodas() => Db.i
      .collectionGroup('citas')
      .snapshots()
      .map((s) => s.docs.map(_desde).toList());
}
