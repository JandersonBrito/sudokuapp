import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/sudoku/presentation/pages/difficulty_selection_page.dart';
import '../../features/sudoku/presentation/pages/sudoku_game_page.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/sudoku',
    routes: [
      GoRoute(
        path: '/sudoku',
        builder: (context, state) => const DifficultySelectionPage(),
      ),
      GoRoute(
        path: '/sudoku/game',
        builder: (context, state) => const SudokuGamePage(),
      ),
    ],
  );
}
