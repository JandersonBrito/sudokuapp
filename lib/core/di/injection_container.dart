import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_interceptor.dart';
import '../auth/token_storage.dart';
import '../network/dio_client.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_items_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/login_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // Token storage
  sl.registerLazySingleton(() => TokenStorage(sl()));

  // Dio + interceptors
  final dio = Dio(BaseOptions(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.example.com',
    ),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  sl.registerLazySingleton(() => dio);
  sl.registerLazySingleton(
    () => AuthInterceptor(tokenStorage: sl(), dio: sl()),
  );
  sl.registerLazySingleton(() {
    final client = DioClient(sl());
    dio.interceptors.add(sl<AuthInterceptor>());
    return client;
  });

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl(), tokenStorage: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(
    () => AuthBloc(authRepository: sl(), tokenStorage: sl()),
  );
  sl.registerFactory(() => LoginBloc(loginUseCase: sl()));

  // Home
  sl.registerLazySingleton(() => GetItemsUseCase(sl()));
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(prefs: sl()),
  );
  sl.registerFactory(() => HomeBloc(getItems: sl()));
}
