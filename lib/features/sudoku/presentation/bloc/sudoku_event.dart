import 'package:equatable/equatable.dart';
import '../../domain/entities/sudoku_difficulty.dart';

abstract class SudokuEvent extends Equatable {
  const SudokuEvent();

  @override
  List<Object?> get props => [];
}

class SudokuStarted extends SudokuEvent {
  final SudokuDifficulty difficulty;

  const SudokuStarted(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}

class SudokuCellSelected extends SudokuEvent {
  final int row;
  final int col;

  const SudokuCellSelected(this.row, this.col);

  @override
  List<Object?> get props => [row, col];
}

class SudokuNumberInput extends SudokuEvent {
  final int number;

  const SudokuNumberInput(this.number);

  @override
  List<Object?> get props => [number];
}

class SudokuCellCleared extends SudokuEvent {
  const SudokuCellCleared();
}

class SudokuReset extends SudokuEvent {
  const SudokuReset();
}

class SudokuHintRequested extends SudokuEvent {
  const SudokuHintRequested();
}
