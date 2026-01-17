// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';

// data sources
import 'features/auth/data/datasources/local/hive_local_source.dart';
import 'features/auth/data/datasources/remote/api_remote_source.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
// domain
import 'features/auth/domain/repositories/user_repository.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
// presentation

final sl = GetIt.instance;

Future<void> init() async {
  await Hive.initFlutter();

  // datasources
  sl.registerLazySingleton<ApiRemoteSource>(() => ApiRemoteSource());
  sl.registerLazySingleton<HiveLocalSource>(() => HiveLocalSource());

  // repository
  sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(sl(), sl()));

  // use cases
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));

  // provider
  sl.registerFactory(() => UserProvider(register: sl(), login: sl(), repo: sl()));
}