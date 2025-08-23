import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntry {
  final String id;
  final String habitId;
  final String title;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  final DateTime createdAt;

  HistoryEntry({
    required this.id,
    required this.habitId,
    required this.title,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'title': title,
      'category': category,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] ?? '',
      habitId: json['habitId'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'General',
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.parse(json['startDate']),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.parse(json['endDate']),
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
    );
  }
}
