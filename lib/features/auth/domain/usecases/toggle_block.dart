import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../repositories/user_repository.dart';

class ToggleBlock {
  final UserRepository repository;

  ToggleBlock(this.repository);

  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.toggleBlock(userId);
  }
}
