import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/sudoku_difficulty.dart';
import '../bloc/sudoku_bloc.dart';
import '../bloc/sudoku_event.dart';
import '../bloc/sudoku_state.dart';

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
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
                const SizedBox(height: 32),
                BlocBuilder<SudokuBloc, SudokuState>(
                  builder: (context, state) {
                    final progress = state is SudokuInitial
                        ? state.progress
                        : state is SudokuInProgress
                            ? state.progress
                            : state is SudokuCompleted
                                ? state.progress
                                : state is SudokuGameOver
                                    ? state.progress
                                    : null;

                    return Column(
                      children: SudokuDifficulty.values
                          .map((d) => _DifficultyCard(
                                difficulty: d,
                                unlocked: progress?.isUnlocked(d) ??
                                    d == SudokuDifficulty.veryEasy,
                                currentCount: progress?.currentCompletions(d) ?? 0,
                                requiredCount: progress?.requiredCompletions(d) ?? 0,
                                prerequisite: progress?.prerequisite(d),
                              ))
                          .toList(),
                    );
                  },
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
  final bool unlocked;
  final int currentCount;
  final int requiredCount;
  final SudokuDifficulty? prerequisite;

  const _DifficultyCard({
    required this.difficulty,
    required this.unlocked,
    required this.currentCount,
    required this.requiredCount,
    required this.prerequisite,
  });

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

  String _unlockHint() {
    if (prerequisite == null) return '';
    final remaining = requiredCount - currentCount;
    if (remaining <= 0) return '';
    final preLabel = prerequisite!.label;
    return 'Complete $preLabel $remaining vez${remaining == 1 ? '' : 'es'} para desbloquear';
  }

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? _neonColor() : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 72,
        child: GestureDetector(
          onTap: unlocked
              ? () {
                  context.read<SudokuBloc>().add(SudokuStarted(difficulty));
                  context.go('/sudoku/game');
                }
              : () => _showLockedDialog(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.surfaceVariant
                  : AppColors.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: color.withOpacity(unlocked ? 0.5 : 0.2), width: 1.5),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // Icon or lock
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(unlocked ? 0.15 : 0.08),
                    boxShadow: unlocked
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    unlocked ? _icon() : Icons.lock,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Labels
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
                      if (unlocked)
                        Text(
                          '${difficulty.cellsToRemove} células vazias',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            letterSpacing: 1,
                          ),
                        )
                      else
                        Text(
                          _unlockHint(),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Right side: progress bar or arrow
                if (!unlocked)
                  _ProgressBadge(
                    current: currentCount,
                    required: requiredCount,
                    color: color,
                  )
                else
                  Icon(Icons.arrow_forward_ios,
                      color: color.withOpacity(0.7), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context) {
    final color = _neonColor();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:
              BorderSide(color: AppColors.neonOrange.withOpacity(0.6), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonOrange.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonOrange.withOpacity(0.3),
                      blurRadius: 16,
                    )
                  ],
                ),
                child: const Icon(Icons.lock,
                    size: 32, color: AppColors.neonOrange),
              ),
              const SizedBox(height: 16),
              Text(
                difficulty.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _unlockHint(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              // Progress bar in dialog
              _ProgressBadge(
                current: currentCount,
                required: requiredCount,
                color: color,
                showText: true,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.neonPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.neonPurple.withOpacity(0.6),
                        width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: AppColors.neonPurple,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int current;
  final int required;
  final Color color;
  final bool showText;

  const _ProgressBadge({
    required this.current,
    required this.required,
    required this.color,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = (current / required).clamp(0.0, 1.0);
    if (showText) {
      return Column(
        children: [
          Text(
            '$current / $required',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clamped,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      );
    }

    // Compact version for card trailing
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$current/$required',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 48,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: clamped,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ),
      ],
    );
  }
}
