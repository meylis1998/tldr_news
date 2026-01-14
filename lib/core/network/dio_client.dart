import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/constants/api_constants.dart';
import 'package:tldr_news/core/network/interceptors/logging_interceptor.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        responseType: ResponseType.plain,
      ),
    );

    dio.interceptors.addAll([
      LoggingInterceptor(),
    ]);

    return dio;
  }
}
