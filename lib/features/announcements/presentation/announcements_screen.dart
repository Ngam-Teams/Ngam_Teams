import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../core/services/teams_supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_panel.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  int? _expandedIndex;
  bool _isLoading = true;
  List<_Announcement> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final rows = await TeamsSupabaseService.instance.fetchAnnouncements();
      if (!mounted) return;
      setState(() {
        _announcements = rows.map((row) {
          final rawPriority = (row['priority'] as String?) ?? 'Info';
          final createdRaw = (row['created_at'] as String?) ?? '';
          final parsedDt = DateTime.tryParse(createdRaw)?.toLocal();
          final dateStr = parsedDt != null
              ? DateFormat('dd MMM yyyy').format(parsedDt)
              : (createdRaw.isNotEmpty ? createdRaw : 'Terkini');

          Color pColor = AppColors.info;
          String pLabel = rawPriority;
          if (rawPriority == 'Important' || rawPriority == 'high') {
            pColor = AppColors.error;
            pLabel = 'Penting';
          } else if (rawPriority == 'Reminder') {
            pColor = AppColors.warning;
            pLabel = 'Peringatan';
          } else if (rawPriority == 'Notice' || rawPriority == 'low') {
            pColor = AppColors.secondary;
            pLabel = 'Notis';
          } else {
            pColor = AppColors.info;
            pLabel = 'Maklumat';
          }

          return _Announcement(
            title: (row['title'] as String?) ?? 'Pengumuman',
            body: (row['body'] as String?) ?? (row['content'] as String?) ?? '',
            date: dateStr,
            priority: pLabel,
            priorityColor: pColor,
            isPinned: row['is_pinned'] == true,
            author: (row['author_name'] as String?) ?? 'Pengurusan',
          );
        }).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_announcements.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadAnnouncements,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 80, bottom: 120, left: 24, right: 24),
          children: [
            GlassPanel(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedMegaphone01,
                    color: isDark ? Colors.white38 : Colors.black38,
                    size: 44,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tiada Pengumuman Semasa',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sebarang notis atau pengumuman rasmi daripada pihak pengurusan kedai akan dipaparkan di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Sort: pinned first
    final sorted = List<_Announcement>.from(_announcements)
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAnnouncements,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        itemCount: sorted.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
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
      ),
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
