import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_panel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: [
          // ─── Profile Header ───────────────────────────────────
          _buildProfileHeader(),
          const SizedBox(height: 24),

          // ─── Info Cards ───────────────────────────────────────
          GlassPanel(
            title: 'Staff Information',
            icon: HugeIcons.strokeRoundedUserAccount,
            child: Column(
              children: [
                _InfoRow(
                  icon: HugeIcons.strokeRoundedMail01,
                  label: 'Email',
                  value: 'ahmad.haziq@ngam.my',
                ),
                const Divider(color: Colors.white12, height: 24),
                _InfoRow(
                  icon: HugeIcons.strokeRoundedSmartPhone01,
                  label: 'Phone',
                  value: '+60 12-345 6789',
                ),
                const Divider(color: Colors.white12, height: 24),
                _InfoRow(
                  icon: HugeIcons.strokeRoundedBuilding03,
                  label: 'Department',
                  value: 'Engineering',
                ),
                const Divider(color: Colors.white12, height: 24),
                _InfoRow(
                  icon: HugeIcons.strokeRoundedUserStar01,
                  label: 'Position',
                  value: 'Senior Developer',
                ),
                const Divider(color: Colors.white12, height: 24),
                _InfoRow(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  label: 'Joined',
                  value: 'March 15, 2024',
                ),
                const Divider(color: Colors.white12, height: 24),
                _InfoRow(
                  icon: HugeIcons.strokeRoundedTag01,
                  label: 'Staff ID',
                  value: 'NGM-2024-0042',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── Settings ─────────────────────────────────────────
          GlassPanel(
            title: 'Settings',
            icon: HugeIcons.strokeRoundedSettings01,
            child: Column(
              children: [
                _SettingToggle(
                  icon: HugeIcons.strokeRoundedNotification02,
                  label: 'Push Notifications',
                  value: _notificationsEnabled,
                  onChanged: (v) =>
                      setState(() => _notificationsEnabled = v),
                ),
                const Divider(color: Colors.white12, height: 24),
                _SettingToggle(
                  icon: HugeIcons.strokeRoundedMoon02,
                  label: 'Dark Mode',
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── Sign Out ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Sign out
              },
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedLogout02,
                color: AppColors.error,
                size: 20,
              ),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── App Version ──────────────────────────────────────
          Text(
            'Ngam Teams v0.1.0',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder, width: 1.2),
          ),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'AH',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ahmad Haziq',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Senior Developer • Engineering',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: AppColors.success, size: 8),
                    SizedBox(width: 8),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Info Row ────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final dynamic icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HugeIcon(
          icon: icon,
          color: AppColors.primary.withValues(alpha: 0.7),
          size: 20,
          strokeWidth: 2.1,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Setting Toggle ──────────────────────────────────────────
class _SettingToggle extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HugeIcon(
          icon: icon,
          color: AppColors.primary.withValues(alpha: 0.7),
          size: 20,
          strokeWidth: 2.1,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}
