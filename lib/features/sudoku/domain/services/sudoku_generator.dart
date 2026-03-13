import 'dart:math';
import '../entities/sudoku_difficulty.dart';
import '../entities/sudoku_game.dart';

class SudokuGenerator {
  static final _random = Random();

  static SudokuGame generate(SudokuDifficulty difficulty) {
    final solution = _generateSolution();
    final board = _removeNumbers(solution, difficulty.cellsToRemove);
    final isFixed = List.generate(
      9,
      (r) => List.generate(9, (c) => board[r][c] != 0),
    );

    return SudokuGame(
      board: board,
      solution: solution,
      isFixed: isFixed,
      difficulty: difficulty,
    );
  }

  static List<List<int>> _generateSolution() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  static bool _fillGrid(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          final nums = List.generate(9, (i) => i + 1)..shuffle(_random);
          for (final num in nums) {
            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (_fillGrid(grid)) return true;
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static bool _isValid(List<List<int>> grid, int row, int col, int num) {
    // Check row
    if (grid[row].contains(num)) return false;

    // Check column
    for (int r = 0; r < 9; r++) {
      if (grid[r][col] == num) return false;
    }

    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == num) return false;
      }
    }

    return true;
  }

  static List<List<int>> _removeNumbers(List<List<int>> solution, int count) {
    final board = solution.map((row) => List<int>.from(row)).toList();
    final cells = List.generate(81, (i) => i)..shuffle(_random);

    int removed = 0;
    for (final cell in cells) {
      if (removed >= count) break;
      final row = cell ~/ 9;
      final col = cell % 9;
      if (board[row][col] != 0) {
        board[row][col] = 0;
        removed++;
      }
    }

    return board;
  }
}
