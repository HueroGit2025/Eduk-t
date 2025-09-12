import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionHelper {

  /// Genera un hash SHA-256 de la contraseña
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Compara una contraseña ingresada con un hash guardado
  static bool verifyPassword(String enteredPassword, String storedHash) {
    final enteredHash = hashPassword(enteredPassword);
    return enteredHash == storedHash;
  }
}
