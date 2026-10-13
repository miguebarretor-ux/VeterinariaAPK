import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'repositories/producto_repository.dart';
import 'repositories/carrito_repository.dart';

class TiendaPage extends StatefulWidget {
  final UsuarioModel usuario;
  const TiendaPage({super.key, required this.usuario});

  @override
  State<TiendaPage> createState() => _TiendaPageState();
}

class _TiendaPageState extends State<TiendaPage> {
  List<ProductoModel> _productos = [];
  List<CarritoItemModel> _carrito = [];
  StreamSubscription<List<ProductoModel>>? _subP;
  StreamSubscription<List<CarritoItemModel>>? _subC;

  @override
  void initState() {
    super.initState();
    _subP = ProductoRepository.streamActivos().listen((lista) {
      if (mounted) setState(() => _productos = lista);
    });
    _subC = CarritoRepository.stream(widget.usuario.uid!).listen((items) {
      if (mounted) setState(() => _carrito = items);
    });
  }

  @override
  void dispose() {
    _subP?.cancel();
    _subC?.cancel();
    super.dispose();
  }

  int get _totalItems => _carrito.fold(0, (acc, i) => acc + i.cantidad);

  double get _totalPrecio => _carrito.fold(0.0, (acc, i) => acc + i.subtotal);

  void _agregar(ProductoModel p) =>
      CarritoRepository.agregar(widget.usuario.uid!, p);

  void _abrirCarrito() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CarritoSheet(uid: widget.usuario.uid!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      appBar: AppBar(
        title: const Text('Tienda'),
        backgroundColor: HuellitasTheme.arena,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          if (_totalItems > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _abrirCarrito,
                icon: const Icon(Icons.shopping_cart_outlined,
                    size: 20, color: HuellitasTheme.ink),
                label: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: HuellitasTheme.lavanda,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$_totalItems',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: HuellitasTheme.ink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _totalItems > 0
          ? FloatingActionButton.extended(
              onPressed: _abrirCarrito,
              backgroundColor: HuellitasTheme.lavanda,
              foregroundColor: HuellitasTheme.ink,
              elevation: 0,
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: Text(
                'Ver carrito · ${_fmtPrecio(_totalPrecio)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      body: _productos.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                const SectionLabel('Productos disponibles'),
                const SizedBox(height: 12),
                ..._productos.map((p) => _ProductoCard(
                      producto: p,
                      cantidadEnCarrito: _carrito
                          .where((i) => i.productoId == p.id)
                          .fold(0, (acc, i) => acc + i.cantidad),
                      onAgregar: () => _agregar(p),
                    )),
              ],
            ),
    );
  }
}

String _fmtPrecio(double p) {
  if (p == 0) return '\$0';
  final s = p.toStringAsFixed(0);
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '\$${buf.toString()}';
}

// ── TARJETA PRODUCTO (vista usuario) ─────────────────────────────────────────

class _ProductoCard extends StatelessWidget {
  final ProductoModel producto;
  final int cantidadEnCarrito;
  final VoidCallback onAgregar;

  const _ProductoCard({
    required this.producto,
    required this.cantidadEnCarrito,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: HuellitasTheme.cardBox(),
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: HuellitasTheme.lavanda,
              borderRadius: BorderRadius.circular(22),
              boxShadow: HuellitasTheme.claySm,
            ),
            child: const Icon(Icons.storefront_outlined,
                size: 22, color: HuellitasTheme.ink),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                if (producto.descripcion.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    producto.descripcion,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HuellitasTheme.inkSoft, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(children: [
                  Text(
                    _fmtPrecio(producto.precio),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: HuellitasTheme.lavanda,
                    ),
                  ),
                  if (producto.stock >= 1 && producto.stock <= 5) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: HuellitasTheme.lima,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${producto.stock} disp.',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: HuellitasTheme.ink),
                      ),
                    ),
                  ],
                ]),
              ],
            ),
          ),
          if (cantidadEnCarrito > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: HuellitasTheme.lavanda,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$cantidadEnCarrito',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: HuellitasTheme.ink),
              ),
            )
          else
            IconButton(
              onPressed: onAgregar,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
              color: HuellitasTheme.ink,
            ),
        ],
      ),
    );
  }
}

// ── HOJA CARRITO (reactiva) ────────────────────────────────────────────────────

class _CarritoSheet extends StatefulWidget {
  final String uid;
  const _CarritoSheet({required this.uid});

  @override
  State<_CarritoSheet> createState() => _CarritoSheetState();
}

class _CarritoSheetState extends State<_CarritoSheet> {
  List<CarritoItemModel> _carrito = [];
  StreamSubscription<List<CarritoItemModel>>? _sub;
  bool _confirmando = false;

  @override
  void initState() {
    super.initState();
    _sub = CarritoRepository.stream(widget.uid).listen((items) {
      if (mounted) setState(() => _carrito = items);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  double get _total => _carrito.fold(0.0, (acc, i) => acc + i.subtotal);

  Future<void> _confirmar() async {
    if (_confirmando || _carrito.isEmpty) return;
    setState(() => _confirmando = true);
    await CarritoRepository.confirmarPedido(widget.uid, _carrito);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('¡Pedido confirmado! Pronto lo recibirás.',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: HuellitasTheme.lima,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ));
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: HuellitasTheme.lavanda,
                  borderRadius: BorderRadius.circular(999)),
            ),
          ),
          const SizedBox(height: 18),
          Text('Mi carrito',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          if (_carrito.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'El carrito está vacío',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: HuellitasTheme.inkSoft),
                textAlign: TextAlign.center,
              ),
            )
          else ...[
            ..._carrito.map((item) => _CarritoRow(item: item, uid: widget.uid)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HuellitasTheme.arena,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total',
                      style: Theme.of(context).textTheme.labelLarge),
                  Text(
                    _fmtPrecio(_total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: HuellitasTheme.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ClayButton(
              child: ElevatedButton(
                onPressed: _confirmando ? null : _confirmar,
                child: _confirmando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: HuellitasTheme.ink),
                      )
                    : const Text('Confirmar pedido'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CarritoRow extends StatelessWidget {
  final CarritoItemModel item;
  final String uid;
  const _CarritoRow({required this.item, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nombre,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(_fmtPrecio(item.precio),
                    style: const TextStyle(
                        fontSize: 12, color: HuellitasTheme.inkSoft)),
              ],
            ),
          ),
          _QtyBtn(
            icon: Icons.remove,
            onPressed: () =>
                CarritoRepository.decrementar(uid, item.productoId),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${item.cantidad}',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          _QtyBtn(
            icon: Icons.add,
            onPressed: () => CarritoRepository.agregar(
              uid,
              ProductoModel(
                  id: item.productoId,
                  nombre: item.nombre,
                  precio: item.precio),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _fmtPrecio(item.subtotal),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: HuellitasTheme.lavanda),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _QtyBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: HuellitasTheme.arena,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, size: 16, color: HuellitasTheme.ink),
      ),
    );
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
                color: HuellitasTheme.lavanda,
                borderRadius: BorderRadius.circular(36),
                boxShadow: HuellitasTheme.claySm,
              ),
              child: const Icon(Icons.storefront_outlined,
                  size: 36, color: HuellitasTheme.ink),
            ),
            const SizedBox(height: 20),
            Text('Tienda sin productos',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'El administrador está preparando\nel catálogo. ¡Vuelve pronto!',
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
