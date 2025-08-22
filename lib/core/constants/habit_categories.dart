import 'package:flutter/material.dart';

class HabitCategory {
  final String name;
  final String icon;
  final Color color;
  final List<String> suggestions;

  const HabitCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.suggestions,
  });
}

class HabitCategories {
  static const List<HabitCategory> categories = [
    HabitCategory(
      name: 'Health & Fitness',
      icon: '🏃‍♂️',
      color: Colors.green,
      suggestions: [
        'Exercise',
        'Morning Run',
        'Gym Workout',
        'Yoga',
        'Meditation',
        'Take Vitamins',
        'Drink 8 Glasses of Water',
        'Walk 10,000 Steps',
        'Stretch',
        'Sleep 8 Hours',
      ],
    ),
    HabitCategory(
      name: 'Diet & Nutrition',
      icon: '🥗',
      color: Colors.orange,
      suggestions: [
        'Eat Healthy Breakfast',
        'No Junk Food',
        'Eat 5 Fruits & Vegetables',
        'Cook at Home',
        'No Sugar',
        'Intermittent Fasting',
        'Meal Prep',
        'No Late Night Snacks',
        'Drink Green Tea',
        'Take Probiotics',
      ],
    ),
    HabitCategory(
      name: 'Learning & Growth',
      icon: '📚',
      color: Colors.blue,
      suggestions: [
        'Read for 30 Minutes',
        'Learn New Language',
        'Online Course',
        'Practice Coding',
        'Write in Journal',
        'Listen to Podcast',
        'Watch Educational Video',
        'Practice Instrument',
        'Study New Skill',
        'Read News',
      ],
    ),
    HabitCategory(
      name: 'Productivity',
      icon: '⚡',
      color: Colors.purple,
      suggestions: [
        'Wake Up Early',
        'Make To-Do List',
        'Clean Workspace',
        'No Social Media',
        'Time Blocking',
        'Review Goals',
        'Plan Tomorrow',
        'Organize Files',
        'Complete Priority Task',
        'Focus Time',
      ],
    ),
    HabitCategory(
      name: 'Social & Relationships',
      icon: '👥',
      color: Colors.pink,
      suggestions: [
        'Call Family',
        'Text Friends',
        'Compliment Someone',
        'Help Others',
        'Network',
        'Date Night',
        'Family Time',
        'Make New Friends',
        'Express Gratitude',
        'Listen Actively',
      ],
    ),
    HabitCategory(
      name: 'Self Care',
      icon: '🧘‍♀️',
      color: Colors.teal,
      suggestions: [
        'Skincare Routine',
        'Take a Bath',
        'Practice Gratitude',
        'Deep Breathing',
        'Limit Screen Time',
        'Go Outside',
        'Listen to Music',
        'Take Breaks',
        'Pamper Yourself',
        'Positive Affirmations',
      ],
    ),
    HabitCategory(
      name: 'Bad Habits to Break',
      icon: '🚫',
      color: Colors.red,
      suggestions: [
        'No Smoking',
        'No Drinking Alcohol',
        'No Procrastination',
        'No Negative Thoughts',
        'No Oversleeping',
        'No Overeating',
        'No Gossiping',
        'No Complaining',
        'No Multitasking',
        'No Phone in Bed',
      ],
    ),
    HabitCategory(
      name: 'Finance',
      icon: '💰',
      color: Colors.amber,
      suggestions: [
        'Track Expenses',
        'Save Money',
        'Invest Daily',
        'Budget Review',
        'No Impulse Buying',
        'Check Bank Account',
        'Read Financial News',
        'Plan Investments',
        'Cut Unnecessary Expenses',
        'Emergency Fund',
      ],
    ),
  ];

  static HabitCategory getCategoryByName(String name) {
    return categories.firstWhere(
      (category) => category.name == name,
      orElse: () => categories.first,
    );
  }

  static List<String> get categoryNames {
    return categories.map((category) => category.name).toList();
  }
}
