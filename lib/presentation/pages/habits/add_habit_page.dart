import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracking/core/constants/colors.dart';
import 'package:habit_tracking/logic/controllers/habit_controller.dart';
import 'package:habit_tracking/data/models/habit_model.dart';
import 'package:habit_tracking/core/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/app_snackbar.dart';

class AddHabitPage extends StatefulWidget {
  @override
  _AddHabitPageState createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final HabitController _habitController = Get.find();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  
  String _selectedFrequency = 'Daily';
  TimeOfDay? _selectedTime;
  bool _isBuildHabit = true; // true for build, false for quit
  bool _isReminderEnabled = false; // true for enabled, false for disabled
  int _target = 7;
  String _selectedCategory = 'Running';
  bool _readingInHours = true;
  // Time range selection
  String _selectedTimeRange = 'Anytime';
  final List<String> _timeRanges = const ['Anytime', 'Morning', 'Afternoon', 'Evening'];
  final List<String> _categories = const [
    'Running',
    'Walking',
    'Smoking',
    'Sleeping',
    'Yoga',
    'Drinking',
    'Exercise',
    'Playing',
    'Reading',
    'Meditation',
    'Study',
    'Diet',
    'Custom',
  ];
  
  final List<String> _frequencies = ['Daily', 'Weekdays', 'Weekends', 'Weekly'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add New Habit',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        // Removed top save action; using bottom rounded confirm button
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              // Add bottom inset to avoid overflow when keyboard is visible
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySection(),
                const SizedBox(height: 24),
                _buildDescriptionSection(),
                const SizedBox(height: 24),
                _buildTrackingSection(),
                const SizedBox(height: 24),
                _buildTimeRangeSection(),
                const SizedBox(height: 24),
                _buildRemindersSection(),
                const SizedBox(height: 24),
                _buildHabitTypeToggle(),
                const SizedBox(height: 24),
                _buildTargetSection(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveHabit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Confirm Habit',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final selected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      _selectedCategory = cat;
                      if (_selectedCategory != 'Reading') {
                        _readingInHours = true; // reset when leaving Reading
                      }
                    });
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: selected ? AppColors.primary : AppColors.border)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedCategory == 'Custom') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _customCategoryController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter custom habit name',
              hintStyle: const TextStyle(color: AppColors.textPrimary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (_selectedCategory == 'Custom' && (value == null || value.trim().isEmpty)) {
                return 'Please enter a habit name';
              }
              return null;
            },
          ),
        ]
      ],
    );
  }
  // Time Range quick selector
  Widget _buildTimeRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Time Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: _timeRanges.map((range) {
            final isSelected = _selectedTimeRange == range;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeRange = range;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      range,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  // Tracking section wraps frequency selection
  Widget _buildTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        const Text('Frequency', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
        const SizedBox(height: 12),
        Row(
          children: _frequencies.map((frequency) {
            final isSelected = _selectedFrequency == frequency;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFrequency = frequency;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      frequency,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  // Reminders section wraps time selector
  Widget _buildRemindersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Switch(
              value: _isReminderEnabled,
              onChanged: (value) {
                setState(() {
                  _isReminderEnabled = value;
                  if (!value) {
                    _selectedTime = null;
                  }
                });
              },
              activeColor: AppColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ],
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          height: _isReminderEnabled ? null : 0,
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 600),
            opacity: _isReminderEnabled ? 1.0 : 0.0,
            curve: Curves.easeInOut,
            child: _isReminderEnabled ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text('Reminder', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _isReminderEnabled ? _selectTime : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.textPrimary),
                        const SizedBox(width: 12),
                        Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'Select time',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedTime != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTime = null;
                              });
                            },
                            child: const Icon(Icons.clear, color: AppColors.textPrimary),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ) : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habit Type',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isBuildHabit = false),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: !_isBuildHabit ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        'Quit Habit',
                        style: TextStyle(
                          color: !_isBuildHabit ? Colors.white : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: !_isBuildHabit ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isBuildHabit = true),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isBuildHabit ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        'Build Habit',
                        style: TextStyle(
                          color: _isBuildHabit ? Colors.white : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: _isBuildHabit ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Optional',
            hintStyle: TextStyle(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetSection() {
    if (!_shouldShowTarget()) return const SizedBox.shrink();

    final unit = _unitForCategory();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Target', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        if (_selectedCategory == 'Reading')
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _readingUnitToggle('Hours', true),
                const SizedBox(width: 8),
                _readingUnitToggle('Minutes', false),
              ],
            ),
          ),
        TextFormField(
          initialValue: _target.toString(),
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter target in $unit',
            suffixText: unit,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
            hintStyle: const TextStyle(color: AppColors.textPrimary),
          ),
          onChanged: (val) {
            final parsed = int.tryParse(val);
            if (parsed != null && parsed >= 0) {
              _target = parsed;
            }
          },
        ),
      ],
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // Green color for selected time
              onPrimary: Colors.white, // White text on green
              surface: Colors.white, // White background
              onSurface: AppColors.textPrimary, // Black text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // Green buttons
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      
      // Request notification permissions when user sets a time
      await _requestNotificationPermissions();
    }
  }

  String _iconForCategory(String name, bool isBuild) {
    final n = name.toLowerCase();
    if (n.contains('run')) return '🏃';
    if (n.contains('walk')) return '🚶';
    if (n.contains('smok')) return '🚭';
    if (n.contains('sleep')) return '😴';
    if (n.contains('yoga')) return '🧘';
    if (n.contains('drink')) return '💧';
    if (n.contains('exerc') || n.contains('workout')) return '🏋️';
    if (n.contains('play')) return '🎮';
    if (n.contains('read')) return '📖';
    if (n.contains('medit')) return '🧘';
    if (n.contains('study') || n.contains('learn')) return '📚';
    if (n.contains('diet') || n.contains('food')) return '🥗';
    return isBuild ? '✅' : '❌';
  }

  bool _shouldShowTarget() {
    return _selectedCategory.toLowerCase() != 'custom';
  }

  String _unitForCategory() {
    final c = _selectedCategory.toLowerCase();
    if (c == 'running') return 'km';
    if (c == 'walking') return 'steps';
    if (c == 'smoking') return 'days';
    if (c == 'yoga') return 'hours';
    if (c == 'drinking') return 'liters';
    if (c == 'sleeping') return 'hours';
    if (c == 'exercise') return 'hours';
    if (c == 'playing') return 'hours';
    if (c == 'reading') return _readingInHours ? 'hours' : 'minutes';
    if (c == 'meditation') return 'hours';
    if (c == 'study') return 'hours';
    if (c == 'diet') return 'days';
    return 'times';
  }

  Widget _readingUnitToggle(String label, bool hours) {
    final selected = _readingInHours == hours;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _readingInHours = hours),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      
      final hasPermission = await notificationService.requestPermissions();
      if (!hasPermission) {
        // Show dialog to inform user about permissions
        _showPermissionDialog();
      } else {
        // Show success message
        showTopSnack('Permissions Granted', 'Notifications are now enabled for your habit reminders', type: SnackType.success);
      }
    } catch (e) {
      showTopSnack('Permission Error', 'Unable to request notification permissions: $e', type: SnackType.error);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification Permissions Required'),
          content: Text(
            'To receive habit reminders, please enable notifications in your device settings. '
            'Go to Settings > Apps > Habit Tracking > Notifications and enable them.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final String resolvedTitle = _selectedCategory == 'Custom'
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    final habit = Habit(
      id: '',
      title: resolvedTitle,
      description: _descriptionController.text.trim(),
      category: resolvedTitle,
      icon: _iconForCategory(resolvedTitle, _isBuildHabit),
      color: '#18392B', // Green color for both
      targetFrequency: _target,
      frequency: _selectedFrequency,
      time: _selectedTime != null ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}' : null,
      timeRange: _selectedTimeRange,
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      targetUnit: _unitForCategory(),
      currentAmount: 0,
      isBuildHabit: _isBuildHabit,
    );

    await _habitController.createHabit(habit);

    // Schedule notification if reminder is enabled and time is set
    if (_isReminderEnabled && _selectedTime != null) {
      try {
        final notificationService = NotificationService();
        final weekdays = notificationService.getWeekdaysFromFrequency(_selectedFrequency);
        
        await notificationService.scheduleHabitReminder(
          id: habit.hashCode, // Use habit hashcode as unique ID
          habitTitle: habit.title,
          reminderTime: _selectedTime!,
          weekdays: weekdays,
        );
        
        showTopSnack('Success', 'Habit added with reminder notifications!', type: SnackType.success);
      } catch (e) {
        showTopSnack('Partial Success', 'Habit added but notification scheduling failed: $e', type: SnackType.warning);
      }
    } else {
      showTopSnack('Success', 'Habit added successfully!', type: SnackType.success);
    }
  }
}
