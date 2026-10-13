import 'package:cloud_firestore/cloud_firestore.dart';
import '../mascota_model.dart';

class ProductoRepository {
  static final _col = FirebaseFirestore.instance.collection('productos');

  static Stream<List<ProductoModel>> stream() =>
      _col.orderBy('nombre').snapshots().map((s) => s.docs
          .map((d) => ProductoModel.fromFirestore(d.id, d.data()))
          .toList());

  static Stream<List<ProductoModel>> streamActivos() =>
      _col
          .where('activo', isEqualTo: true)
          .orderBy('nombre')
          .snapshots()
          .map((s) => s.docs
              .map((d) => ProductoModel.fromFirestore(d.id, d.data()))
              .toList());

  static Future<void> agregar(ProductoModel p) => _col.add(p.toFirestore());

  static Future<void> actualizar(ProductoModel p) =>
      _col.doc(p.id).update(p.toFirestore());

  static Future<void> toggleActivo(String id, bool activo) =>
      _col.doc(id).update({'activo': activo});

  static Future<void> actualizarStock(String id, int stock) =>
      _col.doc(id).update({'stock': stock});

  static Future<void> eliminar(String id) => _col.doc(id).delete();
}
