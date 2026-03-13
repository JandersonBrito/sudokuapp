import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../presentation/bloc/sudoku_bloc.dart';
import '../../presentation/bloc/sudoku_event.dart';
import '../../presentation/bloc/sudoku_state.dart';

class SudokuBoard extends StatelessWidget {
  final SudokuInProgress state;

  const SudokuBoard({super.key, required this.state});

  bool _isHintCell(int row, int col) =>
      state.hintRow == row && state.hintCol == col;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neonPurple.withOpacity(0.8), width: 2),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonPurple.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                return _SudokuCell(
                  row: row,
                  col: col,
                  value: state.game.board[row][col],
                  isFixed: state.game.isFixed[row][col],
                  isSelected:
                      state.selectedRow == row && state.selectedCol == col,
                  isHighlighted: state.highlightedCells[row][col],
                  isError: state.errorCells[row][col],
                  isHint: _isHintCell(row, col),
                  isCompleted: state.completedCells.isNotEmpty
                      ? state.completedCells[row][col]
                      : false,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SudokuCell extends StatefulWidget {
  final int row;
  final int col;
  final int value;
  final bool isFixed;
  final bool isSelected;
  final bool isHighlighted;
  final bool isError;
  final bool isHint;
  final bool isCompleted;

  const _SudokuCell({
    required this.row,
    required this.col,
    required this.value,
    required this.isFixed,
    required this.isSelected,
    required this.isHighlighted,
    required this.isError,
    this.isHint = false,
    this.isCompleted = false,
  });

  @override
  State<_SudokuCell> createState() => _SudokuCellState();
}

class _SudokuCellState extends State<_SudokuCell>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  late AnimationController _errorFlashController;
  late Animation<double> _errorFlashAnimation;

  late AnimationController _errorPulseController;
  late Animation<double> _errorPulseAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );

    // Flash rápido ao errar
    _errorFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _errorFlashAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _errorFlashController, curve: Curves.easeOut),
    );

    // Pulse suave enquanto a célula estiver com erro
    _errorPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _errorPulseAnimation = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(parent: _errorPulseController, curve: Curves.easeInOut),
    );

    if (widget.isError) {
      _errorPulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_SudokuCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _glowController.forward(from: 0).then((_) => _glowController.reverse());
    }
    if (widget.isError && !oldWidget.isError) {
      _errorFlashController.forward(from: 0).then((_) => _errorFlashController.reverse());
      _errorPulseController.repeat(reverse: true);
    }
    if (!widget.isError && oldWidget.isError) {
      _errorFlashController.stop();
      _errorFlashController.reset();
      _errorPulseController.stop();
      _errorPulseController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _errorFlashController.dispose();
    _errorPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor = AppColors.surfaceVariant;

    // Box borders (3x3)
    final isBoxRight = widget.col % 3 == 2 && widget.col != 8;
    final isBoxBottom = widget.row % 3 == 2 && widget.row != 8;

    if (widget.isHint) {
      bgColor = AppColors.neonBlue.withOpacity(0.25);
      textColor = AppColors.neonBlue;
    } else if (widget.isSelected) {
      bgColor = AppColors.neonPurple.withOpacity(0.35);
      textColor = Colors.white;
    } else if (widget.isError) {
      bgColor = AppColors.neonRed.withOpacity(0.2);
      textColor = AppColors.neonRed;
    } else if (widget.isHighlighted) {
      bgColor = AppColors.neonPurple.withOpacity(0.1);
      textColor = widget.isFixed ? AppColors.textPrimary : AppColors.neonPurple;
    } else {
      bgColor = AppColors.surface;
      textColor = widget.isFixed ? AppColors.textPrimary : AppColors.neonPurple;
    }

    if (widget.isError) borderColor = AppColors.neonRed.withOpacity(0.4);
    if (widget.isSelected) borderColor = AppColors.neonPurple.withOpacity(0.6);
    if (widget.isHint) borderColor = AppColors.neonBlue.withOpacity(0.6);

    final thinBorder = BorderSide(color: AppColors.surfaceVariant, width: 0.5);
    final thickBorder = BorderSide(color: AppColors.neonPurple.withOpacity(0.5), width: 1.5);

    return GestureDetector(
      onTap: () {
        context.read<SudokuBloc>().add(SudokuCellSelected(widget.row, widget.col));
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowAnimation, _errorFlashAnimation, _errorPulseAnimation]),
        builder: (context, child) {
          final glow = _glowAnimation.value;
          final errFlash = _errorFlashAnimation.value;
          final errPulse = widget.isError ? _errorPulseAnimation.value : 0.0;

          // Flash sobrepõe o pulse no momento do erro
          final errIntensity = errFlash > errPulse ? errFlash : errPulse;

          Color finalBg = bgColor;
          if (glow > 0) {
            finalBg = Color.lerp(bgColor, AppColors.neonGreen.withOpacity(0.35), glow)!;
          } else if (errIntensity > 0) {
            finalBg = Color.lerp(bgColor, AppColors.neonRed.withOpacity(0.5), errIntensity)!;
          }

          List<BoxShadow>? shadows;
          if (glow > 0) {
            shadows = [
              BoxShadow(
                color: AppColors.neonGreen.withOpacity(0.6 * glow),
                blurRadius: 12 * glow,
                spreadRadius: 2 * glow,
              ),
            ];
          } else if (errIntensity > 0) {
            shadows = [
              BoxShadow(
                color: AppColors.neonRed.withOpacity(0.7 * errIntensity),
                blurRadius: 14 * errIntensity,
                spreadRadius: 2 * errIntensity,
              ),
            ];
          } else if (widget.isSelected || widget.isHint) {
            shadows = [
              BoxShadow(
                color: (widget.isHint ? AppColors.neonBlue : AppColors.neonPurple)
                    .withOpacity(0.3),
                blurRadius: 6,
              ),
            ];
          }

          Color finalTextColor = textColor;
          if (glow > 0) {
            finalTextColor = Color.lerp(textColor, AppColors.neonGreen, glow * 0.7)!;
          } else if (errFlash > 0) {
            finalTextColor = Color.lerp(textColor, Colors.white, errFlash * 0.5)!;
          }

          return Container(
            decoration: BoxDecoration(
              color: finalBg,
              border: Border(
                top: widget.row % 3 == 0 ? thickBorder : thinBorder,
                left: widget.col % 3 == 0 ? thickBorder : thinBorder,
                bottom: isBoxBottom ? thickBorder : (widget.row == 8 ? BorderSide.none : thinBorder),
                right: isBoxRight ? thickBorder : (widget.col == 8 ? BorderSide.none : thinBorder),
              ),
              boxShadow: shadows,
            ),
            child: Center(
              child: widget.value == 0
                  ? null
                  : Text(
                      '${widget.value}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: widget.isFixed ? FontWeight.bold : FontWeight.w600,
                        color: finalTextColor,
                        shadows: widget.isHint || widget.isSelected || glow > 0 || errIntensity > 0
                            ? [
                                Shadow(
                                  color: (glow > 0
                                          ? AppColors.neonGreen
                                          : errIntensity > 0
                                              ? AppColors.neonRed
                                              : textColor)
                                      .withOpacity(
                                        glow > 0 ? glow : errIntensity > 0 ? errIntensity : 0.8,
                                      ),
                                  blurRadius: glow > 0
                                      ? 12 * glow
                                      : errIntensity > 0
                                          ? 10 * errIntensity
                                          : 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
