
class Habit {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final List<DateTime> completedDates;
  final List<bool> completedDays;
  final String category;
  final int targetFrequency; // Number of times per week
  final int currentStreak;
  final int longestStreak;
  final String icon;
  final String color;
  final bool isArchived;
  final String userId;
  final int progress;
  final String? frequency;
  final String? time;
  // New optional time range label (e.g., Anytime, Morning, Afternoon, Evening)
  final String? timeRange;
  // New fields for exact tracking
  final int currentAmount; // raw amount toward target
  final String targetUnit; // unit for target/currentAmount
  // Habit type: true for build, false for quit
  final bool isBuildHabit;

  Habit({
    required this.id,
    required this.title,
    this.description = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isCompleted = false,
    List<DateTime>? completedDates,
    List<bool>? completedDays,
    this.category = 'General',
    this.targetFrequency = 7, // Default to daily
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.icon = 'default_icon',
    this.color = 'teal',
    this.isArchived = false,
    required this.userId,
    this.progress = 0,
    this.frequency,
    this.time,
    this.timeRange,
    this.currentAmount = 0,
    this.targetUnit = 'times',
    this.isBuildHabit = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        completedDates = completedDates ?? [],
        completedDays = completedDays ?? List.filled(7, false);

  // Convert Habit to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'completedDates': completedDates.map((date) => date.toIso8601String()).toList(),
      'completedDays': completedDays,
      'category': category,
      'targetFrequency': targetFrequency,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'icon': icon,
      'color': color,
      'isArchived': isArchived,
      'userId': userId,
      'progress': progress,
      'frequency': frequency,
      'time': time,
      'timeRange': timeRange,
      'currentAmount': currentAmount,
      'targetUnit': targetUnit,
      'isBuildHabit': isBuildHabit,
    };
  }

  // Create Habit from Map
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isCompleted: json['isCompleted'] ?? false,
      completedDates: json['completedDates'] != null
          ? (json['completedDates'] as List).map((date) => DateTime.parse(date)).toList()
          : null,
      completedDays: json['completedDays'] != null
          ? List<bool>.from(json['completedDays'])
          : null,
      category: json['category'] ?? 'General',
      targetFrequency: json['targetFrequency'] ?? 7,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      icon: json['icon'] ?? 'default_icon',
      color: json['color'] ?? 'teal',
      isArchived: json['isArchived'] ?? false,
      userId: json['userId'] ?? '',
      progress: json['progress'] ?? 0,
      frequency: json['frequency'],
      time: json['time'],
      timeRange: json['timeRange'],
      currentAmount: json['currentAmount'] ?? 0,
      targetUnit: json['targetUnit'] ?? 'times',
      isBuildHabit: json['isBuildHabit'] ?? true,
    );
  }

  // Create a copy of the habit with updated fields
  Habit copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    List<DateTime>? completedDates,
    List<bool>? completedDays,
    String? category,
    int? targetFrequency,
    int? currentStreak,
    int? longestStreak,
    String? icon,
    String? color,
    bool? isArchived,
    String? userId,
    int? progress,
    String? frequency,
    String? time,
    String? timeRange,
    int? currentAmount,
    String? targetUnit,
    bool? isBuildHabit,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDates: completedDates ?? List.from(this.completedDates),
      completedDays: completedDays ?? List.from(this.completedDays),
      category: category ?? this.category,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      userId: userId ?? this.userId,
      progress: progress ?? this.progress,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      timeRange: timeRange ?? this.timeRange,
      currentAmount: currentAmount ?? this.currentAmount,
      targetUnit: targetUnit ?? this.targetUnit,
      isBuildHabit: isBuildHabit ?? this.isBuildHabit,
    );
  }

  // Mark habit as completed for a specific date
  Habit markAsCompleted(DateTime date) {
    final updatedDates = List<DateTime>.from(completedDates);
    if (!updatedDates.any((d) => _isSameDate(d, date))) {
      updatedDates.add(date);
    }
    
    // Calculate new streak
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final newStreak = _isSameDate(date, now) || _isSameDate(date, yesterday)
        ? currentStreak + 1
        : 1;
    
    return copyWith(
      completedDates: updatedDates,
      currentStreak: newStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      updatedAt: DateTime.now(),
    );
  }

  // Mark a day as completed
  Habit markDayCompleted(int dayIndex, bool completed) {
    final updatedDays = List<bool>.from(completedDays);
    if (dayIndex >= 0 && dayIndex < updatedDays.length) {
      updatedDays[dayIndex] = completed;
    }
    
    // Calculate new progress
    final completedCount = updatedDays.where((day) => day).length;
    final newProgress = updatedDays.isEmpty ? 0 : ((completedCount / updatedDays.length) * 100).round();
    
    // Calculate new streak
    final newStreak = completed ? currentStreak + 1 : (currentStreak > 0 ? currentStreak - 1 : 0);
    
    return copyWith(
      completedDays: updatedDays,
      progress: newProgress,
      currentStreak: newStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      updatedAt: DateTime.now(),
    );
  }

  // Check if habit is completed for a specific date
  bool isCompletedForDate(DateTime date) {
    return completedDates.any((d) => _isSameDate(d, date));
  }

  // Helper method to compare dates without time
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Calculate progress based on completed days
  int getProgress() {
    if (completedDays.isEmpty) return 0;
    final completedCount = completedDays.where((day) => day).length;
    return ((completedCount / completedDays.length) * 100).round();
  }
}
