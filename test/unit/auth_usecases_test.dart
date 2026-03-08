import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/auth/domain/usecases/login_user.dart';
import 'package:twizzle/features/auth/domain/usecases/register_user.dart';
import 'package:twizzle/features/auth/domain/usecases/get_blocks.dart';
import 'package:twizzle/features/auth/domain/usecases/toggle_block.dart';

import 'mocks.dart';

void main() {
  late MockUserRepository mockRepo;
  late LoginUser loginUser;
  late RegisterUser registerUser;
  late GetBlocks getBlocks;
  late ToggleBlock toggleBlock;

  setUpAll(() {
    setupMocks();
  });

  setUp(() {
    mockRepo = MockUserRepository();
    loginUser = LoginUser(mockRepo);
    registerUser = RegisterUser(mockRepo);
    getBlocks = GetBlocks(mockRepo);
    toggleBlock = ToggleBlock(mockRepo);
  });

  final tUser = User(
    id: '1',
    name: 'Test',
    username: 'test',
    email: 'test@test.com',
    password: 'password',
    token: 'token',
  );

  group('LoginUser', () {
    test('should return User when login is successful', () async {
      // arrange
      when(() => mockRepo.loginUser(any(), any(), confirmReactivate: any(named: 'confirmReactivate')))
          .thenAnswer((_) async => Right(tUser));
      // act
      final result = await loginUser('test@test.com', 'password');
      // assert
      expect(result, Right(tUser));
      verify(() => mockRepo.loginUser('test@test.com', 'password')).called(1);
    });

    test('should return Failure when login fails', () async {
      // arrange
      when(() => mockRepo.loginUser(any(), any(), confirmReactivate: any(named: 'confirmReactivate')))
          .thenAnswer((_) async => const Left(ServerFailure('Login Failed')));
      // act
      final result = await loginUser('test@test.com', 'password');
      // assert
      expect(result, const Left(ServerFailure('Login Failed')));
    });
  });

  group('RegisterUser', () {
    test('should return User when registration is successful', () async {
      // arrange
      when(() => mockRepo.registerUser(any()))
          .thenAnswer((_) async => Right(tUser));
      // act
      final result = await registerUser(tUser);
      // assert
      expect(result, Right(tUser));
      verify(() => mockRepo.registerUser(tUser)).called(1);
    });

    test('should return Failure when registration fails', () async {
      // arrange
      when(() => mockRepo.registerUser(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Register Failed')));
      // act
      final result = await registerUser(tUser);
      // assert
      expect(result, const Left(ServerFailure('Register Failed')));
    });
  });

  group('Auth Edge Cases', () {
    test('should return DeactivatedAccountFailure on login', () async {
      when(() => mockRepo.loginUser(any(), any(), confirmReactivate: any(named: 'confirmReactivate')))
          .thenAnswer((_) async => const Left(DeactivatedAccountFailure('Account deactivated')));
      final result = await loginUser('e', 'p');
      expect(result, const Left(DeactivatedAccountFailure('Account deactivated')));
    });

    test('should return CacheFailure on getBlocks', () async {
      when(() => mockRepo.getBlocks()).thenAnswer((_) async => const Left(CacheFailure()));
      final result = await getBlocks();
      expect(result, const Left(CacheFailure()));
    });
  });

  group('GetBlocks', () {
    test('should return list of blocked users', () async {
      // arrange
      when(() => mockRepo.getBlocks())
          .thenAnswer((_) async => Right([tUser]));
      // act
      final result = await getBlocks();
      // assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), equals([tUser]));
      verify(() => mockRepo.getBlocks()).called(1);
    });

    test('should return Failure when getBlocks fails', () async {
      // arrange
      when(() => mockRepo.getBlocks())
          .thenAnswer((_) async => const Left(ServerFailure('Failed')));
      // act
      final result = await getBlocks();
      // assert
      expect(result, const Left(ServerFailure('Failed')));
    });
  });

  group('ForgotPassword', () {
    test('should return message string when forgot password is successful', () async {
      when(() => mockRepo.forgotPassword(any()))
          .thenAnswer((_) async => const Right('Check your email'));
      final result = await mockRepo.forgotPassword('test@test.com');
      expect(result.isRight(), true);
      result.fold((_) {}, (msg) => expect(msg, 'Check your email'));
    });

    test('should return ServerFailure when forgot password fails', () async {
      when(() => mockRepo.forgotPassword(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Email not found')));
      final result = await mockRepo.forgotPassword('test@test.com');
      expect(result, const Left(ServerFailure('Email not found')));
    });
  });

  group('ResetPassword', () {
    test('should return string when reset password is successful', () async {
      when(() => mockRepo.resetPassword(any(), any()))
          .thenAnswer((_) async => const Right('Password changed'));
      final result = await mockRepo.resetPassword('code123', 'newPass!');
      expect(result.isRight(), true);
    });

    test('should return ServerFailure when reset password fails', () async {
      when(() => mockRepo.resetPassword(any(), any()))
          .thenAnswer((_) async => const Left(ServerFailure('Invalid code')));
      final result = await mockRepo.resetPassword('bad', 'newPass!');
      expect(result, const Left(ServerFailure('Invalid code')));
    });
  });

  group('ToggleBlock', () {
    test('should return unit when toggle is successful', () async {
      // arrange
      when(() => mockRepo.toggleBlock(any()))
          .thenAnswer((_) async => const Right(unit));
      // act
      final result = await toggleBlock('id');
      // assert
      expect(result, const Right(unit));
      verify(() => mockRepo.toggleBlock('id')).called(1);
    });

    test('should return Failure when toggle fails', () async {
      // arrange
      when(() => mockRepo.toggleBlock(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Failed')));
      // act
      final result = await toggleBlock('id');
      // assert
      expect(result, const Left(ServerFailure('Failed')));
    });
  });
}
