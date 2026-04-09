sealed class AppError {
  const AppError();

  String get message;
}

final class NetworkError extends AppError {
  const NetworkError({required this.message, this.statusCode});

  @override
  final String message;
  final int? statusCode;
}

final class NotFoundError extends AppError {
  const NotFoundError(this.resourceId);

  final String resourceId;

  @override
  String get message => 'Resource not found: $resourceId';
}

final class ParseError extends AppError {
  const ParseError(this.message);

  @override
  final String message;
}

final class CacheError extends AppError {
  const CacheError(this.message);

  @override
  final String message;
}

final class UnknownError extends AppError {
  const UnknownError(this.cause);

  final Object cause;

  @override
  String get message => 'Unknown error';
}
