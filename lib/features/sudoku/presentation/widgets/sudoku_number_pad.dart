import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SudokuNumberPad extends StatelessWidget {
  final void Function(int) onNumber;
  final VoidCallback onClear;
  final VoidCallback onHint;
  final Set<int> exhaustedNumbers;
  final int hintsAvailable;
  final int consecutiveCorrect;

  const SudokuNumberPad({
    super.key,
    required this.onNumber,
    required this.onClear,
    required this.onHint,
    this.exhaustedNumbers = const {},
    this.hintsAvailable = 0,
    this.consecutiveCorrect = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(9, (i) {
              final n = i + 1;
              final disabled = exhaustedNumbers.contains(n);
              return _NumberButton(
                number: n,
                onTap: disabled ? null : () => onNumber(n),
                disabled: disabled,
              );
            }),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _NeonButton(
                  onPressed: onClear,
                  color: AppColors.neonPink,
                  icon: Icons.backspace_outlined,
                  label: 'Apagar',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HintButton(
                  hintsAvailable: hintsAvailable,
                  consecutiveCorrect: consecutiveCorrect,
                  onHint: onHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final VoidCallback? onTap;
  final bool disabled;

  const _NumberButton({
    required this.number,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = disabled ? AppColors.textSecondary.withOpacity(0.3) : AppColors.neonPurple;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 50,
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.surfaceVariant.withOpacity(0.4)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.2),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.neonPurple.withOpacity(0.25),
                    blurRadius: 8,
                  )
                ],
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: disabled
                  ? AppColors.textSecondary.withOpacity(0.3)
                  : AppColors.textPrimary,
              shadows: disabled
                  ? null
                  : [
                      Shadow(
                        color: AppColors.neonPurple.withOpacity(0.6),
                        blurRadius: 6,
                      )
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NeonButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final IconData icon;
  final String label;

  const _NeonButton({
    required this.onPressed,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  final int hintsAvailable;
  final int consecutiveCorrect;
  final VoidCallback onHint;

  const _HintButton({
    required this.hintsAvailable,
    required this.consecutiveCorrect,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = hintsAvailable <= 0;
    final color = disabled ? AppColors.textSecondary.withOpacity(0.3) : AppColors.neonBlue;
    final remaining = 5 - (consecutiveCorrect % 5);
    final nearEarning = consecutiveCorrect > 0 && remaining <= 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: disabled ? null : onHint,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 1.5),
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.neonBlue.withOpacity(0.25),
                        blurRadius: 10,
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outline, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Dica ($hintsAvailable)',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (nearEarning)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.neonGreen,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                '+1 em $remaining',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
