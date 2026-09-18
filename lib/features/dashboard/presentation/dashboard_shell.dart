import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_translations.dart';
import '../../../widgets/bottom_nav.dart';
import '../../home/presentation/home_screen.dart';
import '../../announcements/presentation/announcements_screen.dart';
import '../../attendance/presentation/attendance_screen.dart';
import '../../leave/presentation/leave_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../settings/presentation/settings_screen.dart';

/// Master dashboard layout — theme-aware & bilingual.
/// NavigationRail on desktop, pill-sliding BottomNav on mobile.
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  List<({dynamic icon, String label})> _getNavItems(BuildContext context) => [
        (icon: HugeIcons.strokeRoundedHome11, label: context.tr('nav.home')),
        (icon: HugeIcons.strokeRoundedMegaphone01, label: context.tr('nav.notices')),
        (icon: HugeIcons.strokeRoundedClock01, label: context.tr('nav.attend')),
        (icon: HugeIcons.strokeRoundedCalendar03, label: context.tr('nav.leave')),
        (icon: HugeIcons.strokeRoundedSettings01, label: context.tr('nav.settings')),
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          extendBody: true,
          bottomNavigationBar: isDesktop ? null : _buildBottomNav(context),
          body: Stack(
            children: [
              // Ambient soft radiant blobs for realistic frosted glass refraction
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.2, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: -60,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4ECDC4).withValues(alpha: isDark ? 0.14 : 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.2, 1.0],
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: isDesktop
                    ? Row(
                        children: [
                          _buildNavigationRail(context, isDark),
                          Expanded(child: _buildContent(context, isDesktop, isDark)),
                        ],
                      )
                    : _buildContent(context, isDesktop, isDark),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final navItems = _getNavItems(context);
    return BottomNav(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: navItems
          .map((item) => NavItem(icon: item.icon, title: item.label))
          .toList(),
    );
  }

  // ─── Navigation Rail (sidebar) ──────────────────────────────
  Widget _buildNavigationRail(BuildContext context, bool isDark) {
    final navItems = _getNavItems(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.55),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.7),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Logo / Wordmark
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/app.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngam',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Text(
                          'Teams',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Nav items
              ...navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final selected = index == _selectedIndex;

                return _NavItem(
                  icon: item.icon,
                  label: item.label,
                  selected: selected,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              }),

              const Spacer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Content Area ───────────────────────────────────────────
  Widget _buildContent(BuildContext context, bool isDesktop, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 32 : 16,
        isDesktop ? 32 : 16,
        isDesktop ? 32 : 16,
        isDesktop ? 32 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getPageTitle(context),
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('nav.staff_portal'),
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : const Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              _buildTopBarActions(context, isDark),
            ],
          ),
          const SizedBox(height: 12),

          // Page body
          Expanded(child: _buildPageBody()),
        ],
      ),
    );
  }

  String _getPageTitle(BuildContext context) => switch (_selectedIndex) {
        0 => context.tr('nav.home'),
        1 => context.tr('nav.notices'),
        2 => context.tr('nav.attend'),
        3 => context.tr('nav.leave'),
        4 => context.tr('nav.settings'),
        _ => 'Teams',
      };

  Widget _buildPageBody() {
    return IndexedStack(
      index: _selectedIndex.clamp(0, 4),
      children: const [
        HomeScreen(),
        AnnouncementsScreen(),
        AttendanceScreen(),
        LeaveScreen(),
        SettingsScreen(),
      ],
    );
  }

  Widget _buildTopBarActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedNotification02,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
            size: 20,
            strokeWidth: 2.1,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: AppColors.primary,
              size: 18,
              strokeWidth: 2.1,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Nav Item ────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.12)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: icon,
              color: selected
                  ? AppColors.primary
                  : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
              size: 20,
              strokeWidth: 2.1,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppColors.primary
                    : (isDark ? Colors.white70 : const Color(0xFF475569)),
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
