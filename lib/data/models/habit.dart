class Habit {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final List<DateTime> completedDates;
  final String category;
  final int targetFrequency; // Number of times per week
  final int currentStreak;
  final int longestStreak;
  final String icon;
  final String color;
  final bool isArchived;
  final String userId;

  Habit({
    required this.id,
    required this.title,
    this.description = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isCompleted = false,
    List<DateTime>? completedDates,
    this.category = 'General',
    this.targetFrequency = 7, // Default to daily
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.icon = 'default_icon',
    this.color = 'teal',
    this.isArchived = false,
    required this.userId,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        completedDates = completedDates ?? [];

  // Convert Habit to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'completedDates': completedDates.map((date) => date.toIso8601String()).toList(),
      'category': category,
      'targetFrequency': targetFrequency,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'icon': icon,
      'color': color,
      'isArchived': isArchived,
      'userId': userId,
    };
  }

  // Create Habit from Map
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isCompleted: map['isCompleted'] ?? false,
      completedDates: map['completedDates'] != null
          ? (map['completedDates'] as List).map((date) => DateTime.parse(date)).toList()
          : [],
      category: map['category'] ?? 'General',
      targetFrequency: map['targetFrequency'] ?? 7,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      icon: map['icon'] ?? 'default_icon',
      color: map['color'] ?? 'teal',
      isArchived: map['isArchived'] ?? false,
      userId: map['userId'] ?? '',
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
    String? category,
    int? targetFrequency,
    int? currentStreak,
    int? longestStreak,
    String? icon,
    String? color,
    bool? isArchived,
    String? userId,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDates: completedDates ?? List.from(this.completedDates),
      category: category ?? this.category,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      userId: userId ?? this.userId,
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

  // Check if habit is completed for a specific date
  bool isCompletedForDate(DateTime date) {
    return completedDates.any((d) => _isSameDate(d, date));
  }

  // Helper method to compare dates without time
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
