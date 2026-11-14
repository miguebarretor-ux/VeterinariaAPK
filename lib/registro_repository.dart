import 'mascota_model.dart';

/// Error de registro o de inicio de sesión con un mensaje apto para mostrar
/// a la persona.
class RegistroException implements Exception {
  final String mensaje;
  const RegistroException(this.mensaje);

  @override
  String toString() => 'RegistroException: $mensaje';
}

/// Cuentas de la app. Las pantallas solo conocen esta interfaz, así se puede
/// conectar una API real sin tocar la interfaz de usuario.
abstract class RegistroRepository {
  /// Crea la cuenta. Lanza [RegistroException] si no se pudo.
  Future<void> registrar(UsuarioModel usuario);

  /// Devuelve la cuenta si el correo y la contraseña coinciden.
  /// Lanza [RegistroException] si no.
  Future<UsuarioModel> iniciarSesion(String correo, String contrasena);
}

/// Implementación provisional mientras no hay backend: guarda las cuentas en
/// memoria, así que se pierden al cerrar o recargar la app.
class RegistroSimuladoRepository implements RegistroRepository {
  final Duration demora;
  final Map<String, UsuarioModel> _cuentas = {};

  RegistroSimuladoRepository({this.demora = const Duration(milliseconds: 900)});

  @override
  Future<void> registrar(UsuarioModel usuario) async {
    // TODO: enviar usuario.toJson() a la API o base de datos.
    // No registrar el JSON en consola: incluye la contraseña.
    await Future<void>.delayed(demora);
    if (_cuentas.containsKey(usuario.correo)) {
      throw const RegistroException('Ese correo ya tiene una cuenta. Inicia sesión.');
    }
    _cuentas[usuario.correo] = usuario;
  }

  @override
  Future<UsuarioModel> iniciarSesion(String correo, String contrasena) async {
    // TODO: validar contra la API.
    await Future<void>.delayed(demora);
    final cuenta = _cuentas[correo.trim().toLowerCase()];
    // Mismo mensaje para correo desconocido y contraseña errada: no revela
    // qué correos tienen cuenta.
    if (cuenta == null || cuenta.contrasena != contrasena) {
      throw const RegistroException('El correo o la contraseña no coinciden.');
    }
    return cuenta;
  }
}
