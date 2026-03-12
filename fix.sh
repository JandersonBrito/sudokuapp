#!/bin/bash
set -e

echo "🔧 Corrigindo projeto Flutter..."

# ─── 1. Habilitar web e criar estrutura base ──────────────────────────────────
flutter create . --platforms=android,web 2>/dev/null || true
flutter config --enable-web

# ─── 2. Garantir estrutura de pastas ─────────────────────────────────────────
mkdir -p lib/core/{di,errors,network,router,theme,usecases}
mkdir -p lib/features/home/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}
mkdir -p assets/{images,icons,translations}
touch assets/images/.gitkeep assets/icons/.gitkeep assets/translations/.gitkeep

echo "📁 Pastas criadas"

# ─── core/errors/failures.dart ───────────────────────────────────────────────
cat > lib/core/errors/failures.dart << 'EOF'
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  const Failure({required this.message, this.statusCode});
  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}
EOF

# ─── core/errors/exceptions.dart ─────────────────────────────────────────────
cat > lib/core/errors/exceptions.dart << 'EOF'
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection.'});
}
EOF

# ─── core/usecases/usecase.dart ──────────────────────────────────────────────
cat > lib/core/usecases/usecase.dart << 'EOF'
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
EOF

# ─── core/network/dio_client.dart ────────────────────────────────────────────
cat > lib/core/network/dio_client.dart << 'EOF'
import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    _dio.interceptors.add(_LoggingInterceptor());
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('REQUEST[${options.method}] => ${options.path}');
    super.onRequest(options, handler);
  }
}
EOF

# ─── core/theme/app_theme.dart ───────────────────────────────────────────────
cat > lib/core/theme/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: const CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
      );
}
EOF

# ─── core/router/app_router.dart ─────────────────────────────────────────────
cat > lib/core/router/app_router.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
EOF

# ─── core/di/injection_container.dart ────────────────────────────────────────
cat > lib/core/di/injection_container.dart << 'EOF'
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_items_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => HomeBloc(getItems: sl()));
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
  sl.registerLazySingleton(() => DioClient(sl()));
  sl.registerLazySingleton(() => Dio(BaseOptions(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.example.com',
    ),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  )));
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);
}
EOF

# ─── domain/entities/item.dart ───────────────────────────────────────────────
cat > lib/features/home/domain/entities/item.dart << 'EOF'
import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, description, createdAt];
}
EOF

# ─── domain/repositories/home_repository.dart ────────────────────────────────
cat > lib/features/home/domain/repositories/home_repository.dart << 'EOF'
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<Item>>> getItems();
  Future<Either<Failure, Item>> getItemById(String id);
}
EOF

# ─── domain/usecases/get_items_usecase.dart ───────────────────────────────────
cat > lib/features/home/domain/usecases/get_items_usecase.dart << 'EOF'
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/item.dart';
import '../repositories/home_repository.dart';

class GetItemsUseCase implements UseCaseNoParams<List<Item>> {
  final HomeRepository repository;
  GetItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Item>>> call() => repository.getItems();
}
EOF

# ─── data/models/item_model.dart ─────────────────────────────────────────────
cat > lib/features/home/data/models/item_model.dart << 'EOF'
import '../../domain/entities/item.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };
}
EOF

