import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
/// Collapsible floating Liquid Glass Sidebar (matching Ngam & Ngam Business) on desktop/landscape,
/// pill-sliding BottomNav on mobile.
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  /// Allows programmatic tab switching across screens (e.g., jump from Home to Leave or Attend).
  static final ValueNotifier<int> activeTabNotifier = ValueNotifier<int>(0);

  /// Preserves sidebar expanded/collapsed state across tab & route changes.
  static final ValueNotifier<bool> isExpandedNotifier = ValueNotifier<bool>(true);

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
                          _buildNavigationRail(
                            context,
                            isDark,
                            isCompactHeight,
                            maxAvailableWidth: constraints.maxWidth,
                          ),
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

  // ─── Navigation Rail (Floating Collapsible Liquid Glass Sidebar) ─────────
  Widget _buildNavigationRail(
    BuildContext context,
    bool isDark,
    bool isCompactHeight, {
    double maxAvailableWidth = 1000,
  }) {
    final navItems = _getNavItems(context);
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata ?? const <String, dynamic>{};
    final String staffName = (meta['full_name'] ??
            meta['name'] ??
            user?.email?.split('@').first ??
            'Ngam Teams')
        .toString()
        .trim();
    final String staffSub = (user?.email ?? context.tr('nav.staff_portal')).toString();
    final double expandedWidth = (maxAvailableWidth * 0.35).clamp(180.0, 260.0);
    final double collapsedWidth = isCompactHeight ? 64.0 : 72.0;

    return ValueListenableBuilder<bool>(
      valueListenable: DashboardShell.isExpandedNotifier,
      builder: (context, isExpanded, _) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            isCompactHeight ? 10 : 16,
            isCompactHeight ? 8 : 16,
            0,
            isCompactHeight ? 8 : 16,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isCompactHeight ? 22 : 28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                width: isExpanded ? expandedWidth : collapsedWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1E2838).withValues(alpha: 0.58),
                            const Color(0xFF101622).withValues(alpha: 0.45),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.58),
                            Colors.white.withValues(alpha: 0.38),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(isCompactHeight ? 22 : 28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.75),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: isCompactHeight ? 8 : 16),

                    // ─── 1. Header Atas (Logo & Butang Kembang / Kecil) ───
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/app.png',
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/splash.png',
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2196F3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'N',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Ngam',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    'Teams',
                                    style: TextStyle(
                                      color: Color(0xFF42A5F5),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            _CollapseSidebarButton(
                              onTap: () => DashboardShell.isExpandedNotifier.value = false,
                            ),
                          ],
                        ),
                      )
                    else
                      _LogoExpandButton(
                        brandName: 'Ngam Teams',
                        onTap: () => DashboardShell.isExpandedNotifier.value = true,
                      ),

                    SizedBox(height: isCompactHeight ? 8 : 14),

                    // ─── 2. Kad Profil Staf ──────────────────────────────
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          hoverColor: Colors.white.withValues(alpha: 0.08),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: isCompactHeight ? 5 : 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildStaffSidebarAvatar(
                                  staffName,
                                  isCompactHeight ? 14 : 17,
                                  isDark,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        staffName,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black87,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 1.5),
                                      Text(
                                        staffSub,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.45)
                                              : Colors.black45,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Tooltip(
                        message: staffName,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: _buildStaffSidebarAvatar(
                            staffName,
                            isCompactHeight ? 16 : 19,
                            isDark,
                          ),
                        ),
                      ),

                    SizedBox(height: isCompactHeight ? 6 : 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                        height: 1,
                      ),
                    ),

                    SizedBox(height: isCompactHeight ? 4 : 8),

                    // ─── 3. Senarai Navigasi Menu ────────────────────────
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const ClampingScrollPhysics(),
                        itemCount: navItems.length,
                        separatorBuilder: (_, __) => SizedBox(height: isCompactHeight ? 2 : 4),
                        itemBuilder: (context, index) {
                          final item = navItems[index];
                          final selected = index == _selectedIndex;
                          return _SidebarNavItem(
                            icon: item.icon,
                            label: item.label,
                            selected: selected,
                            isExpanded: isExpanded,
                            isCompactHeight: isCompactHeight,
                            onTap: () => _onTabSelected(index),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                        height: 1,
                      ),
                    ),
                    SizedBox(height: isCompactHeight ? 4 : 6),

                    // ─── 4. Butang Log Keluar ────────────────────────────
                    _SidebarNavItem(
                      icon: HugeIcons.strokeRoundedLogout02,
                      label: context.tr('settings.sign_out'),
                      selected: false,
                      isExpanded: isExpanded,
                      isCompactHeight: isCompactHeight,
                      onTap: () => _confirmSignOut(context, isDark),
                    ),

                    SizedBox(height: isCompactHeight ? 8 : 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaffSidebarAvatar(String name, double radius, bool isDark) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'T';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.88,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF141826) : Colors.white,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context, bool isDark) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141420) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.tr('settings.sign_out'),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          context.tr('settings.sign_out_confirm'),
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              context.tr('settings.cancel'),
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(context.tr('settings.sign_out')),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
      if (context.mounted) {
        context.go('/login');
      }
    }
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

