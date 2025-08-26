import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/habit_categories.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/habit_model.dart';
import '../../../logic/controllers/habit_controller.dart';
import '../../../logic/controllers/app_controller.dart';
import '../../../logic/controllers/auth_controller.dart';
import 'widgets/habit_card.dart';
import 'widgets/habit_details_dialog.dart';
import '../settings/settings_page.dart';
import 'add_habit_page.dart';
import 'habit_progress_page.dart';
import '../history/history_page.dart';
// import '../statistics/statistics_page.dart';

class HabitsPage extends StatefulWidget {
  @override
  _HabitsPageState createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  final HabitController _habitController = Get.find();
  final AppController _appController = Get.find();
  final AuthController _authController = Get.find();
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final ScrollController _calendarController = ScrollController();
  final GlobalKey _todayKey = GlobalKey();
  bool _didScrollToToday = false;
  DateTime? _lastScrollTime;
  int _scrollRetries = 0;
  Worker? _tabWorker;

  @override
  void initState() {
    super.initState();
    // Ensure the calendar scrolls to today's position after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollCalendarToToday());
    // Listen to tab index changes and recenter when switching to Home (index 0)
    _tabWorker = ever<int>(_appController.currentTabIndex, (idx) {
      if (idx == 0) {
        _scheduleRecenter();
      }
    });
  }

