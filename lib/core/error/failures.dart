import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({this.message = 'An unexpected error occurred'});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Failed to load cached data'});
}

class ParseFailure extends Failure {
  const ParseFailure({super.message = 'Failed to parse data'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred'});
}
