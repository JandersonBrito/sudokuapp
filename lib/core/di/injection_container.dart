import 'package:get_it/get_it.dart';
import '../../features/sudoku/data/datasources/difficulty_progress_storage.dart';
import '../../features/sudoku/presentation/bloc/sudoku_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => DifficultyProgressStorage());
  sl.registerLazySingleton(
      () => SudokuBloc(storage: sl<DifficultyProgressStorage>()));
}
