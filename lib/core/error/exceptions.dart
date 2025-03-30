// lib/core/error/exceptions.dart
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
}
