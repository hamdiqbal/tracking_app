import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'data/models/habit_progress_model.dart';
import 'logic/controllers/habit_controller.dart';

class CalenderScreen extends StatefulWidget {
  final String habitId;
  const CalenderScreen({super.key, required this.habitId});

  @override
  _CalenderScreenState createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  final HabitController _habitController = Get.find();
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D1A),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF2D3748),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                            });
                          },
                        ),
                        Text(
                          '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                          .map((day) => Container(
                                width: 32,
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF718096),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 16),
                    Obx(() {
                      // Rebuild when progress map updates
                      return Column(children: _buildCalendarDays());
                    }),
                  ],
                ),
              ),
              SizedBox(height: 32),
              _buildStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final habit = _habitController.habits.firstWhereOrNull((h) => h.id == widget.habitId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          habit?.title ?? 'Calendar',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Last 30 days overview',
          style: TextStyle(color: Colors.white70),
        )
      ],
    );
  }

  List<Widget> _buildCalendarDays() {
    List<Widget> weeks = [];
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final List<HabitProgress> progress = _habitController.habitProgressMap[widget.habitId] ?? [];

    for (int weekIndex = 0; weekIndex < 6; weekIndex++) {
      List<Widget> days = [];
      for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
        final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
        final isValidDay = dayNumber > 0 && dayNumber <= daysInMonth;
        final currentDate = DateTime(currentMonth.year, currentMonth.month, dayNumber);
        final isToday = isValidDay && 
            currentDate.day == DateTime.now().day &&
            currentDate.month == DateTime.now().month &&
            currentDate.year == DateTime.now().year;
        final isSelected = isValidDay && 
            currentDate.day == selectedDate.day &&
            currentDate.month == selectedDate.month &&
            currentDate.year == selectedDate.year;
        
        // Real completion data for this habit
        final hasCompletedHabits = isValidDay && progress.any((p) => _isSameDate(p.date, currentDate) && p.completed);

        days.add(
          GestureDetector(
            onTap: isValidDay ? () {
              setState(() {
                selectedDate = currentDate;
              });
            } : null,
            child: Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Color(0xFF319795)
                    : isToday 
                        ? Color(0xFF319795).withOpacity(0.3)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: hasCompletedHabits && !isSelected
                    ? Border.all(color: Color(0xFF319795), width: 1)
                    : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isValidDay)
                      Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isSelected || isToday 
                              ? Colors.white 
                              : Color(0xFF718096),
                          fontWeight: isSelected || isToday 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    if (hasCompletedHabits && !isSelected)
                      Container(
                        width: 4,
                        height: 4,
                        margin: EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: Color(0xFF319795),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      weeks.add(
        Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days,
          ),
        ),
      );
    }
    return weeks;
  }

  Widget _buildStats() {
    return Obx(() {
      final stats = _habitController.habitStatsMap[widget.habitId];
      final current = stats?['completedDays'] ?? 0;
      final total = stats?['totalDays'] ?? 0;
      final rate = (stats?['completionRate'] ?? 0.0) as double;
      final streak = stats?['currentStreak'] ?? 0;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 30 days', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _statTile('Completed', '$current/$total'),
                const SizedBox(width: 24),
                _statTile('Rate', '${rate.toStringAsFixed(0)}%'),
                const SizedBox(width: 24),
                _statTile('Streak', '$streak'),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load progress and stats for this habit
    _habitController.loadHabitProgress(widget.habitId);
    _habitController.loadHabitStats(widget.habitId);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}