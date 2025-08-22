import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/habit_model.dart';
import '../models/habit_progress_model.dart';

class FirebaseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? 'anonymous';

  // Collections
  CollectionReference get habitsCollection => 
      _firestore.collection('users').doc(currentUserId).collection('habits');
  
  CollectionReference get progressCollection => 
      _firestore.collection('users').doc(currentUserId).collection('progress');

  // HABIT OPERATIONS
  
  /// Create a new habit
  Future<String> createHabit(Habit habit) async {
    try {
      final docRef = await habitsCollection.add(habit.toJson());
      
      // Update the habit with the generated ID
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create habit: $e');
    }
  }

  /// Restore a habit document by its original ID (used for UNDO)
  Future<bool> restoreHabit(Habit habit) async {
    try {
      await habitsCollection.doc(habit.id).set(habit.toJson());
      return true;
    } catch (e) {
      throw Exception('Failed to restore habit: $e');
    }
  }

  /// Get all habits for current user
  Future<List<Habit>> getAllHabits() async {
    try {
      final snapshot = await habitsCollection
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Habit.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get habits: $e');
    }
  }

  /// Update an existing habit
  Future<bool> updateHabit(Habit habit) async {
    try {
      await habitsCollection.doc(habit.id).update(habit.toJson());
      return true;
    } catch (e) {
      throw Exception('Failed to update habit: $e');
    }
  }

  /// Delete a habit and all related progress (hard delete)
  Future<bool> deleteHabit(String habitId) async {
    try {
      // Begin batch
      final batch = _firestore.batch();

      // Delete habit document
      final habitDoc = habitsCollection.doc(habitId);
      batch.delete(habitDoc);

      // Delete all progress documents for this habit
      final progressSnap = await progressCollection
          .where('habitId', isEqualTo: habitId)
          .get();
      for (final doc in progressSnap.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      throw Exception('Failed to delete habit: $e');
    }
  }

  /// Get habit by ID
  Future<Habit?> getHabitById(String habitId) async {
    try {
      final doc = await habitsCollection.doc(habitId).get();
      if (doc.exists) {
        return Habit.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get habit: $e');
    }
  }

  // PROGRESS OPERATIONS

  /// Record habit completion for a specific date
  Future<bool> recordHabitProgress(String habitId, DateTime date, bool completed) async {
    try {
      final progressId = '${habitId}_${_formatDate(date)}';
      
      final progressData = HabitProgress(
        id: progressId,
        habitId: habitId,
        date: date,
        completed: completed,
        userId: currentUserId,
      );

      await progressCollection.doc(progressId).set(progressData.toJson());
      
      // Update habit streak and stats
      await _updateHabitStats(habitId);
      
      return true;
    } catch (e) {
      throw Exception('Failed to record progress: $e');
    }
  }

  /// Get progress for a specific habit
  Future<List<HabitProgress>> getHabitProgress(String habitId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      Query query = progressCollection.where('habitId', isEqualTo: habitId);
      
      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      
      final snapshot = await query.orderBy('date', descending: true).get();
      
      return snapshot.docs
          .map((doc) => HabitProgress.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get habit progress: $e');
    }
  }

  /// Get progress for last 30 days for a specific habit
  Future<List<HabitProgress>> getLast30DaysProgress(String habitId) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    
    return getHabitProgress(habitId, startDate: startDate, endDate: endDate);
  }

  /// Check if habit is completed for a specific date
  Future<bool> isHabitCompletedOnDate(String habitId, DateTime date) async {
    try {
      final progressId = '${habitId}_${_formatDate(date)}';
      final doc = await progressCollection.doc(progressId).get();
      
      if (doc.exists) {
        final progress = HabitProgress.fromJson(doc.data() as Map<String, dynamic>);
        return progress.completed;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get all progress for a specific date (for calendar view)
  Future<Map<String, bool>> getProgressForDate(DateTime date) async {
    try {
      final dateStr = _formatDate(date);
      final snapshot = await progressCollection
          .where('date', isEqualTo: Timestamp.fromDate(date))
          .get();
      
      final Map<String, bool> progressMap = {};
      
      for (final doc in snapshot.docs) {
        final progress = HabitProgress.fromJson(doc.data() as Map<String, dynamic>);
        progressMap[progress.habitId] = progress.completed;
      }
      
      return progressMap;
    } catch (e) {
      throw Exception('Failed to get progress for date: $e');
    }
  }

  // ANALYTICS & STATS

  /// Calculate and update habit statistics
  Future<void> _updateHabitStats(String habitId) async {
    try {
      final habit = await getHabitById(habitId);
      if (habit == null) return;

      // Get last 30 days progress
      final progress = await getLast30DaysProgress(habitId);
      
      // Calculate current streak
      int currentStreak = 0;
      final today = DateTime.now();
      
      for (int i = 0; i < 30; i++) {
        final checkDate = today.subtract(Duration(days: i));
        final dayProgress = progress.firstWhereOrNull(
          (p) => _isSameDate(p.date, checkDate)
        );
        
        if (dayProgress?.completed == true) {
          currentStreak++;
        } else {
          break;
        }
      }

      // Calculate longest streak
      int longestStreak = 0;
      int tempStreak = 0;
      
      final sortedProgress = progress..sort((a, b) => a.date.compareTo(b.date));
      
      for (final p in sortedProgress) {
        if (p.completed) {
          tempStreak++;
          longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        } else {
          tempStreak = 0;
        }
      }

      // Update habit with new stats
      final updatedHabit = habit.copyWith(
        currentStreak: currentStreak,
        longestStreak: longestStreak > habit.longestStreak ? longestStreak : habit.longestStreak,
        updatedAt: DateTime.now(),
      );

      await updateHabit(updatedHabit);
    } catch (e) {
      print('Error updating habit stats: $e');
    }
  }

  /// Get habit completion statistics
  Future<Map<String, dynamic>> getHabitStats(String habitId) async {
    try {
      final progress = await getLast30DaysProgress(habitId);
      final completedDays = progress.where((p) => p.completed).length;
      final totalDays = progress.length;
      final completionRate = totalDays > 0 ? (completedDays / totalDays) * 100 : 0.0;

      return {
        'completedDays': completedDays,
        'totalDays': totalDays,
        'completionRate': completionRate,
        'currentStreak': await _getCurrentStreak(habitId),
      };
    } catch (e) {
      return {
        'completedDays': 0,
        'totalDays': 0,
        'completionRate': 0.0,
        'currentStreak': 0,
      };
    }
  }

  Future<int> _getCurrentStreak(String habitId) async {
    try {
      final habit = await getHabitById(habitId);
      return habit?.currentStreak ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // UTILITY METHODS

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // REAL-TIME LISTENERS

  /// Listen to habit changes
  Stream<List<Habit>> habitsStream() {
    return habitsCollection
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Habit.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Listen to progress changes for a specific habit
  Stream<List<HabitProgress>> habitProgressStream(String habitId) {
    return progressCollection
        .where('habitId', isEqualTo: habitId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HabitProgress.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // DATA MIGRATION
  /// Backfill exact fields for existing habits: currentAmount and targetUnit
  Future<int> migrateExactFields() async {
    int updated = 0;
    try {
      final snapshot = await habitsCollection.get();
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final hasCurrentAmount = data.containsKey('currentAmount');
        final hasTargetUnit = data.containsKey('targetUnit');
        if (hasCurrentAmount && hasTargetUnit) continue;

        final category = (data['category'] ?? 'General').toString();
        final target = (data['targetFrequency'] ?? 0) is int
            ? data['targetFrequency'] as int
            : int.tryParse('${data['targetFrequency']}') ?? 0;
        final progress = (data['progress'] ?? 0) is int
            ? data['progress'] as int
            : int.tryParse('${data['progress']}') ?? 0;

        final unit = hasTargetUnit ? data['targetUnit'] as String : _unitForCategory(category);
        final amount = hasCurrentAmount ? (data['currentAmount'] ?? 0) as int : ((target * progress) / 100).round();

        await doc.reference.update({
          'currentAmount': amount,
          'targetUnit': unit,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        updated++;
      }
    } catch (e) {
      print('Migration error: $e');
    }
    return updated;
  }

  String _unitForCategory(String category) {
    final c = category.toLowerCase();
    if (c == 'running') return 'km';
    if (c == 'walking') return 'meters';
    if (c == 'smoking') return 'days';
    if (c == 'yoga') return 'hours';
    if (c == 'drinking') return 'liters';
    if (c == 'sleeping') return 'hours';
    if (c == 'exercise') return 'hours';
    if (c == 'playing') return 'hours';
    if (c == 'reading') return 'hours';
    if (c == 'meditation') return 'hours';
    if (c == 'study') return 'hours';
    if (c == 'diet') return 'days';
    return 'times';
  }
}

