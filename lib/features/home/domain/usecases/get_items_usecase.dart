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
