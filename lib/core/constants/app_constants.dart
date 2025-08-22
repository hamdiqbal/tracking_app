class AppConstants {
  // App Info
  static const String appName = 'Habitual';
  static const String appVersion = '1.0.0';
  
  // API Endpoints (if any)
  static const String baseUrl = 'https://api.habitual.com';
  
  // Local Storage Keys
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';
  
  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration buttonPressDuration = Duration(milliseconds: 100);
  
  // Default Values
  static const int defaultHabitStreak = 0;
  static const int defaultHabitProgress = 0;
  static const String defaultHabitFrequency = 'Daily';
  
  // Validation
  static const int minHabitNameLength = 2;
  static const int maxHabitNameLength = 50;
  static const int maxHabitDescriptionLength = 200;
  
  // Pagination
  static const int habitsPerPage = 10;
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  
  // Icons
  static const List<Map<String, String>> habitIcons = [
    {'icon': '🏃‍♂️', 'label': 'Running'},
    {'icon': '📖', 'label': 'Reading'},
    {'icon': '🌱', 'label': 'Growth'},
    {'icon': '🧘‍♂️', 'label': 'Meditation'},
    {'icon': '😴', 'label': 'Sleep'},
    {'icon': '🚴‍♂️', 'label': 'Cycling'},
    {'icon': '🥗', 'label': 'Healthy Eating'},
    {'icon': '☀️', 'label': 'Morning Routine'},
  ];
}
