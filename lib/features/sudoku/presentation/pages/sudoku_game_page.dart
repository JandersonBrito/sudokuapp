import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
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
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (state is SudokuCompleted || state is SudokuGameOver) {
          return _buildCompletedScaffold(context, state);
        }

        final inProgress = state as SudokuInProgress;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.neonPurple, AppColors.neonBlue],
              ).createShader(bounds),
              child: Text(
                inProgress.game.difficulty.label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  fontSize: 16,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () {
                context.read<SudokuBloc>().add(const SudokuReset());
                context.go('/sudoku');
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: List.generate(3, (i) {
                    final filled = i < inProgress.game.mistakes;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        filled ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: filled
                            ? AppColors.neonRed
                            : AppColors.textSecondary,
                        shadows: filled
                            ? [
                                Shadow(
                                  color: AppColors.neonRed.withOpacity(0.7),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.background, Color(0xFF0A0A1F)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  SudokuBoard(state: inProgress),
                  const SizedBox(height: 20),
                  SudokuNumberPad(
                    onNumber: (n) =>
                        context.read<SudokuBloc>().add(SudokuNumberInput(n)),
                    onClear: () => context
                        .read<SudokuBloc>()
                        .add(const SudokuCellCleared()),
                    onHint: () => context
                        .read<SudokuBloc>()
                        .add(const SudokuHintRequested()),
                    exhaustedNumbers: _exhaustedNumbers(inProgress),
                    hintsAvailable: inProgress.hintsAvailable,
                    consecutiveCorrect: inProgress.consecutiveCorrect,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(difficulty),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  void _showGameOverDialog(BuildContext context, SudokuGameOver state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonRed.withOpacity(0.6), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonRed.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonRed.withOpacity(0.4),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: const Icon(Icons.close, size: 40, color: AppColors.neonRed),
              ),
              const SizedBox(height: 16),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonRed,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Você cometeu 3 erros no ${state.game.difficulty.label}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: 'Menu',
                      color: AppColors.textSecondary,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.read<SudokuBloc>().add(const SudokuReset());
                        context.go('/sudoku');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DialogButton(
                      label: 'Tentar Novamente',
                      color: AppColors.neonPurple,
                      onTap: () {
                        Navigator.of(context).pop();
                        context
                            .read<SudokuBloc>()
                            .add(SudokuStarted(state.game.difficulty));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, SudokuCompleted state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonGreen.withOpacity(0.6), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonGreen.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withOpacity(0.4),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: const Icon(Icons.emoji_events, size: 40, color: AppColors.neonGreen),
              ),
              const SizedBox(height: 16),
              const Text(
                'PARABÉNS!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonGreen,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Você completou o ${state.game.difficulty.label}!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.close, size: 14, color: AppColors.neonRed),
                  const SizedBox(width: 4),
                  Text(
                    '${state.mistakes} erro${state.mistakes != 1 ? 's' : ''}',
                    style: const TextStyle(color: AppColors.neonRed, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DialogButton(
                label: 'Jogar Novamente',
                color: AppColors.neonPurple,
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<SudokuBloc>().add(const SudokuReset());
                  context.go('/sudoku');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.2), blurRadius: 8),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
