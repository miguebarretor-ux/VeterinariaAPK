import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'repositories/producto_repository.dart';
import 'repositories/carrito_repository.dart';
import 'pedidos.dart';

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

  Future<void> _agregar(ProductoModel p) async {
    try {
      await CarritoRepository.agregar(widget.usuario.uid!, p);
    } catch (e) {
      if (mounted) mostrarAviso(context, mensajeDeError(e), error: true);
    }
  }

  void _verPedidos() => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PedidosPage(uid: widget.usuario.uid!)),
      );

  void _abrirCarrito() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CarritoSheet(usuario: widget.usuario),
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
          IconButton(
            onPressed: _verPedidos,
            tooltip: 'Mis pedidos',
            icon: const Icon(Icons.receipt_long_outlined,
                color: HuellitasTheme.ink),
          ),
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
                Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 4,
                    children: [
                  Text(
                    _fmtPrecio(producto.precio),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: HuellitasTheme.lavanda,
                    ),
                  ),
                  if (producto.estado == EstadoProducto.agotado) ...[
                    const SizedBox(width: 8),
                    const EstadoChip('Agotado', color: HuellitasTheme.coral),
                  ] else if (producto.estado == EstadoProducto.stockBajo) ...[
                    const SizedBox(width: 8),
                    EstadoChip(
                      producto.stock == 1
                          ? 'Queda 1'
                          : 'Quedan ${producto.stock}',
                      color: HuellitasTheme.lima,
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
            ),
          // Se puede seguir agregando desde la lista, hasta agotar el stock.
          IconButton(
            onPressed: producto.sePuedeComprar &&
                    cantidadEnCarrito < producto.stock
                ? onAgregar
                : null,
            tooltip: !producto.sePuedeComprar
                ? 'Agotado'
                : cantidadEnCarrito >= producto.stock
                    ? 'No hay más unidades'
                    : 'Agregar al carrito',
            icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
            color: HuellitasTheme.ink,
            disabledColor: HuellitasTheme.inkSoft.withAlpha(90),
          ),
        ],
      ),
    );
  }
}

// ── HOJA CARRITO (reactiva) ────────────────────────────────────────────────────

class _CarritoSheet extends StatefulWidget {
  final UsuarioModel usuario;
  const _CarritoSheet({required this.usuario});

  @override
  State<_CarritoSheet> createState() => _CarritoSheetState();
}

class _CarritoSheetState extends State<_CarritoSheet> {
  List<CarritoItemModel> _carrito = [];
  // Catálogo vigente: precio y stock actuales de cada producto del carrito.
  Map<String, ProductoModel> _productos = {};
  StreamSubscription<List<CarritoItemModel>>? _sub;
  StreamSubscription<List<ProductoModel>>? _subP;
  bool _confirmando = false;
  String? _error;

  String get _uid => widget.usuario.uid!;

  @override
  void initState() {
    super.initState();
    _sub = CarritoRepository.stream(_uid).listen((items) {
      if (mounted) setState(() => _carrito = items);
    });
    _subP = ProductoRepository.stream().listen((lista) {
      if (mounted) {
        setState(() => _productos = {for (final p in lista) p.id!: p});
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _subP?.cancel();
    super.dispose();
  }

  /// Precio vigente de una línea (el del catálogo, si ya cargó).
  double _precio(CarritoItemModel i) =>
      _productos[i.productoId]?.precio ?? i.precio;

  double get _total =>
      _carrito.fold(0.0, (acc, i) => acc + _precio(i) * i.cantidad);

  /// Por qué una línea no se puede comprar tal como está, o null si está bien.
  String? _problema(CarritoItemModel i) {
    if (_productos.isEmpty) return null; // catálogo aún cargando
    final p = _productos[i.productoId];
    if (p == null || !p.activo) return 'Ya no está disponible';
    if (p.stock == 0) return 'Agotado';
    if (p.stock < i.cantidad) return 'Solo quedan ${p.stock}';
    return null;
  }

  bool get _hayProblemas => _carrito.any((i) => _problema(i) != null);

  Future<void> _mas(CarritoItemModel i) async {
    final p = _productos[i.productoId];
    if (p == null) return;
    try {
      await CarritoRepository.agregar(_uid, p);
    } catch (e) {
      if (mounted) setState(() => _error = mensajeDeError(e));
    }
  }

  Future<void> _confirmar() async {
    if (_confirmando || _carrito.isEmpty) return;
    setState(() {
      _confirmando = true;
      _error = null;
    });
    try {
      await CarritoRepository.confirmarPedido(
        _uid,
        _carrito,
        clienteNombre: widget.usuario.nombreCompleto,
      );
      if (!mounted) return;
      Navigator.pop(context);
      mostrarAviso(context,
          'Pedido confirmado. Sigue su estado en "Mis pedidos".');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _confirmando = false;
        _error = mensajeDeError(e);
      });
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
            ..._carrito.map((item) => _CarritoRow(
                  item: item,
                  precio: _precio(item),
                  problema: _problema(item),
                  puedeSumar: (_productos[item.productoId]?.sePuedeComprar ??
                          false) &&
                      item.cantidad < (_productos[item.productoId]?.stock ?? 0),
                  onMenos: () =>
                      CarritoRepository.decrementar(_uid, item.productoId),
                  onMas: () => _mas(item),
                  onQuitar: () =>
                      CarritoRepository.eliminar(_uid, item.productoId),
                )),
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
            const SizedBox(height: 8),
            Text(
              'Recoges y pagas tu pedido en la clínica.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: HuellitasTheme.inkSoft, fontSize: 12),
            ),
            const SizedBox(height: 14),
            if (_error != null) ...[
              AvisoEnLinea(_error!),
              const SizedBox(height: 12),
            ],
            ClayButton(
              child: ElevatedButton(
                // Con una línea agotada o sin stock suficiente no se confirma:
                // primero hay que ajustarla.
                onPressed:
                    _confirmando || _hayProblemas ? null : _confirmar,
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
  final double precio;
  final String? problema;
  final bool puedeSumar;
  final VoidCallback onMenos;
  final VoidCallback onMas;
  final VoidCallback onQuitar;
  const _CarritoRow({
    required this.item,
    required this.precio,
    required this.problema,
    required this.puedeSumar,
    required this.onMenos,
    required this.onMas,
    required this.onQuitar,
  });

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
                Text(fmtPrecio(precio),
                    style: const TextStyle(
                        fontSize: 12, color: HuellitasTheme.inkSoft)),
                if (problema != null) ...[
                  const SizedBox(height: 4),
                  Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                    EstadoChip(problema!, color: HuellitasTheme.coral),
                    TextButton(
                      onPressed: onQuitar,
                      style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact),
                      child: const Text('Quitar'),
                    ),
                  ]),
                ],
              ],
            ),
          ),
          _QtyBtn(icon: Icons.remove, onPressed: onMenos),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${item.cantidad}',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          _QtyBtn(icon: Icons.add, onPressed: puedeSumar ? onMas : null),
          const SizedBox(width: 10),
          Text(
            fmtPrecio(precio * item.cantidad),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: HuellitasTheme.ink),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed; // null = desactivado
  const _QtyBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      tooltip: icon == Icons.add ? 'Una más' : 'Una menos',
      color: HuellitasTheme.ink,
      disabledColor: HuellitasTheme.inkSoft.withAlpha(90),
      style: IconButton.styleFrom(
        backgroundColor: HuellitasTheme.arena,
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
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
