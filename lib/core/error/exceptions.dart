class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class NetworkException implements Exception {
  const NetworkException({this.message = 'No internet connection'});

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  const CacheException({this.message = 'Cache error'});

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class ParseException implements Exception {
  const ParseException({this.message = 'Failed to parse data'});

  final String message;

  @override
  String toString() => 'ParseException: $message';
}
