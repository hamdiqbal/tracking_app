import 'package:cloud_firestore/cloud_firestore.dart';

class HabitProgress {
  final String id;
  final String habitId;
  final DateTime date;
  final bool completed;
  final String userId;
  final DateTime createdAt;
  final String? notes;
  final Map<String, dynamic>? metadata;

  HabitProgress({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    required this.userId,
    DateTime? createdAt,
    this.notes,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': Timestamp.fromDate(date),
      'completed': completed,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory HabitProgress.fromJson(Map<String, dynamic> json) {
    return HabitProgress(
      id: json['id'] ?? '',
      habitId: json['habitId'] ?? '',
      date: json['date'] is Timestamp 
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date']),
      completed: json['completed'] ?? false,
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      notes: json['notes'],
      metadata: json['metadata'],
    );
  }

  HabitProgress copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? completed,
    String? userId,
    DateTime? createdAt,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return HabitProgress(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }
}
