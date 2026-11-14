import 'package:flutter/material.dart';

// Si tienes el paquete google_fonts, descomenta esta línea:
// import 'package:google_fonts/google_fonts.dart';

/// Tokens de diseño de Huellitas Veterinaria.
/// Lenguaje visual: Claymorphism con pasteles complementarios.
///
/// Fuente web de referencia: huellitas_tokens.css
///
/// Uso:
///   MaterialApp(
///     theme: HuellitasTheme.theme,
///     ...
///   )
class HuellitasTheme {

  // ─── COLORES ────────────────────────────────────────────────────────────────

  static const Color ink      = Color(0xFF3A3350); // --color-ink      (texto)
  static const Color inkSoft  = Color(0xFF6E6688); // --color-ink-soft (labels)
  static const Color arena    = Color(0xFFF7F3EE); // --color-arena    (fondo)
  static const Color leche    = Color(0xFFFFFDFA); // --color-leche    (tarjetas)
  static const Color lavanda  = Color(0xFFC9BCEB); // --color-lavanda  (primario)
  static const Color lima     = Color(0xFFE5E9A8); // --color-lima     (CTA)
  static const Color coral    = Color(0xFFF49E8C); // --color-coral    (error)
  static const Color menta    = Color(0xFFA9D9C6); // --color-menta    (éxito)

  // ─── SOMBRAS CLAYMORPHISM ────────────────────────────────────────────────────
  //
  // NOTA: Flutter no soporta inset box-shadow nativamente con BoxShadow.
  // Los niveles 0 (clay-in) se simulan con fillColor más oscuro en los campos.
  // Para el efecto completo, usar CustomPainter en componentes clave.

  /// Nivel 1 — Chip, icono (--shadow-clay-sm)
  static List<BoxShadow> get claySm => [
    BoxShadow(
      offset: const Offset(7, 8),
      blurRadius: 16,
      color: ink.withAlpha(31),       // 0.12 * 255 ≈ 31
    ),
    BoxShadow(
      offset: const Offset(-4, -5),
      blurRadius: 12,
      color: Colors.white.withAlpha(230), // 0.90 * 255 ≈ 230
    ),
  ];

  /// Nivel 2 — Tarjeta estándar (--shadow-clay)
  static List<BoxShadow> get clay => [
    BoxShadow(
      offset: const Offset(14, 16),
      blurRadius: 30,
      color: ink.withAlpha(33),       // 0.13 * 255 ≈ 33
    ),
    BoxShadow(
      offset: const Offset(-8, -10),
      blurRadius: 22,
      color: Colors.white.withAlpha(230), // 0.90 * 255 ≈ 230
    ),
  ];

  /// Nivel 3 — Modal, hero (--shadow-clay-xl)
  static List<BoxShadow> get clayXl => [
    BoxShadow(
      offset: const Offset(22, 26),
      blurRadius: 48,
      color: ink.withAlpha(41),       // 0.16 * 255 ≈ 41
    ),
    BoxShadow(
      offset: const Offset(-12, -14),
      blurRadius: 32,
      color: Colors.white.withAlpha(242), // 0.95 * 255 ≈ 242
    ),
  ];

  // ─── DECORACIONES REUTILIZABLES ──────────────────────────────────────────────

  /// Tarjeta blanca con sombra clay
  static BoxDecoration cardBox({Color? color, double radius = 44}) => BoxDecoration(
    color: color ?? leche,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: clay,
  );

  /// Chip o pastilla con sombra pequeña
  static BoxDecoration chipBox({Color? color, double radius = 999}) => BoxDecoration(
    color: color ?? leche,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: claySm,
  );

  // ─── DECORACIÓN DE CAMPOS ────────────────────────────────────────────────────

  static InputDecoration field(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: inkSoft,
    ),
    hintStyle: TextStyle(
      fontSize: 15,
      color: inkSoft.withAlpha(153), // 0.6 * 255 ≈ 153
    ),
    filled: true,
    fillColor: arena,
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: lavanda, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: coral, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: coral, width: 2),
    ),
    errorStyle: const TextStyle(
      color: coral,
      fontWeight: FontWeight.w700,
      fontSize: 13,
    ),
  );

  // ─── THEMADATA ───────────────────────────────────────────────────────────────

  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: arena,
    colorScheme: const ColorScheme.light(
      primary:    lavanda,
      secondary:  lima,
      error:      coral,
      surface:    leche,
      onPrimary:  ink,
      onSecondary: ink,
      onSurface:  ink,
      onError:    leche,
    ),

    // AppBar sin sombra, misma arena que el fondo
    appBarTheme: const AppBarTheme(
      backgroundColor: arena,
      foregroundColor: ink,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: ink,
      ),
    ),

    // Campos de texto con estilo hundido (clay-in aproximado)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: arena,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: inkSoft,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: lavanda, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: coral, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: coral, width: 2),
      ),
      errorStyle: const TextStyle(color: coral, fontWeight: FontWeight.w700),
    ),

    // Botón primario — fondo lima, texto ink, altura mínima 52px
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lima,
        foregroundColor: ink,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
        elevation: 0,
      ),
    ),

    // Switch con colores del sistema
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? ink : inkSoft,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? lima : arena,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    // Escala tipográfica — equivale a la escala del CSS
    // (Si usas google_fonts, reemplaza TextStyle con GoogleFonts.bitter/nunito)
    textTheme: const TextTheme(
      // --text-display: Bitter 800 / 40px
      displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: ink),
      // --text-title: Bitter 700 / 28px
      titleLarge:   TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: ink),
      // --text-subtitle: Bitter 600 / 20px
      titleMedium:  TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: ink),
      // --text-body: Nunito 400 / 17px
      bodyLarge:    TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: ink, height: 1.6),
      bodyMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: ink),
      // --text-label: Nunito 700 / 15px
      labelLarge:   TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ink),
      // --text-micro: Nunito 700 / 12px
      labelSmall:   TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: inkSoft, letterSpacing: 2.16),
    ),
  );
}
