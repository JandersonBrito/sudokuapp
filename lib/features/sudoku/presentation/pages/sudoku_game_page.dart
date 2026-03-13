import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/sudoku_bloc.dart';
import '../bloc/sudoku_event.dart';
import '../bloc/sudoku_state.dart';
import '../widgets/sudoku_board.dart';
import '../widgets/sudoku_number_pad.dart';

class SudokuGamePage extends StatelessWidget {
  const SudokuGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SudokuBloc, SudokuState>(
      listener: (context, state) {
        if (state is SudokuCompleted) {
          _showCompletionDialog(context, state);
        } else if (state is SudokuGameOver) {
          _showGameOverDialog(context, state);
        }
      },
      builder: (context, state) {
        if (state is SudokuInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/sudoku');
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is SudokuCompleted || state is SudokuGameOver) {
          return _buildCompletedScaffold(context, state);
        }

        final inProgress = state as SudokuInProgress;
        return Scaffold(
          appBar: AppBar(
            title: Text(inProgress.game.difficulty.label),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.read<SudokuBloc>().add(const SudokuReset());
                context.go('/sudoku');
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    const Icon(Icons.close, size: 18, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '${inProgress.game.mistakes}/3',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                SudokuBoard(state: inProgress),
                const SizedBox(height: 24),
                SudokuNumberPad(
                  onNumber: (n) =>
                      context.read<SudokuBloc>().add(SudokuNumberInput(n)),
                  onClear: () =>
                      context.read<SudokuBloc>().add(const SudokuCellCleared()),
                  onHint: () =>
                      context.read<SudokuBloc>().add(const SudokuHintRequested()),
                  exhaustedNumbers: _exhaustedNumbers(inProgress),
                  hintsAvailable: inProgress.hintsAvailable,
                  consecutiveCorrect: inProgress.consecutiveCorrect,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Set<int> _exhaustedNumbers(SudokuInProgress state) {
    final counts = <int, int>{};
    for (final row in state.game.solution) {
      for (final n in row) {
        counts[n] = (counts[n] ?? 0) + 1;
      }
    }
    final placedCorrectly = <int, int>{};
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final val = state.game.board[r][c];
        if (val != 0 && val == state.game.solution[r][c]) {
          placedCorrectly[val] = (placedCorrectly[val] ?? 0) + 1;
        }
      }
    }
    return {
      for (final entry in counts.entries)
        if ((placedCorrectly[entry.key] ?? 0) >= entry.value) entry.key,
    };
  }

  Widget _buildCompletedScaffold(BuildContext context, SudokuState state) {
    final difficulty = state is SudokuCompleted
        ? state.game.difficulty.label
        : (state as SudokuGameOver).game.difficulty.label;
    return Scaffold(
      appBar: AppBar(title: Text(difficulty)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  void _showGameOverDialog(BuildContext context, SudokuGameOver state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sentiment_very_dissatisfied,
                size: 64, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Você cometeu 3 erros no ${state.game.difficulty.label}.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tente novamente!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SudokuBloc>().add(const SudokuReset());
              context.go('/sudoku');
            },
            child: const Text('Voltar ao Menu'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<SudokuBloc>()
                  .add(SudokuStarted(state.game.difficulty));
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, SudokuCompleted state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Parabéns!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 12),
            Text(
              'Você completou o Sudoku ${state.game.difficulty.label}!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Erros: ${state.mistakes}',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SudokuBloc>().add(const SudokuReset());
              context.go('/sudoku');
            },
            child: const Text('Jogar Novamente'),
          ),
        ],
      ),
    );
  }
}
