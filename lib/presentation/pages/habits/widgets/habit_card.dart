import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/habit_categories.dart';
import '../../../../data/models/habit_model.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final Function(bool) onToggle;

  const HabitCard({
    Key? key,
    required this.habit,
    required this.onTap,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = _categoryColor(habit.category);
    final Brightness brightness = ThemeData.estimateBrightnessForColor(categoryColor);
    final Color onColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: categoryColor, // exact category color as requested
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              _buildHabitInfo(),
              const Spacer(),
              _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final category = HabitCategories.getCategoryByName(habit.category);
    final hasCustomIcon = habit.icon.isNotEmpty;
    final isAssetIcon = hasCustomIcon && habit.icon.startsWith('assets/');
    final Color categoryColor = _categoryColor(habit.category);
    final Brightness brightness = ThemeData.estimateBrightnessForColor(categoryColor);
    final Color onColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: onColor.withOpacity(0.15), // subtle contrast bubble
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isAssetIcon
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  habit.icon,
                  fit: BoxFit.contain,
                ),
              )
            : Center(
                child: Text(
                  hasCustomIcon ? habit.icon : category.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
      ),
    );
  }

  Widget _buildHabitInfo() {
    final Color categoryColor = _categoryColor(habit.category);
    final Brightness brightness = ThemeData.estimateBrightnessForColor(categoryColor);
    final Color onColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habit.title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (habit.frequency != null && habit.frequency!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              habit.frequency!,
              style: TextStyle(fontSize: 12, color: onColor.withOpacity(0.85)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ],
          if (habit.time != null && habit.time!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              habit.time!,
              style: TextStyle(fontSize: 14, color: onColor.withOpacity(0.8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final percent = habit.progress.clamp(0, 100);
    final Color categoryColor = _categoryColor(habit.category);
    final Brightness brightness = ThemeData.estimateBrightnessForColor(categoryColor);
    final Color onColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    return Flexible(
      fit: FlexFit.loose,
      child: SizedBox(
        width: 120,
        child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent / 100.0,
                minHeight: 6,
                backgroundColor: onColor.withOpacity(0.25),
                valueColor: AlwaysStoppedAnimation<Color>(onColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '$percent',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: onColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Color _categoryColor(String name) {
    switch (name.toLowerCase().trim()) {
      case 'running':
        return const Color(0xFF190019);
      case 'walking':
        return const Color(0xFF2B124C);
      case 'smoking':
        return const Color(0xFF522B5B);
      case 'sleeping':
        return const Color(0xFF854F6C);
      case 'yoga':
        return const Color(0xFFDFB6B2);
      case 'drinking':
        return const Color(0xFFFBE4D8);
      case 'exercise':
        return const Color(0xFF2F3A32);
      case 'playing':
        return const Color(0xFF545748);
      case 'reading':
        return const Color(0xFFDB9F75);
      case 'meditation':
        return const Color(0xFF804012);
      case 'study':
        return const Color(0xFF3E2411);
      case 'diet':
        return const Color(0xFF052659);
      case 'custom':
        return const Color(0xFF7DA0CA);
      default:
        return AppColors.surface;
    }
  }
}
