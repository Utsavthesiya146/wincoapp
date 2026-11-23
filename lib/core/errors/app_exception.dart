class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AppException(this.message, {this.statusCode, this.details});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([super.message = 'Unable to connect to the server. Please check your internet connection.']);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Session expired or invalid credentials. Please log in again.'])
      : super(statusCode: 401);
}

class ForbiddenException extends AppException {
  ForbiddenException([super.message = 'You do not have permission to access this resource.'])
      : super(statusCode: 403);
}

class NotFoundException extends AppException {
  NotFoundException([super.message = 'Requested resource was not found on the server.'])
      : super(statusCode: 404);
}

class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  ValidationException(super.message, {this.fieldErrors = const {}})
      : super(statusCode: 422);
}

class ServerException extends AppException {
  ServerException([super.message = 'The WINCO server encountered an issue. Please try again later.', int? code])
      : super(statusCode: code ?? 500);
}