  bool _isHabitActiveForDate(Habit habit, DateTime date) {
    final String freq = (habit.frequency ?? '').trim();
    if (freq.isEmpty) return true; // default active if not specified
    final int weekday = date.weekday; // 1 = Mon, ... 7 = Sun
    switch (freq.toLowerCase()) {
      case 'daily':
        return true;
      case 'weekly':
        return true; // always visible as per requirement
      case 'weekdays':
        return weekday >= DateTime.monday && weekday <= DateTime.friday;
      case 'weekends':
        return weekday == DateTime.saturday || weekday == DateTime.sunday;
      default:
        return true; // unknown values -> keep active
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // When dependencies change (e.g., page becomes visible again), recenter to today with debounce
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      if (_lastScrollTime == null || now.difference(_lastScrollTime!).inMilliseconds > 800) {
        _lastScrollTime = now;
        // Reset so that the today item can trigger ensureVisible when rebuilt
        _didScrollToToday = false;
        setState(() {});
        // Also proactively try to scroll after this rebuild
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollCalendarToToday());
      }
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _tabWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Debounced scroll attempt each build to handle cases like IndexedStack tab switches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      if (_lastScrollTime == null || now.difference(_lastScrollTime!).inMilliseconds > 800) {
        _lastScrollTime = now;
        // allow ensureVisible trigger again
        _didScrollToToday = false;
        _scrollCalendarToToday();
      }
    });
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: _buildBody(),
      // Removed FAB to match header + icon add pattern
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      final index = _appController.currentTabIndex.value;
      switch (index) {
        case 0:
          return SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  _buildHabitsList(),
                ],
              ),
            ),
          );
        case 1:
          return AddHabitPage();
        case 2:
          return HistoryPage();
        case 3:
                        return SettingsPage();
        default:
          return Container();
      }
    });
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(width: 24), // spacer to help center title visually
        const Expanded(
          child: Center(
            child: Text(
              'Habits',
              style: AppTextStyles.heading1,
            ),
          ),
        ),
        // Account menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle, color: AppColors.textPrimary),
          onSelected: (value) async {
            if (value == 'signout') {
              await _authController.signOut();
              Get.offAllNamed(AppRoutes.signIn);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'signout',
              child: Text('Sign out'),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.textPrimary),
                        onPressed: () => Get.to(() => SettingsPage()),
        ),
      ],
    );
  }

  Widget _buildHabitsList() {
    return Obx(() {
      if (_habitController.isLoading.value) {
        return const Expanded(child: Center(child: CircularProgressIndicator()));
      }

      if (_habitController.habits.isEmpty) {
        return Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.track_changes,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No habits yet',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start building better habits today!\nTap the + button to add your first habit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Split habits into Build and Quit sections
      final allHabits = _habitController.habits;
      final buildHabits = allHabits.where((h) => h.isBuildHabit).toList();
      final quitHabits = allHabits.where((h) => !h.isBuildHabit).toList();

      List<Widget> section(String title, List<Habit> items) {
        if (items.isEmpty) return [];
        return [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Text(title, style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
          ),
          ...items.map((habit) => Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                child: Builder(
                  builder: (ctx) {
                    final bool isActive = _isHabitActiveForDate(habit, _selectedDate);
                    final bool isDisabled = !isActive;
                    return Dismissible(
                    key: Key('${title.toLowerCase().replaceAll(' ', '_')}_${habit.id}'),
                    direction: isDisabled ? DismissDirection.none : DismissDirection.startToEnd,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: const Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    onDismissed: (direction) async {
                      final removed = habit;
                      final success = await _habitController.deleteHabit(habit.id);
                      ScaffoldMessenger.of(ctx).clearSnackBars();
                      if (success) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: const Text('Habit deleted'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () async {
                                await _habitController.restoreHabit(removed);
                              },
                            ),
                          ),
                        );
                      } else {
                        await _habitController.restoreHabit(removed);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Failed to delete habit')),
                        );
                      }
                    },
                    child: HabitCard(
                      habit: habit,
                      disabled: isDisabled,
                      onTap: isDisabled ? null : () => _openHabitCalendar(habit),
                      onToggle: (value) => _toggleHabitCompletion(habit, value),
                    ),
                  );
                  },
                ),
              )),
          const SizedBox(height: 12),
        ];
      }

      return Expanded(
        child: ListView(
          children: [
            // Horizontal calendar at the top
            _buildHorizontalCalendar(),
            const SizedBox(height: 16),
            ...section('Build Habits', buildHabits),
            ...section('Quit Habits', quitHabits),
          ],
        ),
      );
    });
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() => BottomNavigationBar(
          currentIndex: _appController.currentTabIndex.value,
          onTap: (index) => _onTabTapped(index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ));
  }

  void _onTabTapped(int index) {
    _appController.changeTab(index);
    if (index == 0) {
      _scheduleRecenter();
    }
  }

  Widget _buildHorizontalCalendar() {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 7));
    // Show 30 days range for easy scrolling
    final totalDays = 30;

    String _weekdayLabel(DateTime d) {
      const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return names[d.weekday % 7];
    }

    const double itemExtent = 60.0; // fixed width for each day item for precise scrolling
    return SizedBox(
      height: 92,
      child: ListView.builder(
        controller: _calendarController,
        scrollDirection: Axis.horizontal,
        itemExtent: itemExtent,
        itemCount: totalDays,
        itemBuilder: (context, index) {
          final date = start.add(Duration(days: index));
          final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
          final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;

          // Overall progress ring: average of ACTIVE (unfaded) habits' progress (0-100)
          final habitsForDate = _habitController.habits.where((h) => _isHabitActiveForDate(h, date)).toList();
          final count = habitsForDate.length;
          final totalProgress = habitsForDate.fold<int>(0, (sum, h) => sum + (h.progress.clamp(0, 100)));
          final progress = count == 0 ? 0.0 : (totalProgress / (count * 100)).clamp(0.0, 1.0);

          if (isToday && !_didScrollToToday) {
            // Trigger a one-time ensureVisible after the item is built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final ctx = _todayKey.currentContext;
              if (ctx != null) {
                _didScrollToToday = true;
                Scrollable.ensureVisible(
                  ctx,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  alignment: 0.5,
                );
              }
            });
          }

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 8 : 10, right: index == totalDays - 1 ? 8 : 0),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                // Block future date selection
                final dateOnly = DateTime(date.year, date.month, date.day);
                final todayOnly = DateTime(today.year, today.month, today.day);
                if (dateOnly.isAfter(todayOnly)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot select a future date')),
                  );
                  return;
                }
                setState(() => _selectedDate = dateOnly);
                _animateCalendarToIndex(index, itemExtent);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayLabel(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected || isToday ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    key: isToday ? _todayKey : null,
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          value: isToday ? progress : 0.0,
                          strokeWidth: 5,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isToday ? AppColors.primary : Colors.transparent,
                          ),
                        ),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday ? AppColors.primary : AppColors.surface,
                          border: Border.all(
                            color: isToday
                                ? AppColors.primary
                                : (isSelected ? AppColors.primary : AppColors.border),
                            width: isSelected && !isToday ? 2 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isToday ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _scrollCalendarToToday() {
    try {
      // If the ListView isn't attached yet, retry shortly (up to 5 times)
      if (!_calendarController.hasClients) {
        if (_scrollRetries < 5) {
          _scrollRetries++;
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollCalendarToToday());
        } else {
          _scrollRetries = 0;
        }
        return;
      }
      _scrollRetries = 0;
      final ctx = _todayKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          alignment: 0.5,
        );
        return;
      }
      // Fallback to controller-based approximation
      const itemWidth = 60.0; // fixed width used in ListView.itemExtent
      const totalDays = 30;
      final today = DateTime.now();
      final start = today.subtract(const Duration(days: 7));
      final index = today.difference(DateTime(start.year, start.month, start.day)).inDays;
      final clampedIndex = index.clamp(0, totalDays - 1);
      _animateCalendarToIndex(clampedIndex, itemWidth);
    } catch (_) {
      // no-op if controller not ready
    }
  }

  void _scheduleRecenter() {
    _didScrollToToday = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollCalendarToToday());
  }

  void _animateCalendarToIndex(int index, double itemExtent) {
    if (!_calendarController.hasClients) return;
    final viewport = _calendarController.position.viewportDimension;
    double targetOffset = index * itemExtent - (viewport - itemExtent) / 2;
    final max = _calendarController.position.maxScrollExtent;
    if (targetOffset < 0) targetOffset = 0;
    if (targetOffset > max) targetOffset = max;
    _calendarController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    Get.toNamed(AppRoutes.addHabit);
  }

  void _openHabitCalendar(Habit habit) {
    Get.to(() => HabitProgressPage(habit: habit));
  }

  void _toggleHabitCompletion(Habit habit, bool value) {
    // Use the selected date for toggling completion
    _habitController.toggleHabitCompletion(habit.id, _selectedDate);
  }
}
