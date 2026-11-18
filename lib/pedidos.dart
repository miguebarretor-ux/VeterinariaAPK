import 'dart:async';
import 'package:flutter/material.dart';
import 'mascota_model.dart';
import 'huellitas_theme.dart';
import 'widgets.dart';
import 'repositories/carrito_repository.dart';

/// Pedidos de la tienda.
///
/// Con [uid] muestra el historial de ese cliente. Sin [uid] es la bandeja
/// del administrador: todos los pedidos, con acciones para avanzar el estado.
class PedidosPage extends StatefulWidget {
  final String? uid;
  const PedidosPage({super.key, this.uid});

  bool get esAdmin => uid == null;

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  List<PedidoModel> _pedidos = [];
  bool _cargando = true;
  String? _error;
  StreamSubscription<List<PedidoModel>>? _sub;

  @override
  void initState() {
    super.initState();
    final stream = widget.esAdmin
        ? CarritoRepository.streamTodosLosPedidos()
        : CarritoRepository.streamPedidos(widget.uid!);
    _sub = stream.listen(
      (lista) {
        if (mounted) {
          setState(() {
            _pedidos = lista;
            _cargando = false;
            _error = null;
          });
        }
      },
      onError: (Object e) {
        if (mounted) {
          setState(() {
            _cargando = false;
            _error = mensajeDeError(e);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _cambiar(PedidoModel p, EstadoPedido nuevo) async {
    if (nuevo == EstadoPedido.cancelado) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Cancelar pedido'),
          content: Text(
              'Se cancelará el pedido de ${p.clienteNombre.isEmpty ? 'este cliente' : p.clienteNombre} '
              'y sus ${p.unidades} unidades volverán al stock. No se puede deshacer.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Volver')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancelar pedido',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    try {
      await CarritoRepository.cambiarEstado(p, nuevo);
      if (mounted) mostrarAviso(context, 'Pedido: ${nuevo.etiqueta.toLowerCase()}.');
    } catch (e) {
      if (mounted) mostrarAviso(context, mensajeDeError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final abiertos = _pedidos
        .where((p) =>
            p.estado == EstadoPedido.pendiente || p.estado == EstadoPedido.listo)
        .toList();
    final cerrados = _pedidos.where((p) => !abiertos.contains(p)).toList();

    return Scaffold(
      backgroundColor: HuellitasTheme.arena,
      appBar: AppBar(
        title: Text(widget.esAdmin ? 'Pedidos' : 'Mis pedidos'),
        backgroundColor: HuellitasTheme.arena,
        elevation: 0,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: HuellitasTheme.lavanda))
          : _error != null
              ? EstadoVacio(
                  icono: Icons.cloud_off_rounded,
                  color: HuellitasTheme.coral,
                  titulo: 'No pudimos cargar los pedidos',
                  detalle: _error!,
                )
              : _pedidos.isEmpty
                  ? EstadoVacio(
                      icono: Icons.receipt_long_outlined,
                      titulo: 'Sin pedidos',
                      detalle: widget.esAdmin
                          ? 'Cuando un cliente compre en la tienda, su pedido aparecerá aquí.'
                          : 'Cuando compres en la tienda, tu pedido aparecerá aquí.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        if (abiertos.isNotEmpty) ...[
                          SectionLabel(widget.esAdmin ? 'Por atender' : 'En curso'),
                          const SizedBox(height: 12),
                          ...abiertos.map(_tarjeta),
                        ],
                        if (cerrados.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const SectionLabel('Historial'),
                          const SizedBox(height: 12),
                          ...cerrados.map(_tarjeta),
                        ],
                      ],
                    ),
    );
  }

  Widget _tarjeta(PedidoModel p) => _PedidoCard(
        pedido: p,
        esAdmin: widget.esAdmin,
        onCambiar: widget.esAdmin ? (e) => _cambiar(p, e) : null,
      );
}

class _PedidoCard extends StatelessWidget {
  final PedidoModel pedido;
  final bool esAdmin;
  final void Function(EstadoPedido)? onCambiar;
  const _PedidoCard({required this.pedido, required this.esAdmin, this.onCambiar});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final suave = textos.bodyMedium
        ?.copyWith(color: HuellitasTheme.inkSoft, fontSize: 13);
    final abierto = pedido.estado == EstadoPedido.pendiente ||
        pedido.estado == EstadoPedido.listo;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: HuellitasTheme.cardBox(
          color: abierto ? HuellitasTheme.leche : HuellitasTheme.arena),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  esAdmin && pedido.clienteNombre.isNotEmpty
                      ? pedido.clienteNombre
                      : 'Pedido del ${pedido.fechaFormateada}',
                  style: textos.labelLarge,
                ),
              ),
              EstadoChip(pedido.estado.etiqueta,
                  color: colorEstadoPedido(pedido.estado)),
            ],
          ),
          if (esAdmin && pedido.clienteNombre.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(pedido.fechaFormateada, style: suave),
          ],
          const SizedBox(height: 10),
          for (final i in pedido.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                      child: Text('${i.cantidad} × ${i.nombre}', style: suave)),
                  Text(fmtPrecio(i.subtotal), style: suave),
                ],
              ),
            ),
          const Divider(color: HuellitasTheme.arena, thickness: 1.5),
          Row(
            children: [
              Expanded(child: Text('Total', style: textos.labelLarge)),
              Text(fmtPrecio(pedido.total),
                  style: textos.labelLarge?.copyWith(fontSize: 16)),
            ],
          ),
          if (!esAdmin && pedido.estado == EstadoPedido.listo) ...[
            const SizedBox(height: 8),
            Text('Ya puedes pasar a recogerlo y pagarlo en la clínica.',
                style: suave),
          ],
          if (onCambiar != null && abierto) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (pedido.estado == EstadoPedido.pendiente)
                  FilledButton(
                    onPressed: () => onCambiar!(EstadoPedido.listo),
                    style: FilledButton.styleFrom(
                      backgroundColor: HuellitasTheme.lima,
                      foregroundColor: HuellitasTheme.ink,
                    ),
                    child: const Text('Marcar listo'),
                  ),
                if (pedido.estado == EstadoPedido.listo)
                  FilledButton(
                    onPressed: () => onCambiar!(EstadoPedido.entregado),
                    style: FilledButton.styleFrom(
                      backgroundColor: HuellitasTheme.lima,
                      foregroundColor: HuellitasTheme.ink,
                    ),
                    child: const Text('Marcar entregado'),
                  ),
                TextButton(
                  onPressed: () => onCambiar!(EstadoPedido.cancelado),
                  child: const Text('Cancelar pedido'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
