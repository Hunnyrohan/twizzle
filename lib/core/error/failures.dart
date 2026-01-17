// lib/core/error/failures.dart
abstract class Failure {}

class CacheFailure extends Failure {}

class ServerFailure extends Failure {
  final String message;
  ServerFailure(this.message);
}