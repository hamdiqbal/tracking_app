import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_controller.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_progress_model.dart';
import '../../data/models/history_entry.dart';
import '../../data/services/firebase_service.dart';
import '../../data/constants/predefined_habits.dart';
import '../../presentation/widgets/app_snackbar.dart';

class HabitController extends GetxController {
  final FirebaseService _firebaseService = Get.find();
  final AuthController _authController = Get.find();
  final _uuid = const Uuid();
  StreamSubscription<List<Habit>>? _habitsSub;
  StreamSubscription<User?>? _authSub;
  
  final RxList<Habit> habits = <Habit>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<Habit?> selectedHabit = Rx<Habit?>(null);
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxMap<String, List<HabitProgress>> habitProgressMap = <String, List<HabitProgress>>{}.obs;
  final RxMap<String, Map<String, dynamic>> habitStatsMap = <String, Map<String, dynamic>>{}.obs;
  final RxList<HistoryEntry> historyEntries = <HistoryEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHabits();
    _setupHabitsListener();
    _runMigration();
    _loadHistoryAndPrune();
    // Re-subscribe when auth state changes so we switch from anonymous to real UID
    _authSub = _authController.authStateChanges.listen((_) {
      _setupHabitsListener();
      loadHabits();
      _loadHistoryAndPrune();
    });
  }

  void _setupHabitsListener() {
    // Cancel previous subscription if any
    _habitsSub?.cancel();
    _habitsSub = _firebaseService.habitsStream().listen((habitsList) {
      habits.assignAll(habitsList);
    });
  }

  // Get habits for the selected date
  List<Habit> get habitsForSelectedDate {
    return habits.where((habit) {
      // Return habits that are either due on this date or have been completed on this date
      return habit.isCompletedForDate(selectedDate.value);
    }).toList();
  }

  // Get habits by category
  Map<String, List<Habit>> get habitsByCategory {
    final Map<String, List<Habit>> result = {};
    
    for (final habit in habits) {
      if (habit.isArchived) continue;
      
      result.putIfAbsent(habit.category, () => []).add(habit);
    }
    
    return result;
  }

  // Load all habits
  Future<void> loadHabits() async {
    try {
      isLoading.value = true;
      final result = await _firebaseService.getAllHabits();
      habits.assignAll(result);
    } catch (e) {
      showTopSnack('Error', 'Failed to load habits: ${e.toString()}', type: SnackType.error);
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new habit
  Future<bool> createHabit(Habit habit) async {
    try {
      final id = await _firebaseService.createHabit(habit);
      if (id.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      showTopSnack('Error', 'Failed to create habit: ${e.toString()}', type: SnackType.error);
      return false;
    }
  }

  // Update an existing habit
  Future<bool> updateHabit(Habit habit) async {
    try {
      return await _firebaseService.updateHabit(habit);
    } catch (e) {
      showTopSnack('Error', 'Failed to update habit: ${e.toString()}', type: SnackType.error);
      return false;
    }
  }

  // Delete a habit
  Future<bool> deleteHabit(String id) async {
    try {
      // Fetch habit to create history entry
      final habit = await _firebaseService.getHabitById(id);
      if (habit != null) {
        final entry = HistoryEntry(
          id: '${habit.id}_${DateTime.now().millisecondsSinceEpoch}',
          habitId: habit.id,
          title: habit.title,
          category: habit.category,
          startDate: habit.createdAt,
          endDate: DateTime.now(),
          userId: _firebaseService.currentUserId,
        );
        await _firebaseService.addHistoryEntry(entry);
      }

      final ok = await _firebaseService.deleteHabit(id);
      if (ok) {
        await _loadHistoryAndPrune();
      }
      return ok;
    } catch (e) {
      showTopSnack('Error', 'Failed to delete habit: ${e.toString()}', type: SnackType.error);
      return false;
    }
  }

  // Restore a habit by its original ID (used for UNDO)
  Future<bool> restoreHabit(Habit habit) async {
    try {
      return await _firebaseService.restoreHabit(habit);
    } catch (e) {
      showTopSnack('Error', 'Failed to restore habit: ${e.toString()}', type: SnackType.error);
      return false;
    }
  }

  // Toggle habit completion for a specific date
  Future<bool> toggleHabitCompletion(String habitId, DateTime date) async {
    try {
      final isCompleted = await _firebaseService.isHabitCompletedOnDate(habitId, date);
      final success = await _firebaseService.recordHabitProgress(habitId, date, !isCompleted);
      
      if (success) {
        await loadHabitProgress(habitId);
        await loadHabitStats(habitId);
      }
      
      return success;
    } catch (e) {
      showTopSnack('Error', 'Failed to update habit completion: ${e.toString()}', type: SnackType.error);
      return false;
    }
  }

  // Load progress for a habit (last 30 days)
  Future<void> loadHabitProgress(String habitId) async {
    try {
      final progress = await _firebaseService.getLast30DaysProgress(habitId);
      habitProgressMap[habitId] = progress;
    } catch (_) {}
  }

  // Load aggregate stats for a habit
  Future<void> loadHabitStats(String habitId) async {
    try {
      final stats = await _firebaseService.getHabitStats(habitId);
      habitStatsMap[habitId] = stats;
    } catch (_) {}
  }

  // Helper
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void selectHabit(Habit? habit) {
    selectedHabit.value = habit;
  }

  // Run one-time compatible migration to backfill exact fields
  void _runMigration() async {
    try {
      await _firebaseService.migrateExactFields();
    } catch (_) {}
  }

  Future<void> _loadHistoryAndPrune() async {
    try {
      // prune first
      await _firebaseService.pruneHistoryOlderThan30Days();
      // then load
      final entries = await _firebaseService.getLast30DaysHistory();
      historyEntries.assignAll(entries);
    } catch (_) {}
  }

  Future<void> refreshHistory() async {
    await _loadHistoryAndPrune();
  }

  // Get habits for a specific day of the week
  List<Habit> getHabitsForDay(int dayIndex) {
    return habits.where((habit) {
      return dayIndex < habit.completedDays.length && habit.completedDays[dayIndex];
    }).toList();
  }

  // Get habits by frequency
  List<Habit> getHabitsByFrequency(String frequency) {
    return habits.where((habit) => habit.frequency == frequency).toList();
  }

  // Get habits with progress above a certain threshold
  List<Habit> getHabitsWithProgressAbove(int threshold) {
    return habits.where((habit) => habit.progress >= threshold).toList();
  }

  // Get current streak for a habit
  int getCurrentStreak(String habitId) {
    final habit = habits.firstWhereOrNull((h) => h.id == habitId);
    return habit?.currentStreak ?? 0;
  }

  // Calculate completion rate for a habit
  double getCompletionRate(String habitId) {
    final habit = habits.firstWhereOrNull((h) => h.id == habitId);
    if (habit == null || habit.completedDays.isEmpty) return 0.0;
    
    final completed = habit.completedDays.where((day) => day).length;
    return completed / habit.completedDays.length;
  }

  // Get the most recent completed date for a habit
  DateTime? getLastCompletedDate(String habitId) {
    final habit = habits.firstWhereOrNull((h) => h.id == habitId);
    if (habit == null || habit.completedDates.isEmpty) return null;
    return habit.completedDates.reduce((a, b) => a.isAfter(b) ? a : b);
    
    for (int i = habit.completedDays.length - 1; i >= 0; i--) {
      if (habit.completedDays[i]) {
        return DateTime.now().subtract(Duration(days: habit.completedDays.length - 1 - i));
      }
    }
    return null;
  }

  // Check if a habit is due today
  bool isHabitDueToday(String habitId) {
    final habit = habits.firstWhereOrNull((h) => h.id == habitId);
    if (habit == null) return false;
    
    final today = DateTime.now();
    final lastCompleted = getLastCompletedDate(habitId);
    
    // If never completed, it's due today if frequency matches
    if (lastCompleted == null) return true;
    
    // Check if already completed today
    if (_isSameDate(lastCompleted, today)) return false;
    
    // Check frequency
    switch (habit.frequency) {
      case 'Daily':
        return true;
      case 'Weekdays':
        return today.weekday >= DateTime.monday && today.weekday <= DateTime.friday;
      case 'Weekends':
        return today.weekday == DateTime.saturday || today.weekday == DateTime.sunday;
      case 'Weekly':
        final daysSinceLastCompletion = today.difference(lastCompleted).inDays;
        return daysSinceLastCompletion >= 7;
      default:
        return false;
    }
  }
}
