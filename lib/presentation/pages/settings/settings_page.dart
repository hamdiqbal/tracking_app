import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../logic/controllers/app_controller.dart';
import '../../widgets/app_snackbar.dart';

class SettingsPage extends StatelessWidget {
  final AppController _appController = Get.find();

  @override
  Widget build(BuildContext context) {
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
          'Settings',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          _buildThemeSwitch(),
          const Divider(height: 32),
          _buildSectionHeader('General'),
          _buildListTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => _openNotificationsSettings(),
          ),
          _buildListTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _changeLanguage(),
          ),
          const Divider(height: 32),
          _buildSectionHeader('Support'),
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () => _launchUrl('https://help.habitual.app'),
          ),
          _buildListTile(
            icon: Icons.email_outlined,
            title: 'Contact Us',
            onTap: () => _launchUrl('mailto:support@habitual.app'),
          ),
          _buildListTile(
            icon: Icons.star_border,
            title: 'Rate Us',
            onTap: () => _launchUrl('https://play.google.com/store/apps/details?id=com.habitual.app'),
          ),
          const Divider(height: 32),
          _buildSectionHeader('About'),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: _appController.appVersion,
            showTrailing: false,
          ),
          _buildListTile(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy',
            onTap: () => _launchUrl('https://habitual.app/privacy'),
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => _launchUrl('https://habitual.app/terms'),
          ),
          const SizedBox(height: 32),
          _buildLogoutButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildThemeSwitch() {
    return Obx(() => SwitchListTile(
          title: const Text(
            'Dark Mode',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            _appController.isDarkMode.value ? 'On' : 'Off',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          value: _appController.isDarkMode.value,
          onChanged: (value) => _appController.toggleTheme(),
          activeColor: AppColors.primary,
          secondary: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _appController.isDarkMode.value
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: AppColors.primary,
            ),
          ),
        ));
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool showTrailing = true,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: showTrailing
          ? const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            )
          : null,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _confirmLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withOpacity(0.1),
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _openNotificationsSettings() {
    // TODO: Implement notifications settings
    showTopSnack('Coming Soon', 'Notifications settings will be implemented here', type: SnackType.info);
  }

  void _changeLanguage() {
    // TODO: Implement language change
    showTopSnack('Coming Soon', 'Language selection will be implemented here', type: SnackType.info);
  }

  void _confirmLogout() {
    Get.defaultDialog(
      title: 'Log Out',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      content: const Text(
        'Are you sure you want to log out?',
        style: TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: AppColors.surface,
      titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      confirm: TextButton(
        onPressed: () {
          // TODO: Implement logout logic
          Get.back();
          Get.offAllNamed('/login');
        },
        child: const Text(
          'Log Out',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text(
          'Cancel',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showTopSnack('Error', 'Could not launch $url', type: SnackType.error);
    }
  }
}
