import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Welcome Header ───────────────────────────────────
          _buildWelcomeHeader(),
          const SizedBox(height: 24),

          // ─── Quick Stats Row ──────────────────────────────────
          _buildQuickStats(),
          const SizedBox(height: 24),

          // ─── Quick Actions ────────────────────────────────────
          GlassPanel(
            title: 'Quick Actions',
            icon: HugeIcons.strokeRoundedZap,
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionChip(
                    icon: HugeIcons.strokeRoundedClock01,
                    label: 'Clock In',
                    color: AppColors.success,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionChip(
                    icon: HugeIcons.strokeRoundedCalendar03,
                    label: 'Apply Leave',
                    color: AppColors.info,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionChip(
                    icon: HugeIcons.strokeRoundedNotification02,
                    label: 'Notices',
                    color: AppColors.warning,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── Recent Announcements ─────────────────────────────
          GlassPanel(
            title: 'Recent Announcements',
            icon: HugeIcons.strokeRoundedMegaphone01,
            child: Column(
              children: [
                _AnnouncementPreview(
                  title: 'Office Closure — Hari Raya',
                  body: 'The office will be closed from 15th–17th October. Enjoy the holidays!',
                  date: 'Today',
                  isPinned: true,
                ),
                const SizedBox(height: 16),
                _AnnouncementPreview(
                  title: 'New Staff Onboarding',
                  body: 'Welcome our new team members joining this month. Please help them settle in.',
                  date: '2 days ago',
                  isPinned: false,
                ),
                const SizedBox(height: 16),
                _AnnouncementPreview(
                  title: 'Monthly Team Meeting',
                  body: 'Reminder: Monthly meeting this Friday at 3 PM in the conference room.',
                  date: '4 days ago',
                  isPinned: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── This Week Summary ────────────────────────────────
          GlassPanel(
            title: 'This Week',
            icon: HugeIcons.strokeRoundedCalendar03,
            child: Column(
              children: [
                _WeekRow(day: 'Mon', status: 'Present', time: '09:02 – 18:00', color: AppColors.success),
                const SizedBox(height: 12),
                _WeekRow(day: 'Tue', status: 'Present', time: '08:55 – 18:15', color: AppColors.success),
                const SizedBox(height: 12),
                _WeekRow(day: 'Wed', status: 'Present', time: '09:10 – 18:05', color: AppColors.success),
                const SizedBox(height: 12),
                _WeekRow(day: 'Thu', status: 'Today', time: '09:00 – …', color: AppColors.primary),
                const SizedBox(height: 12),
                _WeekRow(day: 'Fri', status: '—', time: '—', color: AppColors.textTertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'AH',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good Morning 👋',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ahmad Haziq',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Checked In — 09:00 AM',
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

  Widget _buildQuickStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Attendance Rate',
                  value: '96%',
                  subtitle: 'This month',
                  icon: HugeIcons.strokeRoundedChartIncrease,
                  accentColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Leave Balance',
                  value: '12',
                  subtitle: 'Days left',
                  icon: HugeIcons.strokeRoundedCalendar03,
                  accentColor: AppColors.info,
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            StatCard(
              label: 'Attendance Rate',
              value: '96%',
              subtitle: 'This month',
              icon: HugeIcons.strokeRoundedChartIncrease,
              accentColor: AppColors.success,
            ),
            const SizedBox(height: 16),
            StatCard(
              label: 'Leave Balance',
              value: '12',
              subtitle: 'Days left',
              icon: HugeIcons.strokeRoundedCalendar03,
              accentColor: AppColors.info,
            ),
          ],
        );
      },
    );
  }
}

// ─── Quick Action Chip ────────────────────────────────────────
class _QuickActionChip extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            HugeIcon(icon: icon, color: color, size: 24, strokeWidth: 2.1),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Announcement Preview ─────────────────────────────────────
class _AnnouncementPreview extends StatelessWidget {
  final String title;
  final String body;
  final String date;
  final bool isPinned;

  const _AnnouncementPreview({
    required this.title,
    required this.body,
    required this.date,
    required this.isPinned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPinned
              ? AppColors.warning.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isPinned) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin_rounded, color: AppColors.warning, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Pinned',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Week Row ─────────────────────────────────────────────────
class _WeekRow extends StatelessWidget {
  final String day;
  final String status;
  final String time;
  final Color color;

  const _WeekRow({
    required this.day,
    required this.status,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            day,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