// ─────────────────────────────────────────────────────────────────────────────
// Logo Expand Button (Gemini Style: Hover logo -> Expand icon)
// ─────────────────────────────────────────────────────────────────────────────
class _LogoExpandButton extends StatefulWidget {
  final String brandName;
  final VoidCallback onTap;

  const _LogoExpandButton({
    required this.brandName,
    required this.onTap,
  });

  @override
  State<_LogoExpandButton> createState() => _LogoExpandButtonState();
}

class _LogoExpandButtonState extends State<_LogoExpandButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: _isHovered ? 'Expand sidebar' : widget.brandName,
      waitDuration: const Duration(milliseconds: 300),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _isHovered
                  ? (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isHovered
                    ? (isDark ? Colors.white.withValues(alpha: 0.18) : Colors.black12)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: _isHovered
                  ? HugeIcon(
                      key: const ValueKey('expand_icon'),
                      icon: HugeIcons.strokeRoundedSidebarLeft01,
                      color: isDark ? Colors.white : Colors.black87,
                      size: 20,
                      strokeWidth: 2.1,
                    )
                  : ClipRRect(
                      key: const ValueKey('logo_img'),
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/app.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/splash.png',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'N',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collapse Button (Gemini Style: Top right icon button to collapse sidebar)
// ─────────────────────────────────────────────────────────────────────────────
class _CollapseSidebarButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CollapseSidebarButton({required this.onTap});

  @override
  State<_CollapseSidebarButton> createState() => _CollapseSidebarButtonState();
}

class _CollapseSidebarButtonState extends State<_CollapseSidebarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: 'Collapse sidebar',
      waitDuration: const Duration(milliseconds: 300),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _isHovered
                  ? (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08))
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isHovered
                    ? (isDark ? Colors.white.withValues(alpha: 0.18) : Colors.black12)
                    : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                width: 1,
              ),
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSidebarLeft,
                color: isDark ? Colors.white70 : Colors.black87,
                size: 18,
                strokeWidth: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar Nav Item (Dual Mode: Icon + Text in Expand, Icon Only in Shrink)
// ─────────────────────────────────────────────────────────────────────────────
class _SidebarNavItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool selected;
  final bool isExpanded;
  final bool isCompactHeight;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isExpanded,
    this.isCompactHeight = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isExpanded) {
      return Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 300),
        child: Center(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(isCompactHeight ? 12 : 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isCompactHeight ? 42 : 48,
              height: isCompactHeight ? 42 : 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isCompactHeight ? 12 : 16),
                color: selected
                    ? const Color(0xFF42A5F5).withValues(alpha: 0.18)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF42A5F5).withValues(alpha: 0.35)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  color: selected
                      ? const Color(0xFF42A5F5)
                      : (isDark ? Colors.white38 : Colors.black45),
                  size: isCompactHeight ? 20 : 22,
                  strokeWidth: selected ? 2.3 : 1.9,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: isCompactHeight ? 1.5 : 3),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: isCompactHeight ? 7 : 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? const Color(0xFF42A5F5).withValues(alpha: 0.18)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? const Color(0xFF42A5F5).withValues(alpha: 0.35)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: icon,
              color: selected
                  ? const Color(0xFF42A5F5)
                  : (isDark ? Colors.white38 : Colors.black45),
              size: isCompactHeight ? 18 : 20,
              strokeWidth: selected ? 2.3 : 1.9,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? (isDark ? Colors.white : const Color(0xFF1976D2))
                      : (isDark ? Colors.white54 : Colors.black87),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: isCompactHeight ? 13 : 14,
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
