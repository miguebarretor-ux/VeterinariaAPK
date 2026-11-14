import 'package:cloud_firestore/cloud_firestore.dart';
import '../mascota_model.dart';

class ProductoRepository {
  static final _col = FirebaseFirestore.instance.collection('productos');

  static Stream<List<ProductoModel>> stream() =>
      _col.orderBy('nombre').snapshots().map((s) => s.docs
          .map((d) => ProductoModel.fromFirestore(d.id, d.data()))
          .toList());

  // Filtra activos en cliente para evitar índice compuesto en Firestore.
  static Stream<List<ProductoModel>> streamActivos() =>
      _col
          .where('activo', isEqualTo: true)
          .snapshots()
          .map((s) {
            final lista = s.docs
                .map((d) => ProductoModel.fromFirestore(d.id, d.data()))
                .toList()
              ..sort((a, b) => a.nombre.compareTo(b.nombre));
            return lista;
          });

  static Future<void> agregar(ProductoModel p) => _col.add(p.toFirestore());

  static Future<void> actualizar(ProductoModel p) =>
      _col.doc(p.id).update(p.toFirestore());

  static Future<void> toggleActivo(String id, bool activo) =>
      _col.doc(id).update({'activo': activo});

  static Future<void> actualizarStock(String id, int stock) =>
      _col.doc(id).update({'stock': stock});

  static Future<void> eliminar(String id) => _col.doc(id).delete();
}
