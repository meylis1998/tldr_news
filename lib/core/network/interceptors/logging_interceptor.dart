import 'dart:developer';

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('┌─────────────────────────────────────────────────────────');
    log('│ REQUEST: ${options.method} ${options.uri}');
    log('│ Headers: ${options.headers}');
    if (options.data != null) {
      log('│ Body: ${options.data}');
    }
    log('└─────────────────────────────────────────────────────────');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    log('┌─────────────────────────────────────────────────────────');
    log('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    log('│ Data length: ${response.data.toString().length} chars');
    log('└─────────────────────────────────────────────────────────');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('┌─────────────────────────────────────────────────────────');
    log('│ ERROR: ${err.type} ${err.requestOptions.uri}');
    log('│ Message: ${err.message}');
    log('└─────────────────────────────────────────────────────────');
    super.onError(err, handler);
  }
}
