class TokenMissedException implements Exception {
  String message;
  TokenMissedException(this.message);
}

class TokenExpiredException implements Exception {
  String message;
  TokenExpiredException(this.message);
}