# ─── data/datasources/home_remote_datasource.dart ────────────────────────────
cat > lib/features/home/data/datasources/home_remote_datasource.dart << 'EOF'
import '../../../../core/network/dio_client.dart';
import '../models/item_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<ItemModel>> getItems();
  Future<ItemModel> getItemById(String id);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient dioClient;
  HomeRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ItemModel>> getItems() async {
    final response = await dioClient.get('/items');
    final data = response.data as List<dynamic>;
    return data.map((json) => ItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<ItemModel> getItemById(String id) async {
    final response = await dioClient.get('/items/$id');
    return ItemModel.fromJson(response.data as Map<String, dynamic>);
  }
}
EOF

# ─── data/datasources/home_local_datasource.dart ─────────────────────────────
cat > lib/features/home/data/datasources/home_local_datasource.dart << 'EOF'
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/item_model.dart';

abstract class HomeLocalDataSource {
  Future<List<ItemModel>> getCachedItems();
  Future<void> cacheItems(List<ItemModel> items);
}

const _cachedItemsKey = 'CACHED_ITEMS';

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final SharedPreferences prefs;
  HomeLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<ItemModel>> getCachedItems() async {
    final jsonString = prefs.getString(_cachedItemsKey);
    if (jsonString == null) throw const CacheException(message: 'No cached items found');
    final jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList.map((e) => ItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> cacheItems(List<ItemModel> items) async {
    await prefs.setString(_cachedItemsKey, json.encode(items.map((i) => i.toJson()).toList()));
  }
}
EOF

# ─── data/repositories/home_repository_impl.dart ─────────────────────────────
cat > lib/features/home/data/repositories/home_repository_impl.dart << 'EOF'
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, List<Item>>> getItems() async {
    try {
      final items = await remoteDataSource.getItems();
      await localDataSource.cacheItems(items);
      return Right(items);
    } on ServerException catch (e) {
      try {
        return Right(await localDataSource.getCachedItems());
      } on CacheException {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      }
    } on NetworkException {
      try {
        return Right(await localDataSource.getCachedItems());
      } on CacheException {
        return const Left(NetworkFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Item>> getItemById(String id) async {
    try {
      return Right(await remoteDataSource.getItemById(id));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
EOF

# ─── presentation/bloc/home_bloc.dart ────────────────────────────────────────
cat > lib/features/home/presentation/bloc/home_bloc.dart << 'EOF'
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/get_items_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetItemsUseCase getItems;

  HomeBloc({required this.getItems}) : super(HomeInitial()) {
    on<LoadItemsEvent>(_onLoadItems);
    on<RefreshItemsEvent>(_onRefreshItems);
  }

  Future<void> _onLoadItems(LoadItemsEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final result = await getItems();
    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (items) => emit(HomeLoaded(items: items)),
    );
  }

  Future<void> _onRefreshItems(RefreshItemsEvent event, Emitter<HomeState> emit) async {
    final result = await getItems();
    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (items) => emit(HomeLoaded(items: items)),
    );
  }
}
EOF

cat > lib/features/home/presentation/bloc/home_event.dart << 'EOF'
part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadItemsEvent extends HomeEvent {
  const LoadItemsEvent();
}

class RefreshItemsEvent extends HomeEvent {
  const RefreshItemsEvent();
}
EOF

cat > lib/features/home/presentation/bloc/home_state.dart << 'EOF'
part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Item> items;
  const HomeLoaded({required this.items});
  @override
  List<Object?> get props => [items];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
  @override
  List<Object?> get props => [message];
}
EOF

# ─── presentation/pages/home_page.dart ───────────────────────────────────────
cat > lib/features/home/presentation/pages/home_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/home_bloc.dart';
import '../widgets/item_card.dart';
import '../widgets/error_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const LoadItemsEvent()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Clean App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<HomeBloc>().add(const RefreshItemsEvent()),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('No items found'));
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<HomeBloc>().add(const RefreshItemsEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                itemBuilder: (context, index) => ItemCard(item: state.items[index]),
              ),
            );
          }
          if (state is HomeError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<HomeBloc>().add(const LoadItemsEvent()),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
EOF

# ─── presentation/widgets/item_card.dart ─────────────────────────────────────
cat > lib/features/home/presentation/widgets/item_card.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(item.description, style: theme.textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# ─── presentation/widgets/error_widget.dart ──────────────────────────────────
cat > lib/features/home/presentation/widgets/error_widget.dart << 'EOF'
import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const AppErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Oops! Something went wrong', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
EOF

# ─── lib/main.dart ───────────────────────────────────────────────────────────
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';

import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Clean App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
EOF

# ─── pubspec.yaml ─────────────────────────────────────────────────────────────
cat > pubspec.yaml << 'EOF'
name: flutter_clean_app
description: Flutter app with Clean Architecture, BLoC and Docker support.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.5
  bloc: ^8.1.4
  equatable: ^2.0.5
  get_it: ^7.7.0
  dio: ^5.4.3
  shared_preferences: ^2.2.3
  dartz: ^0.10.1
  intl: ^0.19.0
  go_router: ^13.2.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/translations/
EOF

# ─── Instalar dependências e verificar ───────────────────────────────────────
flutter pub get

echo ""
echo "✅ Projeto corrigido com sucesso!"
echo "Rodando flutter analyze para verificar..."
flutter analyze --no-fatal-infos || true
