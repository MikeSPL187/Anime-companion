import 'package:dio/dio.dart';

import 'app_network_log_interceptor.dart';

abstract final class DioTimeouts {
  static const connect = Duration(seconds: 10);
  static const send = Duration(seconds: 10);
  static const receive = Duration(seconds: 20);
}

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: DioTimeouts.connect,
      sendTimeout: DioTimeouts.send,
      receiveTimeout: DioTimeouts.receive,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(AppNetworkLogInterceptor());
  return dio;
}
