import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/sudoku_difficulty.dart';
import '../bloc/sudoku_bloc.dart';
import '../bloc/sudoku_event.dart';

class DifficultySelectionPage extends StatelessWidget {
  const DifficultySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D1A), Color(0xFF0A0A1F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                // Glow icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonPurple.withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.grid_4x4,
                      size: 64,
                      color: AppColors.neonPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.neonPurple, AppColors.neonBlue],
                  ).createShader(bounds),
                  child: const Text(
                    'SUDOKU',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'DO ZÉ IVAN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 48),
                Expanded(
                  child: Column(
                    children: SudokuDifficulty.values
                        .map((d) => _DifficultyCard(difficulty: d))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final SudokuDifficulty difficulty;

  const _DifficultyCard({required this.difficulty});

  Color _neonColor() {
    switch (difficulty) {
      case SudokuDifficulty.veryEasy:
        return AppColors.neonGreen;
      case SudokuDifficulty.easy:
        return AppColors.neonBlue;
      case SudokuDifficulty.medium:
        return AppColors.neonPurple;
      case SudokuDifficulty.hard:
        return AppColors.neonOrange;
      case SudokuDifficulty.expert:
        return AppColors.neonRed;
    }
  }

  IconData _icon() {
    switch (difficulty) {
      case SudokuDifficulty.veryEasy:
        return Icons.sentiment_very_satisfied;
      case SudokuDifficulty.easy:
        return Icons.sentiment_satisfied;
      case SudokuDifficulty.medium:
        return Icons.sentiment_neutral;
      case SudokuDifficulty.hard:
        return Icons.sentiment_dissatisfied;
      case SudokuDifficulty.expert:
        return Icons.whatshot;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _neonColor();
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () {
            context.read<SudokuBloc>().add(SudokuStarted(difficulty));
            context.go('/sudoku/game');
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(_icon(), color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        difficulty.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '${difficulty.cellsToRemove} células vazias',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.7), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
