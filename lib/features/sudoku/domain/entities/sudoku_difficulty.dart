enum SudokuDifficulty {
  veryEasy,
  easy,
  medium,
  hard,
  expert;

  String get label {
    switch (this) {
      case SudokuDifficulty.veryEasy:
        return 'Muito Fácil';
      case SudokuDifficulty.easy:
        return 'Fácil';
      case SudokuDifficulty.medium:
        return 'Médio';
      case SudokuDifficulty.hard:
        return 'Difícil';
      case SudokuDifficulty.expert:
        return 'Expert';
    }
  }

  /// Number of cells to remove from a complete board
  int get cellsToRemove {
    switch (this) {
      case SudokuDifficulty.veryEasy:
        return 25;
      case SudokuDifficulty.easy:
        return 35;
      case SudokuDifficulty.medium:
        return 45;
      case SudokuDifficulty.hard:
        return 52;
      case SudokuDifficulty.expert:
        return 58;
    }
  }
}
