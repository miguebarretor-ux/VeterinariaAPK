import 'package:cloud_firestore/cloud_firestore.dart';
import '../mascota_model.dart';

class CarritoRepository {
  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('carrito');

  static CollectionReference<Map<String, dynamic>> _pedidosCol(String uid) =>
      FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('pedidos');

  static Stream<List<CarritoItemModel>> stream(String uid) =>
      _col(uid).snapshots().map((s) => s.docs
          .map((d) => CarritoItemModel.fromFirestore(d.id, d.data()))
          .toList());

  static Future<void> agregar(String uid, ProductoModel p) async {
    final doc = _col(uid).doc(p.id);
    final snap = await doc.get();
    if (snap.exists) {
      await doc.update({'cantidad': FieldValue.increment(1)});
    } else {
      await doc.set({
        'nombre': p.nombre,
        'precio': p.precio,
        'cantidad': 1,
      });
    }
  }

  static Future<void> decrementar(String uid, String productoId) async {
    final doc = _col(uid).doc(productoId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final cantidad = (snap.data()!['cantidad'] as num).toInt();
    if (cantidad <= 1) {
      await doc.delete();
    } else {
      await doc.update({'cantidad': FieldValue.increment(-1)});
    }
  }

  static Future<void> eliminar(String uid, String productoId) =>
      _col(uid).doc(productoId).delete();

  static Future<void> vaciar(String uid) async {
    final snap = await _col(uid).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> confirmarPedido(
      String uid, List<CarritoItemModel> items) async {
    final total = items.fold<double>(0, (acc, i) => acc + i.subtotal);
    await _pedidosCol(uid).add({
      'fecha': DateTime.now().toIso8601String(),
      'total': total,
      'estado': 'pendiente',
      'items': items
          .map((i) => {
                'productoId': i.productoId,
                'nombre': i.nombre,
                'precio': i.precio,
                'cantidad': i.cantidad,
              })
          .toList(),
    });
    await vaciar(uid);
  }
}
