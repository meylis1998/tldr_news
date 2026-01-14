import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/constants/api_constants.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio get dio {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        responseType: ResponseType.plain,
      ),
    );
  }
}
