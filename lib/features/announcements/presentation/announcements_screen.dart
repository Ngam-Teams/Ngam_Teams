import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_panel.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  int? _expandedIndex;

  final List<_Announcement> _announcements = [
    _Announcement(
      title: 'Office Closure — Hari Raya Aidilfitri',
      body:
          'Assalamualaikum & Salam Sejahtera,\n\nThe office will be closed from 15th–17th October in conjunction with Hari Raya Aidilfitri. All staff are reminded to clear their pending tasks before the holiday.\n\nPlease ensure all client-facing work is handled accordingly. Emergency contacts will be shared via the group chat.\n\nSelamat Hari Raya to all! 🌙',
      date: 'Sep 17, 2026',
      priority: 'Important',
      priorityColor: AppColors.error,
      isPinned: true,
      author: 'HR Department',
    ),
    _Announcement(
      title: 'New Staff Onboarding — October Batch',
      body:
          'We are excited to welcome 5 new team members joining us in October:\n\n• Sarah — Marketing\n• Aiman — Engineering\n• Nurul — Customer Support\n• Hafiz — Operations\n• Mei Lin — Finance\n\nPlease help them settle in and feel welcome! Mentors will be assigned by end of this week.',
      date: 'Sep 15, 2026',
      priority: 'Info',
      priorityColor: AppColors.info,
      isPinned: true,
      author: 'People & Culture',
    ),
    _Announcement(
      title: 'Monthly Team Meeting — Friday',
      body:
          'Reminder: Our monthly all-hands meeting is this Friday at 3:00 PM in Conference Room A.\n\nAgenda:\n1. Q3 Performance Review\n2. New project kickoffs\n3. Team building event planning\n4. Open floor Q&A\n\nPlease prepare your updates!',
      date: 'Sep 14, 2026',
      priority: 'Reminder',
      priorityColor: AppColors.warning,
      isPinned: false,
      author: 'Management',
    ),
    _Announcement(
      title: 'IT Maintenance — Saturday Night',
      body:
          'The IT team will be performing scheduled maintenance on our internal systems this Saturday from 10 PM – 2 AM.\n\nDuring this time, email and internal tools may be temporarily unavailable. Please plan your work accordingly.',
      date: 'Sep 13, 2026',
      priority: 'Notice',
      priorityColor: AppColors.secondary,
      isPinned: false,
      author: 'IT Department',
    ),
    _Announcement(
      title: 'Parking Lot Expansion',
      body:
          'Good news! The parking lot expansion project has been completed. We now have 30 additional parking spots available on Level B2.\n\nNew spots will be allocated on a first-come-first-served basis starting next Monday.',
      date: 'Sep 10, 2026',
      priority: 'Info',
      priorityColor: AppColors.info,
      isPinned: false,
      author: 'Admin & Facilities',
    ),
    _Announcement(
      title: 'Employee Wellness Program Launch',
      body:
          'We are launching a new wellness program for all employees! Benefits include:\n\n• Free gym membership at partner gyms\n• Monthly wellness workshops\n• Mental health support hotline\n• Healthy snacks in the pantry\n\nSign up through HR by end of September.',
      date: 'Sep 8, 2026',
      priority: 'New',
      priorityColor: AppColors.success,
      isPinned: false,
      author: 'HR Department',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Sort: pinned first
    final sorted = List<_Announcement>.from(_announcements)
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final a = sorted[index];
        final isExpanded = _expandedIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          child: GlassPanel(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Priority badge + Pinned
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: a.priorityColor.withValues(alpha: isDark ? 0.15 : 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: a.priorityColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        a.priority,
                        style: TextStyle(
                          color: a.priorityColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (a.isPinned) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.push_pin_rounded,
                        color: AppColors.warning.withValues(alpha: 0.8),
                        size: 16,
                      ),
                    ],
                    const Spacer(),
                    Text(
                      a.date,
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  a.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Body
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Text(
                    a.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF475569),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  secondChild: Text(
                    a.body,
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.75) : const Color(0xFF334155),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Author + expand hint
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF94A3B8),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      a.author,
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF94A3B8),
                        size: 20,
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
  }
}

class _Announcement {
  final String title;
  final String body;
  final String date;
  final String priority;
  final Color priorityColor;
  final bool isPinned;
  final String author;

  const _Announcement({
    required this.title,
    required this.body,
    required this.date,
    required this.priority,
    required this.priorityColor,
    required this.isPinned,
    required this.author,
  });
}
