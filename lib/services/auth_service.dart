import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<UserCredential> registrar(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  static Future<UserCredential> iniciarSesion(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  static Future<void> cerrarSesion() => _auth.signOut();

  static User? get usuarioActual => _auth.currentUser;

  static String mensajeError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo.';
      case 'weak-password':
        return 'La contraseña es muy débil. Usa al menos 6 caracteres.';
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return 'Error de autenticación. Intenta nuevamente.';
    }
  }
}
