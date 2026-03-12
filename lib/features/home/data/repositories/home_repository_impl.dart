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
