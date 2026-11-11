import 'mascota_model.dart';

/// Reglas de validación del registro. Son funciones puras: devuelven el
/// mensaje de error que ve la persona, o `null` si el valor es válido.
class Validadores {
  static final RegExp _soloLetras = RegExp(r"^\p{L}[\p{L}\p{M}\s'’.\-]*$", unicode: true);
  static final RegExp _correo = RegExp(r'^[^\s@]+@[^\s@.]+(\.[^\s@.]+)+$');
  static final RegExp _digitos = RegExp(r'^\d+$');
  static final RegExp _alfanumerico = RegExp(r'^[A-Za-z0-9]+$');
  static final RegExp _letra = RegExp(r'\p{L}', unicode: true);
  static final RegExp _numero = RegExp(r'\d');

  static const int contrasenaMinima = 8;

  /// Nombre o apellido de persona. [queFalta] completa "Escribe …".
  static String? nombrePersona(String? valor, {required String queFalta}) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Escribe $queFalta';
    if (v.length < 2) return 'Debe tener al menos 2 letras';
    if (!_soloLetras.hasMatch(v)) return 'Usa solo letras, sin números ni símbolos';
    return null;
  }

  /// Texto obligatorio sin más reglas (nombre de la mascota, especie).
  static String? obligatorio(String? valor, {required String mensaje}) {
    return (valor == null || valor.trim().isEmpty) ? mensaje : null;
  }

  static String? documento(String tipo, String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Escribe tu número de documento';
    if (tipo == Opciones.pasaporte) {
      if (!_alfanumerico.hasMatch(v)) return 'Usa solo letras y números, sin espacios';
      if (v.length < 5 || v.length > 12) return 'El pasaporte tiene entre 5 y 12 caracteres';
      return null;
    }
    if (!_digitos.hasMatch(v)) return 'Usa solo números, sin puntos ni espacios';
    if (v.length < 6 || v.length > 11) return 'Debe tener entre 6 y 11 dígitos';
    return null;
  }

  static String? correo(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Escribe tu correo';
    if (!_correo.hasMatch(v)) return 'Revisa el correo. Ejemplo: nombre@correo.com';
    return null;
  }

  static bool tieneLongitud(String v) => v.length >= contrasenaMinima;
  static bool tieneLetra(String v) => _letra.hasMatch(v);
  static bool tieneNumero(String v) => _numero.hasMatch(v);

  static String? contrasena(String? valor) {
    final v = valor ?? '';
    if (v.isEmpty) return 'Crea una contraseña';
    if (!tieneLongitud(v) || !tieneLetra(v) || !tieneNumero(v)) {
      return 'Aún no cumple los requisitos de abajo';
    }
    return null;
  }

  static String? confirmacion(String? valor, String original) {
    if (valor == null || valor.isEmpty) return 'Repite tu contraseña';
    if (valor != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? edad(String? valor, String unidad) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Escribe la edad';
    final n = int.tryParse(v);
    if (n == null || n < 0) return 'Usa un número entero';
    if (unidad == Opciones.meses) {
      if (n > 23) return 'Para 2 años o más, cambia a años';
      return null;
    }
    if (n == 0) return 'Si tiene menos de un año, cambia a meses';
    if (n > 100) return 'Revisa la edad';
    return null;
  }

  /// Convierte "4,5" o "4.5" a número. `null` si está vacío o no es un número.
  static double? leerPeso(String? valor) {
    final v = valor?.trim().replaceAll(',', '.') ?? '';
    if (v.isEmpty) return null;
    return double.tryParse(v);
  }

  /// El peso es opcional: vacío es válido.
  static String? peso(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    final n = leerPeso(valor);
    if (n == null) return 'Usa un número, por ejemplo 4,5';
    if (n <= 0) return 'El peso debe ser mayor que 0';
    if (n > 1000) return 'Revisa el peso, es en kilogramos';
    return null;
  }
}
