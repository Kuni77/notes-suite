class AppException implements Exception {
  final String message;
  final String? details;

  AppException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

class NetworkException extends AppException {
  NetworkException([String? details])
      : super('Network error', details ?? 'Please check your internet connection');
}

class AuthException extends AppException {
  AuthException([String? details])
      : super('Authentication error', details ?? 'Please login again');
}

class ValidationException extends AppException {
  ValidationException([String? details])
      : super('Validation error', details);
}

class NotFoundException extends AppException {
  NotFoundException([String? details])
      : super('Not found', details);
}

class ServerException extends AppException {
  ServerException([String? details])
      : super('Server error', details ?? 'Something went wrong');
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? details])
      : super('Unauthorized', details ?? 'You don\'t have permission');
}