import 'package:flutter/material.dart';
import 'core/constants/colors.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Account'),
              SizedBox(height: 16),
              _buildSettingItem(
                icon: Icons.person_outline,
                title: 'Account Settings',
                subtitle: 'Manage your account details',
                onTap: () {
                  // Navigate to account settings
                },
              ),
              SizedBox(height: 32),
              _buildSectionTitle('Notifications'),
              SizedBox(height: 16),
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: 'Notification Settings',
                subtitle: 'Customize notification preferences',
                onTap: () {
                  // Navigate to notification settings
                },
              ),
              SizedBox(height: 32),
              _buildSectionTitle('App Preferences'),
              SizedBox(height: 16),
              _buildSettingItem(
                icon: Icons.light_mode_outlined,
                title: 'Theme',
                subtitle: 'Choose your preferred app theme',
                onTap: () {
                  // Navigate to theme settings
                },
              ),
              SizedBox(height: 16),
              _buildSettingItem(
                icon: Icons.schedule_outlined,
                title: 'Reminders',
                subtitle: 'Set up daily reminders for your habits',
                onTap: () {
                  // Navigate to reminder settings
                },
              ),
              SizedBox(height: 32),
              _buildSectionTitle('Help & Feedback'),
              SizedBox(height: 16),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: '',
                onTap: () {
                  // Navigate to help center
                },
              ),
              SizedBox(height: 16),
              _buildSettingItem(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: '',
                onTap: () {
                  // Navigate to feedback
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}