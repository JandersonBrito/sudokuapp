import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            border: Border.all(color: Colors.black, width: 2),
          ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SudokuCell extends StatelessWidget {
  final int row;
  final int col;
  final int value;
  final bool isFixed;
  final bool isSelected;
  final bool isHighlighted;
  final bool isError;
  final bool isHint;

  const _SudokuCell({
    required this.row,
    required this.col,
    required this.value,
    required this.isFixed,
    required this.isSelected,
    required this.isHighlighted,
    required this.isError,
    this.isHint = false,
  });

  BorderSide _border(double width) =>
      BorderSide(color: Colors.black, width: width);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    if (isHint) {
      bgColor = Colors.amber.withOpacity(0.45);
    } else if (isSelected) {
      bgColor = theme.colorScheme.primary.withOpacity(0.4);
    } else if (isError) {
      bgColor = Colors.red.withOpacity(0.2);
    } else if (isHighlighted) {
      bgColor = theme.colorScheme.primary.withOpacity(0.12);
    } else {
      bgColor = theme.colorScheme.surface;
    }

    Color textColor;
    if (isError) {
      textColor = Colors.red;
    } else if (isHint) {
      textColor = Colors.amber.shade800;
    } else if (isFixed) {
      textColor = theme.colorScheme.onSurface;
    } else {
      textColor = theme.colorScheme.primary;
    }

    // Thick borders for 3x3 boxes
    final borderTop = row % 3 == 0 ? 1.5 : 0.5;
    final borderLeft = col % 3 == 0 ? 1.5 : 0.5;
    final borderBottom = row == 8 ? 0.0 : (row % 3 == 2 ? 1.5 : 0.5);
    final borderRight = col == 8 ? 0.0 : (col % 3 == 2 ? 1.5 : 0.5);

    return GestureDetector(
      onTap: () {
        context.read<SudokuBloc>().add(SudokuCellSelected(row, col));
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: _border(borderTop),
            left: _border(borderLeft),
            bottom: _border(borderBottom),
            right: _border(borderRight),
          ),
        ),
        child: Center(
          child: value == 0
              ? null
              : Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        isFixed ? FontWeight.bold : FontWeight.normal,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}
