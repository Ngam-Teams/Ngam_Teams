import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_translations.dart';
import '../../../widgets/bottom_nav.dart';
import '../../home/presentation/home_screen.dart';
import '../../announcements/presentation/announcements_screen.dart';
import '../../attendance/presentation/attendance_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../core/services/app_update_service.dart';

/// Master dashboard layout — theme-aware & bilingual.
/// NavigationRail on desktop, pill-sliding BottomNav on mobile.
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  /// Allows programmatic tab switching across screens (e.g., jump from Home to Leave or Attend).
  static final ValueNotifier<int> activeTabNotifier = ValueNotifier<int>(0);

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;
  final Set<int> _activatedTabs = {0}; // Lazy tab loading cache

  @override
  void initState() {
    super.initState();
    DashboardShell.activeTabNotifier.addListener(_onTabNotifierChanged);
    _selectedIndex = DashboardShell.activeTabNotifier.value;
    _activatedTabs.add(_selectedIndex);
  }

  @override
  void dispose() {
    DashboardShell.activeTabNotifier.removeListener(_onTabNotifierChanged);
    super.dispose();
  }

  void _onTabNotifierChanged() {
    if (mounted && _selectedIndex != DashboardShell.activeTabNotifier.value) {
      setState(() {
        _selectedIndex = DashboardShell.activeTabNotifier.value;
        _activatedTabs.add(_selectedIndex);
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _activatedTabs.add(index);
    });
    DashboardShell.activeTabNotifier.value = index;
  }

  List<({dynamic icon, String label})> _getNavItems(BuildContext context) => [
        (icon: HugeIcons.strokeRoundedHome11, label: context.tr('nav.home')),
        (icon: HugeIcons.strokeRoundedMegaphone01, label: context.tr('nav.notices')),
        (icon: HugeIcons.strokeRoundedClock01, label: context.tr('nav.attend')),
        (icon: HugeIcons.strokeRoundedSettings01, label: context.tr('nav.settings')),
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final isDesktop = constraints.maxWidth >= 800;
        final isCompactHeight = constraints.maxHeight < 520;
        final useSidebar = isDesktop || isLandscape;

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          extendBody: true,
          bottomNavigationBar: useSidebar ? null : _buildBottomNav(context),
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
                child: useSidebar
                    ? Row(
                        children: [
                          _buildNavigationRail(context, isDark, isCompactHeight),
                          Expanded(child: _buildContent(context, useSidebar, isDark, isCompactHeight)),
                        ],
                      )
                    : _buildContent(context, false, isDark, false),
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
      onTap: _onTabSelected,
      items: navItems
          .map((item) => NavItem(icon: item.icon, title: item.label))
          .toList(),
    );
  }

  // ─── Navigation Rail (sidebar) ──────────────────────────────
  Widget _buildNavigationRail(BuildContext context, bool isDark, bool isCompactHeight) {
    final navItems = _getNavItems(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: isCompactHeight ? 180 : 220,
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
              SizedBox(height: isCompactHeight ? 16 : 48),

              // Logo / Wordmark
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isCompactHeight ? 14 : 20),
                child: Row(
                  children: [
                    Container(
                      width: isCompactHeight ? 28 : 36,
                      height: isCompactHeight ? 28 : 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isCompactHeight ? 8 : 10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/app.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngam',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                            fontSize: isCompactHeight ? 14 : 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Teams',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: isCompactHeight ? 9 : 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: isCompactHeight ? 16 : 40),

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
                  isCompact: isCompactHeight,
                  onTap: () => _onTabSelected(index),
                );
              }),

              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isCompactHeight ? 10 : 12),
                child: ValueListenableBuilder<String>(
                  valueListenable: AppUpdateService.versionNotifier,
                  builder: (context, ver, _) {
                    return ValueListenableBuilder<AppReleaseInfo?>(
                      valueListenable: AppUpdateService.availableUpdateNotifier,
                      builder: (context, update, _) {
                        final hasUpdate = update != null;
                        final Color statusColor =
                            hasUpdate ? Colors.amberAccent : const Color(0xFF10B981);

                        return Tooltip(
                          message: context.tr('update.check_tooltip'),
                          child: InkWell(
                            onTap: () {
                              if (update != null) {
                                AppUpdateService.showUpdateDialog(context, update);
                              } else {
                                AppUpdateService.checkManually(context);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: isCompactHeight ? 6 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(
                                  alpha: hasUpdate ? 0.14 : 0.07,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor.withValues(
                                    alpha: hasUpdate ? 0.45 : 0.22,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Ngam Teams v$ver',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : const Color(0xFF334155),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      hasUpdate
                                          ? context
                                              .tr('update.update_pill')
                                              .replaceAll('{v}', update.version)
                                          : context.tr('update.latest_pill'),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: isCompactHeight ? 10 : 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Content Area ───────────────────────────────────────────
  Widget _buildContent(BuildContext context, bool useSidebar, bool isDark, bool isCompactHeight) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCompactHeight ? 16 : (useSidebar ? 28 : 16),
        isCompactHeight ? 12 : (useSidebar ? 24 : 16),
        isCompactHeight ? 16 : (useSidebar ? 28 : 16),
        isCompactHeight ? 12 : (useSidebar ? 24 : 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPageTitle(context),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: isCompactHeight ? 20 : (useSidebar ? 26 : 28),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            context.tr('nav.staff_portal'),
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : const Color(0xFF64748B),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ValueListenableBuilder<String>(
                          valueListenable: AppUpdateService.versionNotifier,
                          builder: (context, ver, _) {
                            return ValueListenableBuilder<AppReleaseInfo?>(
                              valueListenable:
                                  AppUpdateService.availableUpdateNotifier,
                              builder: (context, update, _) {
                                final hasUpdate = update != null;
                                final Color pillColor = hasUpdate
                                    ? Colors.amberAccent
                                    : AppColors.primary;
                                return Tooltip(
                                  message: context.tr('update.check_tooltip'),
                                  child: InkWell(
                                    onTap: () {
                                      if (update != null) {
                                        AppUpdateService.showUpdateDialog(
                                            context, update);
                                      } else {
                                        AppUpdateService.checkManually(context);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pillColor.withValues(
                                          alpha: hasUpdate ? 0.18 : 0.14,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: pillColor.withValues(
                                            alpha: hasUpdate ? 0.5 : 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        hasUpdate
                                            ? 'v$ver → ${context.tr('update.update_pill').replaceAll('{v}', update.version)}'
                                            : 'v$ver • ${context.tr('update.latest_pill')}',
                                        style: TextStyle(
                                          color: pillColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
        3 => context.tr('nav.settings'),
        _ => 'Teams',
      };

  Widget _buildPageBody() {
    return IndexedStack(
      index: _selectedIndex.clamp(0, 3),
      children: [
        _activatedTabs.contains(0) ? const HomeScreen() : const SizedBox.shrink(),
        _activatedTabs.contains(1) ? const AnnouncementsScreen() : const SizedBox.shrink(),
        _activatedTabs.contains(2) ? const AttendanceScreen() : const SizedBox.shrink(),
        _activatedTabs.contains(3) ? const SettingsScreen() : const SizedBox.shrink(),
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
  final bool isCompact;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isDark,
    this.isCompact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12,
          vertical: isCompact ? 2 : 3,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 10 : 14,
          vertical: isCompact ? 8 : 12,
        ),
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
              size: isCompact ? 16 : 20,
              strokeWidth: 2.1,
            ),
            SizedBox(width: isCompact ? 8 : 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppColors.primary
                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  fontSize: isCompact ? 12 : 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
