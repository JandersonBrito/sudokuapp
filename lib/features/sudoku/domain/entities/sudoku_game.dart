import 'sudoku_difficulty.dart';

class SudokuGame {
  final List<List<int>> board; // 0 = empty
  final List<List<int>> solution;
  final List<List<bool>> isFixed; // cells given at start
  final SudokuDifficulty difficulty;
  final int mistakes;
  final bool isComplete;

  const SudokuGame({
    required this.board,
    required this.solution,
    required this.isFixed,
    required this.difficulty,
    this.mistakes = 0,
    this.isComplete = false,
  });

  SudokuGame copyWith({
    List<List<int>>? board,
    List<List<int>>? solution,
    List<List<bool>>? isFixed,
    SudokuDifficulty? difficulty,
    int? mistakes,
    bool? isComplete,
  }) {
    return SudokuGame(
      board: board ?? this.board,
      solution: solution ?? this.solution,
      isFixed: isFixed ?? this.isFixed,
      difficulty: difficulty ?? this.difficulty,
      mistakes: mistakes ?? this.mistakes,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
