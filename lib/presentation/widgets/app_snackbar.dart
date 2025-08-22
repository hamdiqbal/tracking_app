import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';

enum SnackType { info, success, warning, error }

Color _accentForType(SnackType type) {
  switch (type) {
    case SnackType.success:
      return AppColors.primary;
    case SnackType.warning:
      return const Color(0xFFF59E0B); // amber
    case SnackType.error:
      return const Color(0xFFEF4444); // red
    case SnackType.info:
    default:
      return AppColors.primary;
  }
}

void showTopSnack(String title, String message, {SnackType type = SnackType.info, Duration duration = const Duration(seconds: 2)}) {
  final accent = _accentForType(type);
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    borderRadius: 14,
    backgroundColor: AppColors.card,
    colorText: AppColors.textPrimary,
    duration: duration,
    isDismissible: true,
    overlayBlur: 0,
    snackStyle: SnackStyle.FLOATING,
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    barBlur: 0,
    icon: Icon(Icons.info_outline, color: accent),
    mainButton: null,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    titleText: Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),
    messageText: Text(
      message,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    ),
    borderColor: accent.withOpacity(0.18),
    borderWidth: 1,
  );
}
