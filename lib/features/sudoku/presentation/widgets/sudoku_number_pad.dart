import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              9,
              (i) {
                final n = i + 1;
                final disabled = exhaustedNumbers.contains(n);
                return _NumberButton(
                  number: n,
                  onTap: disabled ? null : () => onNumber(n),
                  disabled: disabled,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.backspace_outlined),
                  label: const Text('Apagar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: theme.colorScheme.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
    final theme = Theme.of(context);
    final bgColor = disabled
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.primaryContainer;
    final textColor = disabled
        ? theme.colorScheme.onSurface.withOpacity(0.35)
        : theme.colorScheme.onPrimaryContainer;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
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
    final theme = Theme.of(context);
    final disabled = hintsAvailable <= 0;
    final remaining = 5 - (consecutiveCorrect % 5);
    final nearEarning = consecutiveCorrect > 0 && remaining <= 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        OutlinedButton.icon(
          onPressed: disabled ? null : onHint,
          icon: Icon(
            Icons.lightbulb_outline,
            color: disabled ? null : Colors.amber.shade700,
          ),
          label: Text(
            'Dica ($hintsAvailable)',
            style: TextStyle(
              color: disabled ? null : Colors.amber.shade700,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(
              color: disabled
                  ? theme.colorScheme.outline.withOpacity(0.4)
                  : Colors.amber.shade400,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (nearEarning)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+1 em $remaining',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
