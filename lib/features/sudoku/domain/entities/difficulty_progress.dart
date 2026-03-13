import 'package:equatable/equatable.dart';
import 'sudoku_difficulty.dart';

/// Tracks how many times each difficulty has been completed
/// and which difficulties are unlocked.
class DifficultyProgress extends Equatable {
  final int veryEasyCompletions;
  final int easyCompletions;
  final int mediumCompletions;
  final int hardCompletions;
  final int expertCompletions;

  const DifficultyProgress({
    this.veryEasyCompletions = 0,
    this.easyCompletions = 0,
    this.mediumCompletions = 0,
    this.hardCompletions = 0,
    this.expertCompletions = 0,
  });

  /// Returns true if the given difficulty is unlocked.
  bool isUnlocked(SudokuDifficulty difficulty) {
    switch (difficulty) {
      case SudokuDifficulty.veryEasy:
        return true; // always unlocked
      case SudokuDifficulty.easy:
        return veryEasyCompletions >= 1;
      case SudokuDifficulty.medium:
        return easyCompletions >= 5;
      case SudokuDifficulty.hard:
        return mediumCompletions >= 10;
      case SudokuDifficulty.expert:
        return hardCompletions >= 20;
    }
  }

  /// How many completions are required to unlock [difficulty].
  int requiredCompletions(SudokuDifficulty difficulty) {
    switch (difficulty) {
      case SudokuDifficulty.veryEasy:
        return 0;
      case SudokuDifficulty.easy:
        return 1;
      case SudokuDifficulty.medium:
        return 5;
      case SudokuDifficulty.hard:
        return 10;
      case SudokuDifficulty.expert:
        return 20;
    }
  }

  /// The difficulty whose completions unlock [difficulty].
  SudokuDifficulty? prerequisite(SudokuDifficulty difficulty) {
    switch (difficulty) {
      case SudokuDifficulty.veryEasy:
        return null;
      case SudokuDifficulty.easy:
        return SudokuDifficulty.veryEasy;
      case SudokuDifficulty.medium:
        return SudokuDifficulty.easy;
      case SudokuDifficulty.hard:
        return SudokuDifficulty.medium;
      case SudokuDifficulty.expert:
        return SudokuDifficulty.hard;
    }
  }

  /// Current completions for the prerequisite difficulty.
  int currentCompletions(SudokuDifficulty difficulty) {
    final pre = prerequisite(difficulty);
    if (pre == null) return 0;
    return completionsFor(pre);
  }

  int completionsFor(SudokuDifficulty difficulty) {
    switch (difficulty) {
      case SudokuDifficulty.veryEasy:
        return veryEasyCompletions;
      case SudokuDifficulty.easy:
        return easyCompletions;
      case SudokuDifficulty.medium:
        return mediumCompletions;
      case SudokuDifficulty.hard:
        return hardCompletions;
      case SudokuDifficulty.expert:
        return expertCompletions;
    }
  }

  DifficultyProgress incrementCompletions(SudokuDifficulty difficulty) {
    return DifficultyProgress(
      veryEasyCompletions: veryEasyCompletions +
          (difficulty == SudokuDifficulty.veryEasy ? 1 : 0),
      easyCompletions:
          easyCompletions + (difficulty == SudokuDifficulty.easy ? 1 : 0),
      mediumCompletions:
          mediumCompletions + (difficulty == SudokuDifficulty.medium ? 1 : 0),
      hardCompletions:
          hardCompletions + (difficulty == SudokuDifficulty.hard ? 1 : 0),
      expertCompletions:
          expertCompletions + (difficulty == SudokuDifficulty.expert ? 1 : 0),
    );
  }

  @override
  List<Object?> get props => [
        veryEasyCompletions,
        easyCompletions,
        mediumCompletions,
        hardCompletions,
        expertCompletions,
      ];
}
