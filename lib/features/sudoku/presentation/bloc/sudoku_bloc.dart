import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sudoku_game.dart';
import '../../domain/services/sudoku_generator.dart';
import 'sudoku_event.dart';
import 'sudoku_state.dart';

class SudokuBloc extends Bloc<SudokuEvent, SudokuState> {
  SudokuBloc() : super(const SudokuInitial()) {
    on<SudokuStarted>(_onStarted);
    on<SudokuCellSelected>(_onCellSelected);
    on<SudokuNumberInput>(_onNumberInput);
    on<SudokuCellCleared>(_onCellCleared);
    on<SudokuReset>(_onReset);
    on<SudokuHintRequested>(_onHintRequested);
  }

  void _onStarted(SudokuStarted event, Emitter<SudokuState> emit) {
    final game = SudokuGenerator.generate(event.difficulty);
    emit(SudokuInProgress(
      game: game,
      highlightedCells: _emptyGrid(false),
      errorCells: _emptyGrid(false),
    ));
  }

  void _onCellSelected(SudokuCellSelected event, Emitter<SudokuState> emit) {
    if (state is! SudokuInProgress) return;
    final current = state as SudokuInProgress;
    final highlighted = _computeHighlights(current.game, event.row, event.col);

    emit(current.copyWith(
      selectedRow: event.row,
      selectedCol: event.col,
      highlightedCells: highlighted,
      clearHint: true,
    ));
  }

  void _onNumberInput(SudokuNumberInput event, Emitter<SudokuState> emit) {
    if (state is! SudokuInProgress) return;
    final current = state as SudokuInProgress;
    final row = current.selectedRow;
    final col = current.selectedCol;

    if (row == null || col == null) return;
    if (current.game.isFixed[row][col]) return;

    final newBoard = current.game.board
        .map((r) => List<int>.from(r))
        .toList();
    newBoard[row][col] = event.number;

    final isCorrect = current.game.solution[row][col] == event.number;
    final newMistakes = current.game.mistakes + (isCorrect ? 0 : 1);

    final newErrorCells = current.errorCells
        .map((r) => List<bool>.from(r))
        .toList();
    newErrorCells[row][col] = !isCorrect;

    // Consecutive correct streak
    final newStreak = isCorrect ? current.consecutiveCorrect + 1 : 0;
    // Every 5 consecutive correct answers, earn 1 hint (max not capped)
    final earnedHint = isCorrect && newStreak % 5 == 0;
    final newHints = current.hintsAvailable + (earnedHint ? 1 : 0);

    final newGame = current.game.copyWith(
      board: newBoard,
      mistakes: newMistakes,
    );

    if (newMistakes >= 3 && !isCorrect) {
      emit(SudokuGameOver(game: newGame));
      return;
    }

    if (_isBoardComplete(newBoard, newGame.solution)) {
      emit(SudokuCompleted(game: newGame, mistakes: newMistakes));
      return;
    }

    final highlighted = _computeHighlights(newGame, row, col);
    emit(current.copyWith(
      game: newGame,
      selectedRow: row,
      selectedCol: col,
      highlightedCells: highlighted,
      errorCells: newErrorCells,
      hintsAvailable: newHints,
      consecutiveCorrect: newStreak,
      clearHint: true,
    ));
  }

  void _onCellCleared(SudokuCellCleared event, Emitter<SudokuState> emit) {
    if (state is! SudokuInProgress) return;
    final current = state as SudokuInProgress;
    final row = current.selectedRow;
    final col = current.selectedCol;

    if (row == null || col == null) return;
    if (current.game.isFixed[row][col]) return;

    final newBoard = current.game.board
        .map((r) => List<int>.from(r))
        .toList();
    newBoard[row][col] = 0;

    final newErrorCells = current.errorCells
        .map((r) => List<bool>.from(r))
        .toList();
    newErrorCells[row][col] = false;

    final newGame = current.game.copyWith(board: newBoard);
    final highlighted = _computeHighlights(newGame, row, col);

    emit(current.copyWith(
      game: newGame,
      selectedRow: row,
      selectedCol: col,
      highlightedCells: highlighted,
      errorCells: newErrorCells,
      clearHint: true,
    ));
  }

  void _onHintRequested(SudokuHintRequested event, Emitter<SudokuState> emit) {
    if (state is! SudokuInProgress) return;
    final current = state as SudokuInProgress;
    if (current.hintsAvailable <= 0) return;

    // Find all empty or wrong cells
    final emptyCells = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (!current.game.isFixed[r][c] &&
            current.game.board[r][c] != current.game.solution[r][c]) {
          emptyCells.add((r, c));
        }
      }
    }

    if (emptyCells.isEmpty) return;

    // Pick a random cell to reveal
    final pick = emptyCells[Random().nextInt(emptyCells.length)];
    final hintRow = pick.$1;
    final hintCol = pick.$2;
    final correctValue = current.game.solution[hintRow][hintCol];

    final newBoard = current.game.board
        .map((r) => List<int>.from(r))
        .toList();
    newBoard[hintRow][hintCol] = correctValue;

    final newErrorCells = current.errorCells
        .map((r) => List<bool>.from(r))
        .toList();
    newErrorCells[hintRow][hintCol] = false;

    final newGame = current.game.copyWith(board: newBoard);

    if (_isBoardComplete(newBoard, newGame.solution)) {
      emit(SudokuCompleted(game: newGame, mistakes: newGame.mistakes));
      return;
    }

    emit(current.copyWith(
      game: newGame,
      errorCells: newErrorCells,
      hintsAvailable: current.hintsAvailable - 1,
      consecutiveCorrect: 0,
      hintRow: hintRow,
      hintCol: hintCol,
    ));
  }

  void _onReset(SudokuReset event, Emitter<SudokuState> emit) {
    emit(const SudokuInitial());
  }

  List<List<bool>> _computeHighlights(SudokuGame game, int row, int col) {
    final highlighted = _emptyGrid(false);
    final value = game.board[row][col];

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final sameRow = r == row;
        final sameCol = c == col;
        final sameBox =
            (r ~/ 3) == (row ~/ 3) && (c ~/ 3) == (col ~/ 3);
        final sameValue = value != 0 && game.board[r][c] == value;

        if (sameRow || sameCol || sameBox || sameValue) {
          highlighted[r][c] = true;
        }
      }
    }

    return highlighted;
  }

  bool _isBoardComplete(List<List<int>> board, List<List<int>> solution) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }

  List<List<bool>> _emptyGrid(bool value) =>
      List.generate(9, (_) => List.filled(9, value));
}
