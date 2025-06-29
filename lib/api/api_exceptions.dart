// A base class for all API-related exceptions.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

// Specific exception for 401 Unauthorized responses.
class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

// You can add more for other status codes as needed
class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}