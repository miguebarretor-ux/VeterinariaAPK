import 'package:flutter/material.dart';
import '../huellitas_theme.dart';

/// Tarjeta color leche con sombra clay de nivel 2.
class ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const ClayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 24),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HuellitasTheme.cardBox(color: color),
      padding: padding,
      child: child,
    );
  }
}

/// Botón primario (lima) con sombra clay. Mientras [cargando] es `true`
/// muestra un indicador y no acepta toques, para evitar envíos dobles.
class ClayButton extends StatelessWidget {
  final String label;
  final String? labelCargando;
  final VoidCallback? onPressed;
  final bool cargando;
  final IconData? icon;

  const ClayButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.labelCargando,
    this.cargando = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final activo = onPressed != null && !cargando;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HuellitasTheme.radiusButton),
        boxShadow: activo ? HuellitasTheme.claySm : const [],
      ),
      child: ElevatedButton(
        onPressed: activo ? onPressed : null,
        child: cargando
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(width: 12),
                  Flexible(child: Text(labelCargando ?? label)),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(label, textAlign: TextAlign.center)),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Selector de una opción entre pocas (2–4), como pastillas lado a lado.
/// Reemplaza al desplegable cuando todas las opciones caben a la vista:
/// se elige con un solo toque y se ven todas las alternativas.
class ClayChoice<T> extends StatelessWidget {
  final List<T> options;
  final T value;
  final ValueChanged<T> onChanged;
  final String Function(T) labelOf;

  /// Nombre del grupo para lectores de pantalla.
  final String semanticLabel;

  const ClayChoice({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.labelOf,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: HuellitasTheme.arena,
          borderRadius: BorderRadius.circular(HuellitasTheme.radiusField),
          border: Border.all(color: HuellitasTheme.bordeCampo, width: 1.2),
        ),
        child: Row(
          children: [
            for (final o in options)
              Expanded(
                child: _Opcion(
                  label: labelOf(o),
                  selected: o == value,
                  onTap: () => onChanged(o),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Opcion extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Opcion({required this.label, required this.selected, required this.onTap});

  @override
  State<_Opcion> createState() => _OpcionState();
}

class _OpcionState extends State<_Opcion> {
  bool _conFoco = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final radius = BorderRadius.circular(HuellitasTheme.radiusField - 4);
    return Semantics(
      // Se anuncia como opción de un grupo excluyente (botón de radio).
      checked: selected,
      inMutuallyExclusiveGroup: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? HuellitasTheme.lavanda : Colors.transparent,
          borderRadius: radius,
          // El foco de teclado es un anillo, no un relleno: así no se
          // confunde con la opción seleccionada.
          border: Border.all(
            color: _conFoco ? HuellitasTheme.lavandaInk : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    offset: const Offset(3, 4),
                    blurRadius: 8,
                    color: HuellitasTheme.ink.withAlpha(36),
                  ),
                ]
              : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            focusColor: Colors.transparent,
            hoverColor: HuellitasTheme.ink.withAlpha(10),
            onFocusChange: (f) => setState(() => _conFoco = f),
            onTap: widget.onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                // Con letra grande el contenido se encoge en vez de partirse
                // en varias líneas.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        const Icon(Icons.check_rounded, size: 18, color: HuellitasTheme.ink),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        widget.label,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                          color: selected ? HuellitasTheme.ink : HuellitasTheme.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Indicador de avance: "PASO 2 DE 3" más una barra segmentada. El título del
/// paso se anuncia a los lectores de pantalla al cambiar.
class PasoProgreso extends StatelessWidget {
  final int actual; // base 0
  final List<String> titulos;

  const PasoProgreso({super.key, required this.actual, required this.titulos});

  @override
  Widget build(BuildContext context) {
    final total = titulos.length;
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Paso ${actual + 1} de $total: ${titulos[actual]}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PASO ${actual + 1} DE $total',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < total; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 8,
                      decoration: BoxDecoration(
                        color: i <= actual
                            ? HuellitasTheme.lavandaInk
                            : HuellitasTheme.borde,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
