import 'package:cloud_firestore/cloud_firestore.dart';
import '../mascota_model.dart';
import 'db.dart';

/// Carrito y pedidos de la tienda.
class CarritoRepository {
  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      Db.i.collection('usuarios').doc(uid).collection('carrito');

  static CollectionReference<Map<String, dynamic>> _pedidosCol(String uid) =>
      Db.i.collection('usuarios').doc(uid).collection('pedidos');

  static CollectionReference<Map<String, dynamic>> get _productos =>
      Db.i.collection('productos');

  static Stream<List<CarritoItemModel>> stream(String uid) =>
      _col(uid).snapshots().map((s) => s.docs
          .map((d) => CarritoItemModel.fromFirestore(d.id, d.data()))
          .toList());

  /// Suma una unidad sin pasar del stock disponible. Lanza
  /// [OperacionException] si el producto no se puede comprar o ya no hay más.
  static Future<void> agregar(String uid, ProductoModel p) async {
    if (!p.sePuedeComprar) {
      throw OperacionException('"${p.nombre}" está agotado.');
    }
    final doc = _col(uid).doc(p.id);
    await Db.i.runTransaction((tx) async {
      final snap = await tx.get(doc);
      final actual = snap.exists ? (snap.data()!['cantidad'] as num).toInt() : 0;
      if (actual >= p.stock) {
        throw OperacionException(
            'Solo quedan ${p.stock} de "${p.nombre}" y ya están en tu carrito.');
      }
      tx.set(doc, {
        'nombre': p.nombre,
        'precio': p.precio,
        'cantidad': actual + 1,
      });
    });
  }

  static Future<void> decrementar(String uid, String productoId) async {
    final doc = _col(uid).doc(productoId);
    await Db.i.runTransaction((tx) async {
      final snap = await tx.get(doc);
      if (!snap.exists) return;
      final cantidad = (snap.data()!['cantidad'] as num).toInt();
      if (cantidad <= 1) {
        tx.delete(doc);
      } else {
        tx.update(doc, {'cantidad': cantidad - 1});
      }
    });
  }

  static Future<void> eliminar(String uid, String productoId) =>
      _col(uid).doc(productoId).delete();

  // ── Compra ────────────────────────────────────────────────────────────────

  /// Convierte el carrito en un pedido, en una sola transacción:
  /// comprueba que cada producto siga publicado y con stock suficiente,
  /// toma el precio vigente del catálogo (no el que guardó el carrito),
  /// descuenta el stock, crea el pedido y vacía el carrito.
  ///
  /// Si algo no se puede, lanza [OperacionException] y no cambia nada.
  static Future<PedidoModel> confirmarPedido(
    String uid,
    List<CarritoItemModel> items, {
    String clienteNombre = '',
  }) async {
    if (items.isEmpty) {
      throw const OperacionException('Tu carrito está vacío.');
    }
    final pedidoRef = _pedidosCol(uid).doc();

    return Db.i.runTransaction((tx) async {
      // Todas las lecturas van antes de las escrituras.
      final productos = <String, ProductoModel>{};
      for (final item in items) {
        final snap = await tx.get(_productos.doc(item.productoId));
        if (!snap.exists) {
          throw OperacionException(
              '"${item.nombre}" ya no está en la tienda. Quítalo del carrito.');
        }
        final p = ProductoModel.fromFirestore(snap.id, snap.data()!);
        if (!p.activo) {
          throw OperacionException(
              '"${p.nombre}" ya no está disponible. Quítalo del carrito.');
        }
        if (p.stock < item.cantidad) {
          throw OperacionException(p.stock == 0
              ? '"${p.nombre}" se agotó. Quítalo del carrito.'
              : 'Solo quedan ${p.stock} de "${p.nombre}". Ajusta la cantidad.');
        }
        productos[item.productoId] = p;
      }

      final lineas = [
        for (final item in items)
          CarritoItemModel(
            productoId: item.productoId,
            nombre: productos[item.productoId]!.nombre,
            precio: productos[item.productoId]!.precio,
            cantidad: item.cantidad,
          ),
      ];
      final pedido = PedidoModel(
        id: pedidoRef.id,
        uid: uid,
        clienteNombre: clienteNombre,
        fecha: DateTime.now().toIso8601String(),
        total: lineas.fold<double>(0, (acc, l) => acc + l.subtotal),
        items: lineas,
      );

      for (final item in items) {
        tx.update(_productos.doc(item.productoId), {
          'stock': productos[item.productoId]!.stock - item.cantidad,
        });
        tx.delete(_col(uid).doc(item.productoId));
      }
      tx.set(pedidoRef, pedido.toFirestore());
      return pedido;
    });
  }

  // ── Pedidos ───────────────────────────────────────────────────────────────

  static PedidoModel _pedidoDesde(DocumentSnapshot<Map<String, dynamic>> d) =>
      PedidoModel.fromFirestore(
          d.id, d.reference.parent.parent?.id ?? '', d.data()!);

  static List<PedidoModel> _recientesPrimero(
          QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map(_pedidoDesde).toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));

  /// Pedidos de un usuario, del más reciente al más antiguo.
  static Stream<List<PedidoModel>> streamPedidos(String uid) =>
      _pedidosCol(uid).snapshots().map(_recientesPrimero);

  /// Pedidos de todos los usuarios (admin).
  static Stream<List<PedidoModel>> streamTodosLosPedidos() =>
      Db.i.collectionGroup('pedidos').snapshots().map(_recientesPrimero);

  /// Cambia el estado de un pedido (admin). Al cancelar, las unidades
  /// vuelven al stock.
  static Future<void> cambiarEstado(PedidoModel p, EstadoPedido nuevo) async {
    final ref = _pedidosCol(p.uid).doc(p.id);
    await Db.i.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw const OperacionException('El pedido ya no existe.');
      }
      final actual = EstadoPedido.desde(snap.data()!['estado'] as String?);
      if (actual == nuevo) return;
      if (actual == EstadoPedido.cancelado) {
        throw const OperacionException(
            'Un pedido cancelado no se puede reactivar: su stock ya se devolvió.');
      }

      if (nuevo == EstadoPedido.cancelado) {
        // Lecturas primero; un producto eliminado del catálogo se omite.
        final existentes = <String, int>{};
        for (final item in p.items) {
          final prod = await tx.get(_productos.doc(item.productoId));
          if (prod.exists) {
            existentes[item.productoId] =
                (prod.data()!['stock'] as num?)?.toInt() ?? 0;
          }
        }
        for (final item in p.items) {
          final stock = existentes[item.productoId];
          if (stock != null) {
            tx.update(_productos.doc(item.productoId),
                {'stock': stock + item.cantidad});
          }
        }
      }
      tx.update(ref, {'estado': nuevo.valor});
    });
  }
}
