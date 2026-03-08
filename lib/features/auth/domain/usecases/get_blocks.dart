import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetBlocks {
  final UserRepository repository;

  GetBlocks(this.repository);

  Future<Either<Failure, List<User>>> call() async {
    return await repository.getBlocks();
  }
}
