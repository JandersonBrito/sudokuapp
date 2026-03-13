import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/sudoku_difficulty.dart';
import '../bloc/sudoku_bloc.dart';
import '../bloc/sudoku_event.dart';

class DifficultySelectionPage extends StatelessWidget {
  const DifficultySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.grid_4x4,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Sudoku',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha a dificuldade',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              ...SudokuDifficulty.values.map(
                (difficulty) => _DifficultyCard(difficulty: difficulty),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final SudokuDifficulty difficulty;

  const _DifficultyCard({required this.difficulty});

  Color _color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (difficulty) {
      case SudokuDifficulty.veryEasy:
        return Colors.green;
      case SudokuDifficulty.easy:
        return Colors.lightGreen;
      case SudokuDifficulty.medium:
        return scheme.primary;
      case SudokuDifficulty.hard:
        return Colors.orange;
      case SudokuDifficulty.expert:
        return Colors.red;
    }
  }

  String _description() {
    switch (difficulty) {
      case SudokuDifficulty.veryEasy:
        return '${difficulty.cellsToRemove} células vazias';
      case SudokuDifficulty.easy:
        return '${difficulty.cellsToRemove} células vazias';
      case SudokuDifficulty.medium:
        return '${difficulty.cellsToRemove} células vazias';
      case SudokuDifficulty.hard:
        return '${difficulty.cellsToRemove} células vazias';
      case SudokuDifficulty.expert:
        return '${difficulty.cellsToRemove} células vazias';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          context.read<SudokuBloc>().add(SudokuStarted(difficulty));
          context.go('/sudoku/game');
        },
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  difficulty.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _description(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
