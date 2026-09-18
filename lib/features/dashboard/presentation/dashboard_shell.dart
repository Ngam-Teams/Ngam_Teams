import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/bottom_nav.dart';
import '../../home/presentation/home_screen.dart';
import '../../announcements/presentation/announcements_screen.dart';
import '../../attendance/presentation/attendance_screen.dart';
import '../../leave/presentation/leave_screen.dart';
import '../../profile/presentation/profile_screen.dart';

/// Master dashboard layout — same pattern as Ngam Admin.
/// NavigationRail on desktop, pill-sliding BottomNav on mobile.
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  static const _navItems = [
    (icon: HugeIcons.strokeRoundedHome11, label: 'Home'),
    (icon: HugeIcons.strokeRoundedMegaphone01, label: 'Notices'),
    (icon: HugeIcons.strokeRoundedClock01, label: 'Attend'),
    (icon: HugeIcons.strokeRoundedCalendar03, label: 'Leave'),
    (icon: HugeIcons.strokeRoundedUser, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
          body: SafeArea(
            bottom: false,
            child: isDesktop
                ? Row(
                    children: [
                      _buildNavigationRail(),
                      Expanded(child: _buildContent(isDesktop)),
                    ],
                  )
                : _buildContent(isDesktop),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNav(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: _navItems
          .map((item) => NavItem(icon: item.icon, title: item.label))
          .toList(),
    );
  }

  // ─── Navigation Rail (frosted glass sidebar) ────────────────
  Widget _buildNavigationRail() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: 220,
          color: Colors.white.withValues(alpha: 0.04),
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
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngam',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
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
              ..._navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final selected = index == _selectedIndex;

                return _NavItem(
                  icon: item.icon,
                  label: item.label,
                  selected: selected,
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
  Widget _buildContent(bool isDesktop) {
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
                    _pageTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Staff Portal',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              _buildTopBarActions(),
            ],
          ),
          const SizedBox(height: 12),

          // Page body
          Expanded(child: _buildPageBody()),
        ],
      ),
    );
  }

  String get _pageTitle => switch (_selectedIndex) {
        0 => 'Home',
        1 => 'Announcements',
        2 => 'Attendance',
        3 => 'Leave',
        4 => 'Profile',
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
        ProfileScreen(),
      ],
    );
  }

  Widget _buildTopBarActions() {
    return Row(
      children: [
        IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedNotification02,
            color: Colors.white54,
            size: 20,
            strokeWidth: 2.1,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withValues(alpha: 0.3),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedUser,
            color: AppColors.primary,
            size: 18,
            strokeWidth: 2.1,
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
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
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
              ? AppColors.primary.withValues(alpha: 0.18)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: icon,
              color: selected ? AppColors.primary : Colors.white38,
              size: 20,
              strokeWidth: 2.1,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
