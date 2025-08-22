class PredefinedHabits {
  static const List<Map<String, dynamic>> habits = [
    {
      'title': 'Morning Exercise',
      'description': 'Start your day with 30 minutes of physical activity',
      'category': 'Fitness',
      'icon': 'assets/images/running.png',
      'color': 'FF4CAF50', // Green
      'frequency': 'Daily',
      'targetFrequency': 7,
    },
    {
      'title': 'Read Books',
      'description': 'Read for at least 20 minutes daily to expand knowledge',
      'category': 'Learning',
      'icon': 'assets/images/vectorstock_33743003.jpg',
      'color': 'FF2196F3', // Blue
      'frequency': 'Daily',
      'targetFrequency': 7,
    },
    {
      'title': 'Meditation',
      'description': 'Practice mindfulness and meditation for mental clarity',
      'category': 'Wellness',
      'icon': 'assets/images/favpng_3a48eefb396efebd34dfbdb43e639331.png',
      'color': 'FF9C27B0', // Purple
      'frequency': 'Daily',
      'targetFrequency': 7,
    },
    {
      'title': 'Drink Water',
      'description': 'Stay hydrated by drinking 8 glasses of water daily',
      'category': 'Health',
      'icon': 'assets/images/clouds.png',
      'color': 'FF00BCD4', // Cyan
      'frequency': 'Daily',
      'targetFrequency': 7,
    },
    {
      'title': 'Cycling',
      'description': 'Go for a bike ride to stay active and explore',
      'category': 'Fitness',
      'icon': 'assets/images/bike.png',
      'color': 'FFFF9800', // Orange
      'frequency': 'Weekdays',
      'targetFrequency': 5,
    },
    {
      'title': 'Morning Sunlight',
      'description': 'Get 15 minutes of natural sunlight exposure',
      'category': 'Health',
      'icon': 'assets/images/sun-icons-sun-icon-isolated-on-black-background-sun-icon-design-illustration-sun-logo-design-vector.jpg',
      'color': 'FFFFC107', // Amber
      'frequency': 'Daily',
      'targetFrequency': 7,
    },
  ];

  static List<String> get categories => [
    'Fitness',
    'Learning', 
    'Wellness',
    'Health',
  ];

  static Map<String, String> get categoryColors => {
    'Fitness': 'FF4CAF50',
    'Learning': 'FF2196F3',
    'Wellness': 'FF9C27B0',
    'Health': 'FF00BCD4',
  };
}
