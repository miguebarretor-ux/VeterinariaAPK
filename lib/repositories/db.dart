import 'package:cloud_firestore/cloud_firestore.dart';

/// Acceso único a Firestore para los repositorios. En las pruebas se
/// reemplaza por una base de datos falsa con [usar].
class Db {
  static FirebaseFirestore? _prueba;

  static FirebaseFirestore get i => _prueba ?? FirebaseFirestore.instance;

  /// Solo para pruebas: usa [db] en lugar de la instancia real (null la
  /// restaura).
  static void usar(FirebaseFirestore? db) => _prueba = db;
}

/// Error de una operación con un mensaje apto para mostrar a la persona.
class OperacionException implements Exception {
  final String mensaje;
  const OperacionException(this.mensaje);

  @override
  String toString() => mensaje;
}
