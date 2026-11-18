import 'package:flutter/material.dart';
import 'huellitas_theme.dart';
import 'mascota_model.dart';

/// Etiqueta de sección con estilo claymorphism.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: HuellitasTheme.inkSoft,
      ),
    );
  }
}

/// Envuelve cualquier [ElevatedButton] con la sombra claymorphism estándar.
class ClayButton extends StatelessWidget {
  final Widget child;
  const ClayButton({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: HuellitasTheme.claySm,
      ),
      child: child,
    );
  }
}

/// Enlace de navegación entre pantallas de autenticación.
class AuthLink extends StatelessWidget {
  final String prefixText;
  final String linkText;
  final VoidCallback onTap;
  const AuthLink({
    super.key,
    required this.prefixText,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 15, color: HuellitasTheme.inkSoft),
            children: [
              TextSpan(text: prefixText),
              TextSpan(
                text: linkText,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: HuellitasTheme.ink,
                  decoration: TextDecoration.underline,
                  decorationColor: HuellitasTheme.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Campos de formulario de mascota reutilizables (registro y edición).
///
/// Muta directamente [mascota] a través de [onSaved] de cada campo.
/// Pasar un [MascotaModel] con valores existentes pre-rellena los campos.
class MascotaFormFields extends StatefulWidget {
  final MascotaModel mascota;
  const MascotaFormFields({super.key, required this.mascota});

  @override
  State<MascotaFormFields> createState() => _MascotaFormFieldsState();
}

class _MascotaFormFieldsState extends State<MascotaFormFields> {
  @override
  Widget build(BuildContext context) {
    final m = widget.mascota;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: m.nombre,
          decoration: HuellitasTheme.field('Nombre de la mascota'),
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
          onSaved: (v) => m.nombre = v!.trim(),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: m.tipo,
          decoration: HuellitasTheme.field('Tipo'),
          items: ['Perro', 'Gato', 'Otro']
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => m.tipo = v!),
          onSaved: (v) => m.tipo = v ?? 'Perro',
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: m.edad > 0 ? '${m.edad}' : null,
          decoration: HuellitasTheme.field('Edad (años)'),
          keyboardType: TextInputType.number,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa la edad' : null,
          onSaved: (v) => m.edad = int.tryParse(v ?? '') ?? 0,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: m.peso != null ? '${m.peso}' : null,
          decoration: HuellitasTheme.field('Peso en kg', hint: 'Opcional'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSaved: (v) => m.peso = double.tryParse(v ?? ''),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: m.raza,
          decoration: HuellitasTheme.field('Raza'),
          textCapitalization: TextCapitalization.words,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Ingresa la raza o cruce'
              : null,
          onSaved: (v) => m.raza = v!.trim(),
        ),
      ],
    );
  }
}

// ── UTILIDADES COMPARTIDAS ────────────────────────────────────────────────────

/// Precio en pesos con separador de miles: 45000 → "$45.000".
String fmtPrecio(double p) {
  final s = p.toStringAsFixed(0);
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '\$${buf.toString()}';
}

/// Aviso breve en la parte inferior. Con [error] usa el color de alerta.
void mostrarAviso(BuildContext context, String mensaje, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(
        mensaje,
        style: const TextStyle(
            fontWeight: FontWeight.w700, color: HuellitasTheme.ink),
      ),
      backgroundColor: error ? HuellitasTheme.coral : HuellitasTheme.menta,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
}

/// Mensaje apto para mostrar a partir de cualquier error.
String mensajeDeError(Object e) {
  final texto = e.toString();
  if (texto.contains('permission-denied')) {
    return 'No tienes permiso para hacer esto.';
  }
  if (texto.contains('unavailable') || texto.contains('network')) {
    return 'Sin conexión. Revisa tu internet e inténtalo de nuevo.';
  }
  // OperacionException ya trae un mensaje pensado para la persona.
  return e is Exception && !texto.startsWith('[')
      ? texto.replaceFirst('Exception: ', '')
      : 'Algo salió mal. Inténtalo de nuevo.';
}

/// Pastilla pequeña para mostrar un estado (cita, pedido, stock).
class EstadoChip extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData? icono;
  const EstadoChip(this.texto, {super.key, required this.color, this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 12, color: HuellitasTheme.ink),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: HuellitasTheme.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mensaje de error dentro de un formulario u hoja.
class AvisoEnLinea extends StatelessWidget {
  final String mensaje;
  const AvisoEnLinea(this.mensaje, {super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
        decoration: BoxDecoration(
          color: HuellitasTheme.coral.withAlpha(60),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HuellitasTheme.coral, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 18, color: HuellitasTheme.ink),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: HuellitasTheme.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado vacío o de error a pantalla completa.
class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String detalle;
  final Color color;
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.color = HuellitasTheme.lavanda,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(36),
                boxShadow: HuellitasTheme.claySm,
              ),
              child: Icon(icono, size: 36, color: HuellitasTheme.ink),
            ),
            const SizedBox(height: 20),
            Text(titulo,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              detalle,
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

/// Color de la pastilla según el estado de una cita.
Color colorEstadoCita(EstadoCita e) => switch (e) {
      EstadoCita.pendiente => HuellitasTheme.lavanda,
      EstadoCita.atendida => HuellitasTheme.menta,
      EstadoCita.cancelada => HuellitasTheme.coral,
    };

/// Color de la pastilla según el estado de un pedido.
Color colorEstadoPedido(EstadoPedido e) => switch (e) {
      EstadoPedido.pendiente => HuellitasTheme.lima,
      EstadoPedido.listo => HuellitasTheme.lavanda,
      EstadoPedido.entregado => HuellitasTheme.menta,
      EstadoPedido.cancelado => HuellitasTheme.coral,
    };
