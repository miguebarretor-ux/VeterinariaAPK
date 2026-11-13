import 'package:flutter/material.dart';

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
  // ─── TIPOGRAFÍA ─────────────────────────────────────────────────────────────
  // Las fuentes van empaquetadas en assets/fonts (ver pubspec.yaml), así la app
  // se ve igual sin conexión y en las pruebas.

  static const String fontDisplay = 'Bitter'; // --font-display
  static const String fontBody = 'Nunito'; //    --font-body

  // ─── COLORES ────────────────────────────────────────────────────────────────

  static const Color ink = Color(0xFF3A3350); //      --color-ink      (texto)
  static const Color inkSoft = Color(0xFF6E6688); //  --color-ink-soft (labels)
  static const Color arena = Color(0xFFF7F3EE); //    --color-arena    (fondo)
  static const Color leche = Color(0xFFFFFDFA); //    --color-leche    (tarjetas)
  static const Color lavanda = Color(0xFFC9BCEB); //  --color-lavanda  (primario)
  static const Color lima = Color(0xFFE5E9A8); //     --color-lima     (CTA)
  static const Color coral = Color(0xFFF49E8C); //    --color-coral    (error)
  static const Color menta = Color(0xFFA9D9C6); //    --color-menta    (éxito)

  // Variantes "ink" de los pasteles: los pasteles no alcanzan contraste AA como
  // texto ni como indicador de foco sobre arena/leche, así que el texto de
  // error, el foco y el progreso usan estas versiones profundas.

  /// --color-coral-ink · texto de error (5.0:1 sobre arena)
  static const Color coralInk = Color(0xFFB5432E);

  /// --color-lavanda-ink · foco y progreso (4.1:1 sobre arena)
  static const Color lavandaInk = Color(0xFF7A68C4);

  /// --color-menta-ink · texto e iconos de éxito (6.2:1 sobre leche)
  static const Color mentaInk = Color(0xFF2F6B55);

  /// --color-borde · divisores y pista del progreso (decorativo)
  static const Color borde = Color(0xFFDCD5E3);

  /// --color-borde-campo · contorno de campos y selectores (3.4:1 sobre leche)
  static const Color bordeCampo = Color(0xFF8E86A6);

  // ─── RADIOS ─────────────────────────────────────────────────────────────────

  static const double radiusField = 22; //  --radius-field
  static const double radiusButton = 24; // --radius-button
  static const double radiusCard = 36; //   tarjetas en móvil (44 en la web)

  // ─── SOMBRAS CLAYMORPHISM ────────────────────────────────────────────────────
  //
  // NOTA: Flutter no soporta inset box-shadow con BoxShadow. El nivel 0
  // (clay-in) se aproxima con campos color arena hundidos dentro de tarjetas
  // color leche.

  /// Nivel 1 — Chip, icono, botón (--shadow-clay-sm)
  static List<BoxShadow> get claySm => [
        BoxShadow(
          offset: const Offset(7, 8),
          blurRadius: 16,
          color: ink.withAlpha(31), // 0.12
        ),
        BoxShadow(
          offset: const Offset(-4, -5),
          blurRadius: 12,
          color: Colors.white.withAlpha(230), // 0.90
        ),
      ];

  /// Nivel 2 — Tarjeta estándar (--shadow-clay)
  static List<BoxShadow> get clay => [
        BoxShadow(
          offset: const Offset(14, 16),
          blurRadius: 30,
          color: ink.withAlpha(33), // 0.13
        ),
        BoxShadow(
          offset: const Offset(-8, -10),
          blurRadius: 22,
          color: Colors.white.withAlpha(230), // 0.90
        ),
      ];

  /// Nivel 3 — Modal, hero (--shadow-clay-xl)
  static List<BoxShadow> get clayXl => [
        BoxShadow(
          offset: const Offset(22, 26),
          blurRadius: 48,
          color: ink.withAlpha(41), // 0.16
        ),
        BoxShadow(
          offset: const Offset(-12, -14),
          blurRadius: 32,
          color: Colors.white.withAlpha(242), // 0.95
        ),
      ];

  // ─── DECORACIONES REUTILIZABLES ──────────────────────────────────────────────

  /// Tarjeta blanca con sombra clay
  static BoxDecoration cardBox({Color? color, double radius = radiusCard}) =>
      BoxDecoration(
        color: color ?? leche,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: clay,
      );

  /// Chip o pastilla con sombra pequeña
  static BoxDecoration chipBox({Color? color, double radius = 999}) =>
      BoxDecoration(
        color: color ?? leche,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: claySm,
      );

  // ─── DECORACIÓN DE CAMPOS ────────────────────────────────────────────────────

  static OutlineInputBorder _fieldBorder(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusField),
        borderSide: BorderSide(color: color, width: width),
      );

  static final InputDecorationTheme _inputTheme = InputDecorationTheme(
    filled: true,
    fillColor: arena,
    // El foco lo comunica el borde; el relleno no cambia al pasar el cursor.
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    labelStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: inkSoft,
    ),
    floatingLabelStyle: WidgetStateTextStyle.resolveWith(
      (states) => TextStyle(
        fontWeight: FontWeight.w700,
        color: states.contains(WidgetState.error)
            ? coralInk
            : states.contains(WidgetState.focused)
                ? ink
                : inkSoft,
      ),
    ),
    hintStyle: const TextStyle(fontSize: 16, color: inkSoft),
    helperStyle: const TextStyle(fontSize: 13, color: inkSoft),
    helperMaxLines: 2,
    errorMaxLines: 3,
    errorStyle: const TextStyle(
      color: coralInk,
      fontWeight: FontWeight.w700,
      fontSize: 13,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
    border: _fieldBorder(bordeCampo, 1.2),
    enabledBorder: _fieldBorder(bordeCampo, 1.2),
    disabledBorder: _fieldBorder(borde, 1.2),
    focusedBorder: _fieldBorder(lavandaInk, 2),
    errorBorder: _fieldBorder(coralInk, 1.6),
    focusedErrorBorder: _fieldBorder(coralInk, 2.4),
    suffixIconColor: inkSoft,
  );

  /// Decoración de un campo. Toma su estilo del tema; solo aporta los textos.
  static InputDecoration field(
    String label, {
    String? hint,
    String? helper,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        suffixIcon: suffixIcon,
      );

  // ─── THEMEDATA ───────────────────────────────────────────────────────────────

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: fontBody,
        scaffoldBackgroundColor: arena,
        canvasColor: leche,
        // Estados de interacción en lavanda en vez del gris por defecto
        focusColor: lavanda.withAlpha(90),
        hoverColor: lavanda.withAlpha(45),
        highlightColor: lavanda.withAlpha(60),
        splashColor: lavanda.withAlpha(70),
        colorScheme: const ColorScheme.light(
          primary: lavandaInk,
          onPrimary: leche,
          primaryContainer: lavanda,
          onPrimaryContainer: ink,
          secondary: lima,
          onSecondary: ink,
          error: coralInk,
          onError: leche,
          surface: leche,
          onSurface: ink,
          onSurfaceVariant: inkSoft,
          outline: borde,
        ),

        // AppBar sin sombra, misma arena que el fondo
        appBarTheme: const AppBarTheme(
          backgroundColor: arena,
          foregroundColor: ink,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: fontDisplay,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),

        inputDecorationTheme: _inputTheme,

        textSelectionTheme: TextSelectionThemeData(
          cursorColor: lavandaInk,
          selectionColor: lavanda.withAlpha(140),
          selectionHandleColor: lavandaInk,
        ),

        // Botón primario — fondo lima, texto ink, altura mínima 52px
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lima,
            foregroundColor: ink,
            disabledBackgroundColor: lima.withAlpha(150),
            disabledForegroundColor: inkSoft,
            minimumSize: const Size.fromHeight(56),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton),
            ),
            textStyle: const TextStyle(
              fontFamily: fontBody,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
            elevation: 0,
          ).copyWith(
            // Sin la sombra gris de Material al pasar el cursor o presionar:
            // el relieve lo da la sombra clay del contenedor.
            elevation: const WidgetStatePropertyAll(0),
            // Anillo visible al llegar con teclado.
            side: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.focused)
                  ? const BorderSide(color: ink, width: 2)
                  : BorderSide.none,
            ),
            shadowColor: const WidgetStatePropertyAll(Colors.transparent),
            overlayColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed)
                  ? ink.withAlpha(28)
                  : states.contains(WidgetState.hovered) ||
                          states.contains(WidgetState.focused)
                      ? ink.withAlpha(15)
                      : null,
            ),
          ),
        ),

        // Botón secundario — solo texto
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: ink,
            minimumSize: const Size(64, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton),
            ),
            textStyle: const TextStyle(
              fontFamily: fontBody,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Menús desplegables con la misma piel que las tarjetas
        popupMenuTheme: PopupMenuThemeData(
          color: leche,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusField),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: ink,
          contentTextStyle: const TextStyle(
            fontFamily: fontBody,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: leche,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        progressIndicatorTheme: const ProgressIndicatorThemeData(color: ink),

        // Escala tipográfica — equivale a la escala del CSS
        textTheme: const TextTheme(
          // --text-display: Bitter 800 / 40px
          displayLarge: TextStyle(
            fontFamily: fontDisplay,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: ink,
            height: 1.1,
          ),
          // --text-title: Bitter 700 / 28px
          titleLarge: TextStyle(
            fontFamily: fontDisplay,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: ink,
            height: 1.2,
          ),
          // --text-subtitle: Bitter 600 / 20px
          titleMedium: TextStyle(
            fontFamily: fontDisplay,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ink,
            height: 1.3,
          ),
          // --text-body: Nunito 400 / 17px
          bodyLarge: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: ink,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: ink,
            height: 1.45,
          ),
          // --text-label: Nunito 700 / 15px
          labelLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          // --text-micro: Nunito 700 / 12px
          labelSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: inkSoft,
            letterSpacing: 1.6,
          ),
        ),
      );
}
