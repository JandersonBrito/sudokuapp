import 'package:equatable/equatable.dart';
import '../../domain/entities/sudoku_game.dart';
import '../../domain/entities/difficulty_progress.dart';

abstract class SudokuState extends Equatable {
  const SudokuState();

  @override
  List<Object?> get props => [];
}

class SudokuInitial extends SudokuState {
  final DifficultyProgress progress;

  const SudokuInitial({this.progress = const DifficultyProgress()});

  @override
  List<Object?> get props => [progress];
}

class SudokuInProgress extends SudokuState {
  final SudokuGame game;
  final DifficultyProgress progress;
  final int? selectedRow;
  final int? selectedCol;
  final List<List<bool>> highlightedCells;
  final List<List<bool>> errorCells;
  final int hintsAvailable;
  final int consecutiveCorrect;
  final int? hintRow;
  final int? hintCol;
  // Cells that just completed a line/col/box (for flash animation)
  final List<List<bool>> completedCells;

  const SudokuInProgress({
    required this.game,
    required this.progress,
    this.selectedRow,
    this.selectedCol,
    required this.highlightedCells,
    required this.errorCells,
    this.hintsAvailable = 3,
    this.consecutiveCorrect = 0,
    this.hintRow,
    this.hintCol,
    this.completedCells = const [],
  });

  SudokuInProgress copyWith({
    SudokuGame? game,
    DifficultyProgress? progress,
    int? selectedRow,
    int? selectedCol,
    List<List<bool>>? highlightedCells,
    List<List<bool>>? errorCells,
    int? hintsAvailable,
    int? consecutiveCorrect,
    int? hintRow,
    int? hintCol,
    bool clearHint = false,
    List<List<bool>>? completedCells,
  }) {
    return SudokuInProgress(
      game: game ?? this.game,
      progress: progress ?? this.progress,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      highlightedCells: highlightedCells ?? this.highlightedCells,
      errorCells: errorCells ?? this.errorCells,
      hintsAvailable: hintsAvailable ?? this.hintsAvailable,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      hintRow: clearHint ? null : (hintRow ?? this.hintRow),
      hintCol: clearHint ? null : (hintCol ?? this.hintCol),
      completedCells: completedCells ?? this.completedCells,
    );
  }

  @override
  List<Object?> get props => [
        game,
        progress,
        selectedRow,
        selectedCol,
        highlightedCells,
        errorCells,
        hintsAvailable,
        consecutiveCorrect,
        hintRow,
        hintCol,
        completedCells,
      ];
}

class SudokuCompleted extends SudokuState {
  final SudokuGame game;
  final int mistakes;
  final DifficultyProgress progress;

  const SudokuCompleted({
    required this.game,
    required this.mistakes,
    required this.progress,
  });

  @override
  List<Object?> get props => [game, mistakes, progress];
}

class SudokuGameOver extends SudokuState {
  final SudokuGame game;
  final DifficultyProgress progress;

  const SudokuGameOver({required this.game, required this.progress});

  @override
  List<Object?> get props => [game, progress];
}
