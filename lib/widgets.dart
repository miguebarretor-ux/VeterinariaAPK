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
