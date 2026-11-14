import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'repositories/producto_repository.dart';

class AdminTiendaPage extends StatefulWidget {
  const AdminTiendaPage({super.key});

  @override
  State<AdminTiendaPage> createState() => _AdminTiendaPageState();
}

class _AdminTiendaPageState extends State<AdminTiendaPage> {
  List<ProductoModel> _productos = [];
  bool _cargando = true;
  StreamSubscription<List<ProductoModel>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = ProductoRepository.stream().listen(
      (lista) {
        if (mounted) setState(() { _productos = lista; _cargando = false; });
      },
      onError: (_) {
        if (mounted) setState(() => _cargando = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _nuevo() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _ProductoSheet(
            onGuardar: (p) async {
              await ProductoRepository.agregar(p);
            },
            onError: _mostrarError,
          ),
        ),
      );

  void _editar(ProductoModel p) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _ProductoSheet(
            producto: p,
            onGuardar: (updated) async {
              await ProductoRepository.actualizar(updated);
            },
            onError: _mostrarError,
          ),
        ),
      );

  void _mostrarError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error al guardar: $e',
          style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: HuellitasTheme.coral,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(
          child: CircularProgressIndicator(color: HuellitasTheme.lavanda));
    }

    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      body: _productos.isEmpty ? _emptyState(context) : _lista(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevo,
        backgroundColor: HuellitasTheme.ink,
        icon: const Icon(Icons.add_shopping_cart_outlined,
            color: HuellitasTheme.leche),
        label: const Text(
          'Nuevo producto',
          style: TextStyle(
              color: HuellitasTheme.leche, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _lista(BuildContext context) {
    final activos = _productos.where((p) => p.activo).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Container(
          decoration:
              HuellitasTheme.cardBox(color: HuellitasTheme.lavanda),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.storefront_outlined,
                  color: HuellitasTheme.ink, size: 28),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_productos.length}',
                      style: Theme.of(context).textTheme.displayLarge),
                  Text(
                    '$activos activo${activos == 1 ? '' : 's'} · ${_productos.length} total',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: HuellitasTheme.inkSoft),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Catálogo de productos'),
        const SizedBox(height: 12),
        ..._productos.map((p) => _ProductoCard(
              producto: p,
              onEditar: () => _editar(p),
              onToggle: (val) =>
                  ProductoRepository.toggleActivo(p.id!, val),
              onEliminar: () => ProductoRepository.eliminar(p.id!),
            )),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
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
            Text('Sin productos en la tienda',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Pulsa el botón para agregar\nel primer producto.',
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

// ── TARJETA PRODUCTO ──────────────────────────────────────────────────────────

class _ProductoCard extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback onEditar;
  final void Function(bool) onToggle;
  final VoidCallback onEliminar;

  const _ProductoCard({
    required this.producto,
    required this.onEditar,
    required this.onToggle,
    required this.onEliminar,
  });

  String _fmt(double p) {
    if (p == 0) return 'Sin precio';
    final s = p.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '\$${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: HuellitasTheme.cardBox(
        color: producto.activo ? HuellitasTheme.leche : HuellitasTheme.arena,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: producto.activo
                            ? HuellitasTheme.ink
                            : HuellitasTheme.inkSoft,
                      ),
                ),
                const SizedBox(height: 3),
                Row(children: [
                  Text(
                    _fmt(producto.precio),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: producto.activo
                          ? HuellitasTheme.lavanda
                          : HuellitasTheme.inkSoft,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: producto.stock > 0
                          ? HuellitasTheme.lima
                          : HuellitasTheme.coral,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Stock: ${producto.stock}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: HuellitasTheme.ink),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          Switch(
            value: producto.activo,
            onChanged: onToggle,
            activeThumbColor: HuellitasTheme.lavanda,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: HuellitasTheme.inkSoft,
            onPressed: onEditar,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: HuellitasTheme.coral,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                title: const Text('Eliminar producto'),
                content: Text('¿Eliminar "${producto.nombre}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onEliminar();
                    },
                    child: const Text('Eliminar',
                        style: TextStyle(color: HuellitasTheme.coral)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── FORMULARIO PRODUCTO ───────────────────────────────────────────────────────

class _ProductoSheet extends StatefulWidget {
  final ProductoModel? producto;
  final Future<void> Function(ProductoModel) onGuardar;
  final void Function(Object) onError;
  const _ProductoSheet({
    this.producto,
    required this.onGuardar,
    required this.onError,
  });

  @override
  State<_ProductoSheet> createState() => _ProductoSheetState();
}

class _ProductoSheetState extends State<_ProductoSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late String _descripcion;
  late double _precio;
  late int _stock;

  @override
  void initState() {
    super.initState();
    _nombre = widget.producto?.nombre ?? '';
    _descripcion = widget.producto?.descripcion ?? '';
    _precio = widget.producto?.precio ?? 0;
    _stock = widget.producto?.stock ?? 0;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    try {
      await widget.onGuardar(ProductoModel(
        id: widget.producto?.id,
        nombre: _nombre,
        descripcion: _descripcion,
        precio: _precio,
        stock: _stock,
        activo: widget.producto?.activo ?? true,
      ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      widget.onError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.producto != null;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: HuellitasTheme.leche,
        borderRadius: BorderRadius.circular(36),
        boxShadow: HuellitasTheme.clayXl,
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Form(
        key: _formKey,
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
            Text(esEdicion ? 'Editar producto' : 'Nuevo producto',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _nombre,
              decoration: HuellitasTheme.field('Nombre del producto'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              onSaved: (v) => _nombre = v!.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _descripcion,
              decoration:
                  HuellitasTheme.field('Descripción', hint: 'Opcional'),
              textCapitalization: TextCapitalization.sentences,
              onSaved: (v) => _descripcion = v?.trim() ?? '',
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  initialValue: _precio > 0 ? _precio.toStringAsFixed(0) : '',
                  decoration:
                      HuellitasTheme.field('Precio (COP)', hint: '35000'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                  onSaved: (v) => _precio = double.tryParse(v ?? '') ?? 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: _stock > 0 ? _stock.toString() : '',
                  decoration: HuellitasTheme.field('Stock', hint: '10'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                  onSaved: (v) => _stock = int.tryParse(v ?? '') ?? 0,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            ClayButton(
              child: ElevatedButton(
                onPressed: () => _guardar(),
                child:
                    Text(esEdicion ? 'Guardar cambios' : 'Crear producto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
