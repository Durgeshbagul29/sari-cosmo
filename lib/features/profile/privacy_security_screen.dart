import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'change_password_screen.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _profileVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          _buildSection('Security', [
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or face ID to login',
              value: _biometricEnabled,
              color: AppTheme.primary,
              onChanged: (v) => setState(() => _biometricEnabled = v),
            ),
            _buildSwitchTile(
              icon: Icons.security_outlined,
              title: 'Two-Factor Authentication',
              subtitle: 'Add extra layer of security via OTP',
              value: _twoFactorEnabled,
              color: const Color(0xFF2980B9),
              onChanged: (v) => setState(() => _twoFactorEnabled = v),
            ),
            _buildActionTile(
              icon: Icons.lock_reset_outlined,
              title: 'Change Password',
              subtitle: 'Last changed 30 days ago',
              color: const Color(0xFF8E44AD),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            _buildActionTile(
              icon: Icons.devices_outlined,
              title: 'Active Sessions',
              subtitle: '2 devices logged in',
              color: AppTheme.warning,
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Privacy', [
            _buildSwitchTile(
              icon: Icons.visibility_outlined,
              title: 'Profile Visibility',
              subtitle: 'Allow others to see your profile',
              value: _profileVisible,
              color: AppTheme.success,
              onChanged: (v) => setState(() => _profileVisible = v),
            ),
            _buildActionTile(
              icon: Icons.download_outlined,
              title: 'Download My Data',
              subtitle: 'Request a copy of your data',
              color: const Color(0xFF2980B9),
              onTap: () {},
            ),
            _buildActionTile(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              color: const Color(0xFFE74C3C),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Notification Preferences', [
            _buildSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive alerts on your device',
              value: _pushNotifications,
              color: AppTheme.primary,
              onChanged: (v) => setState(() => _pushNotifications = v),
            ),
            _buildSwitchTile(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Receive updates via email',
              value: _emailNotifications,
              color: const Color(0xFF8E44AD),
              onChanged: (v) => setState(() => _emailNotifications = v),
            ),
            _buildSwitchTile(
              icon: Icons.sms_outlined,
              title: 'SMS Notifications',
              subtitle: 'Receive SMS alerts',
              value: _smsNotifications,
              color: AppTheme.success,
              onChanged: (v) => setState(() => _smsNotifications = v),
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight, size: 20),
      onTap: onTap,
    );
  }
}
