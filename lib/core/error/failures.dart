// lib/core/error/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache Error']) : super(message);
}

class DeactivatedAccountFailure extends Failure {
  const DeactivatedAccountFailure(super.message);
}