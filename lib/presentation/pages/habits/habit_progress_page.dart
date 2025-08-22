import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/app_snackbar.dart';
import '../../../data/models/habit_model.dart';
import '../../../logic/controllers/habit_controller.dart';

class HabitProgressPage extends StatefulWidget {
  final Habit habit;
  const HabitProgressPage({Key? key, required this.habit}) : super(key: key);

  @override
  State<HabitProgressPage> createState() => _HabitProgressPageState();
}

class _HabitProgressPageState extends State<HabitProgressPage> {
  late int _currentAmount; // amount toward target (interpreted in unit)
  late int _targetAmount; // from habit.targetFrequency
  late String _unit; // derived from category/title
  final HabitController _habitController = Get.find();
  double _prevProgressTarget = 0; // 0.0 - 1.0, for smooth animation

  @override
  void initState() {
    super.initState();
    _targetAmount = widget.habit.targetFrequency;
    // Prefer saved unit on the model; fallback to category-derived
    _unit = (widget.habit.targetUnit).isNotEmpty
        ? widget.habit.targetUnit
        : _unitForHabit(widget.habit);
    // Prefer exact amount from model; fallback to interpreting saved %
    final savedPercent = widget.habit.progress.clamp(0, 100);
    _currentAmount = widget.habit.currentAmount != 0
        ? widget.habit.currentAmount
        : ((_targetAmount * savedPercent) / 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final int progress = _percentFromAmount();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.habit.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      _buildCircularProgress(progress),
                      const SizedBox(height: 24),
                      _buildStats(),
                      const SizedBox(height: 16),
                      _buildAmountRow(),
                      const SizedBox(height: 24),
                      _buildActions(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCircularProgress(int progress) {
    final double target = (progress.clamp(0, 100)) / 100.0;
    final double begin = _prevProgressTarget;
    _prevProgressTarget = target; // cache for next rebuild
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: begin, end: target),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
        builder: (context, value, _) {
          return SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background + progress ring with rounded caps
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CustomPaint(
                    painter: _RoundedCircularProgressPainter(
                      progress: value,
                      trackColor: AppColors.surface,
                      progressColor: AppColors.primary,
                      strokeWidth: 14,
                    ),
                  ),
                ),
                // Inner content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(value * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Progress',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats() {
    return Card(
      color: AppColors.card,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statItem('Streak', '${widget.habit.currentStreak}'),
            _divider(),
            _statItem('Longest', '${widget.habit.longestStreak}'),
            _divider(),
            _statItem('Target', '$_targetAmount $_unit'),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.border,
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Back'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _markTodayDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Mark Today Done'),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: _decrement,
            icon: const Icon(Icons.remove, color: AppColors.primary),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$_currentAmount of $_targetAmount $_unit',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Adjust your progress',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Align(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: ElevatedButton.icon(
                      onPressed: _enterAmountManually,
                      icon: const Icon(Icons.add, size: 18, color: Colors.white),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _increment,
            icon: const Icon(Icons.add, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  int _percentFromAmount() {
    if (_targetAmount <= 0) return 0;
    final pct = ((_currentAmount / _targetAmount) * 100).clamp(0, 100);
    return pct.round();
  }

  Future<void> _persistProgress() async {
    final updated = widget.habit.copyWith(
      progress: _percentFromAmount(),
      currentAmount: _currentAmount,
      targetUnit: _unit,
      updatedAt: DateTime.now(),
    );
    await _habitController.updateHabit(updated);
  }

  void _increment() {
    setState(() {
      _currentAmount = (_currentAmount + 1).clamp(0, _targetAmount);
    });
    _persistProgress();
  }

  void _decrement() {
    setState(() {
      _currentAmount = (_currentAmount - 1).clamp(0, _targetAmount);
    });
    _persistProgress();
  }

  Future<void> _enterAmountManually() async {
    final controller = TextEditingController(text: '$_currentAmount');
    final value = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Enter Amount',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: '0 - $_targetAmount ($_unit)',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final parsed = int.tryParse(controller.text.trim());
                          if (parsed == null) {
                            showTopSnack('Invalid input', 'Please enter a valid number', type: SnackType.error);
                            return;
                          }
                          if (parsed < 0 || parsed > _targetAmount) {
                            showTopSnack('Out of range', 'Enter a value between 0 and $_targetAmount', type: SnackType.warning);
                            return;
                          }
                          Navigator.of(ctx).pop(parsed);
                        },
                        child: const Text('Set'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (value != null) {
      setState(() {
        _currentAmount = value;
      });
      await _persistProgress();
      showTopSnack('Updated', 'Progress set to $value $_unit', type: SnackType.success);
    }
  }

  Future<void> _markTodayDone() async {
    // If amount-based, mark as completed when reaching target
    setState(() {
      _currentAmount = _targetAmount;
    });
    await _persistProgress();
    // Record daily completion for streaks/stats
    await _habitController.toggleHabitCompletion(widget.habit.id, DateTime.now());
    showTopSnack('Great!', 'Today\'s target reached', type: SnackType.success);
  }

  String _unitForHabit(Habit habit) {
    final c = habit.category.toLowerCase();
    if (c == 'running') return 'km';
    if (c == 'walking') return 'meters';
    if (c == 'smoking') return 'days';
    if (c == 'yoga') return 'hours';
    if (c == 'drinking') return 'liters';
    if (c == 'sleeping') return 'hours';
    if (c == 'exercise') return 'hours';
    if (c == 'playing') return 'hours';
    if (c == 'reading') return 'hours';
    if (c == 'meditation') return 'hours';
    if (c == 'study') return 'hours';
    if (c == 'diet') return 'days';
    return 'times';
  }
}

class _RoundedCircularProgressPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _RoundedCircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    this.strokeWidth = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw full track
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc starting from top (-pi/2)
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RoundedCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
