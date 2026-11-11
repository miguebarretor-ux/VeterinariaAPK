import 'mascota_model.dart';

/// Error de registro con un mensaje apto para mostrar a la persona.
class RegistroException implements Exception {
  final String mensaje;
  const RegistroException(this.mensaje);

  @override
  String toString() => 'RegistroException: $mensaje';
}

/// Destino de los datos del registro. La pantalla solo conoce esta interfaz,
/// así se puede conectar una API real sin tocar la interfaz de usuario.
abstract class RegistroRepository {
  /// Crea la cuenta. Lanza [RegistroException] si no se pudo.
  Future<void> registrar(UsuarioModel usuario);
}

/// Implementación provisional: simula la llamada mientras no hay backend.
class RegistroSimuladoRepository implements RegistroRepository {
  final Duration demora;
  const RegistroSimuladoRepository({this.demora = const Duration(milliseconds: 900)});

  @override
  Future<void> registrar(UsuarioModel usuario) async {
    // TODO: enviar usuario.toJson() a la API o base de datos.
    // No registrar el JSON en consola: incluye la contraseña.
    await Future<void>.delayed(demora);
  }
}
