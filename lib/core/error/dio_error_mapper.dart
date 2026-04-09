import 'package:dio/dio.dart';

import 'app_error.dart';

AppError mapDioException(Object error) {
  if (error case final DioException exception) {
    final statusCode = exception.response?.statusCode;
    if (statusCode == 404) {
      return NotFoundError(exception.requestOptions.path);
    }

    return NetworkError(message: exception.type.name, statusCode: statusCode);
  }

  return UnknownError(error);
}
