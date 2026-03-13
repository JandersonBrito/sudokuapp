import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/difficulty_progress.dart';

class DifficultyProgressStorage {
  static const _keyVeryEasy = 'sudoku_completions_veryEasy';
  static const _keyEasy = 'sudoku_completions_easy';
  static const _keyMedium = 'sudoku_completions_medium';
  static const _keyHard = 'sudoku_completions_hard';
  static const _keyExpert = 'sudoku_completions_expert';

  Future<DifficultyProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    return DifficultyProgress(
      veryEasyCompletions: prefs.getInt(_keyVeryEasy) ?? 0,
      easyCompletions: prefs.getInt(_keyEasy) ?? 0,
      mediumCompletions: prefs.getInt(_keyMedium) ?? 0,
      hardCompletions: prefs.getInt(_keyHard) ?? 0,
      expertCompletions: prefs.getInt(_keyExpert) ?? 0,
    );
  }

  Future<void> save(DifficultyProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyVeryEasy, progress.veryEasyCompletions);
    await prefs.setInt(_keyEasy, progress.easyCompletions);
    await prefs.setInt(_keyMedium, progress.mediumCompletions);
    await prefs.setInt(_keyHard, progress.hardCompletions);
    await prefs.setInt(_keyExpert, progress.expertCompletions);
  }
}
