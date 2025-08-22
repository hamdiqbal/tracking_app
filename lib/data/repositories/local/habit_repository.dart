import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../models/habit_model.dart';
import '../base_repository.dart';

class HabitRepository extends BaseRepository<Habit> {
  final _habits = <Habit>[].obs;
  final _uuid = const Uuid();

  @override
  Future<List<Habit>> getAll() async {
    return List<Habit>.from(_habits);
  }

  @override
  Future<Habit?> getById(String id) async {
    try {
      return _habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> create(Habit habit) async {
    final newHabit = habit.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _habits.add(newHabit);
    return newHabit.id;
  }

  @override
  Future<bool> update(Habit updatedHabit) async {
    try {
      final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (index != -1) {
        _habits[index] = updatedHabit.copyWith(updatedAt: DateTime.now());
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      final initialLength = _habits.length;
      _habits.removeWhere((habit) => habit.id == id);
      return _habits.length < initialLength;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clear() async {
    _habits.clear();
  }

  // Additional methods specific to Habit repository
  Future<List<Habit>> getHabitsForDay(DateTime date) async {
    // This is a simplified example - in a real app, you'd filter by date
    return _habits.where((habit) => habit.completedDays[date.weekday % 7]).toList();
  }

  Future<bool> toggleHabitCompletion(String habitId, int dayIndex) async {
    try {
      final habit = await getById(habitId);
      if (habit != null) {
        final updatedHabit = habit.markDayCompleted(dayIndex, !habit.completedDays[dayIndex]);
        return await update(updatedHabit);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
