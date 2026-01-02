// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'features/auth/data/datasources/local/hive_local_source.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
import 'features/auth/domain/repositories/user_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // data
  sl.registerLazySingleton<HiveLocalSource>(() => HiveLocalSource());
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  // domain
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));

  // presentation
  sl.registerFactory(
    () => UserProvider(register: sl(), login: sl(), repo: sl()),
  );
}
