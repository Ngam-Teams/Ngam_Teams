import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/localization/app_translations.dart';
import '../../../widgets/glass_toast.dart';
import '../../../widgets/modal_sheet.dart';
import '../../profile/presentation/profile_screen.dart';

// ============================================================
// Ngam Teams — Settings Screen
// Responsive settings hub supporting real-time theme switching
// (Dark/Light) and bilingual localization (English / Bahasa Melayu).
// ============================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = AppSettings.instance.languageCode;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ─── Header Profil (Tappable to go to Profile) ──
              _buildProfileHeader(isDark),
              const SizedBox(height: 24),

              // ─── Quick Statistics ──────────────────────────
              _buildSectionHeader(context.tr('settings.statistics'), isDark),
              Row(
                children: [
                  _StatCardGlass(
                    label: context.tr('settings.attendance_stat'),
                    value: '98.5%',
                    icon: HugeIcons.strokeRoundedClock01,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _StatCardGlass(
                    label: context.tr('settings.leave_stat'),
                    value: currentLang == 'ms' ? '14 Hari' : '14 Days',
                    icon: HugeIcons.strokeRoundedCalendar03,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _StatCardGlass(
                    label: context.tr('settings.perf_stat'),
                    value: '4.9 ★',
                    icon: HugeIcons.strokeRoundedStar,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Account Section ────────────────────────────
              _buildSectionHeader(context.tr('settings.account'), isDark),
              _buildGlassSection(
                isDark,
                Column(
                  children: [
                    _buildSettingsTile(
                      isDark,
                      HugeIcons.strokeRoundedUserEdit01,
                      context.tr('settings.staff_profile'),
                      subtitle: context.tr('settings.staff_profile_sub'),
                      onTap: _navigateToProfile,
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      isDark,
                      HugeIcons.strokeRoundedShield01,
                      context.tr('settings.security'),
                      subtitle: context.tr('settings.security_sub'),
                      onTap: () => _showSecurityModal(context, isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Preferences Section ────────────────────────
              _buildSectionHeader(context.tr('settings.preferences'), isDark),
              _buildGlassSection(
                isDark,
                Column(
                  children: [
                    _buildToggleTile(
                      isDark: isDark,
                      icon: HugeIcons.strokeRoundedNotification02,
                      title: context.tr('settings.push_notifications'),
                      value: _notificationsEnabled,
                      onChanged: (v) {
                        setState(() => _notificationsEnabled = v);
                        showGlassToast(
                          context,
                          v
                              ? (currentLang == 'ms' ? 'Notifikasi diaktifkan' : 'Notifications enabled')
                              : (currentLang == 'ms' ? 'Notifikasi dinyahaktifkan' : 'Notifications silenced'),
                        );
                      },
                    ),
                    _buildDivider(isDark),
                    _buildToggleTile(
                      isDark: isDark,
                      icon: HugeIcons.strokeRoundedMoon02,
                      title: context.tr('settings.dark_mode'),
                      value: AppSettings.instance.isDarkMode,
                      onChanged: (v) {
                        AppSettings.instance.setDarkMode(v);
                        showGlassToast(
                          context,
                          v
                              ? (currentLang == 'ms' ? 'Mod Gelap Aktif' : 'Dark Mode: ON')
                              : (currentLang == 'ms' ? 'Mod Cerah Aktif' : 'Light Mode: ON'),
                        );
                      },
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      isDark,
                      HugeIcons.strokeRoundedGlobe02,
                      context.tr('settings.language'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentLang == 'ms'
                                ? 'Bahasa Melayu'
                                : 'English',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : const Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildArrow(isDark),
                        ],
                      ),
                      onTap: () => _showLanguageSelector(context, isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Support Section ────────────────────────────
              _buildSectionHeader(context.tr('settings.support'), isDark),
              _buildGlassSection(
                isDark,
                Column(
                  children: [
                    _buildSettingsTile(
                      isDark,
                      HugeIcons.strokeRoundedCustomerService,
                      context.tr('settings.help_center'),
                      subtitle: context.tr('settings.help_center_sub'),
                      onTap: () => _showHelpCenter(context, isDark),
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      isDark,
                      HugeIcons.strokeRoundedCall02,
                      context.tr('settings.contact_support'),
                      subtitle: context.tr('settings.contact_support_sub'),
                      onTap: () => _showContactSupport(context, isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── About Section ──────────────────────────────
              _buildSectionHeader(context.tr('settings.about'), isDark),
              _buildGlassSection(
                isDark,
                Column(
                  children: [
                    _buildSettingsTile(
                      isDark,
                      HugeIcons.strokeRoundedInformationCircle,
                      context.tr('settings.terms'),
                      onTap: () => _showLegalModal(
                        context,
                        isDark,
                        context.tr('settings.terms'),
                        _termsContent,
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      isDark,
                      HugeIcons.strokeRoundedShield01,
                      context.tr('settings.privacy'),
                      onTap: () => _showLegalModal(
                        context,
                        isDark,
                        context.tr('settings.privacy'),
                        _privacyContent,
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      isDark,
                      HugeIcons.strokeRoundedBuilding03,
                      context.tr('settings.about_teams'),
                      trailing: Text(
                        'v0.1.0',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : const Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => _showAboutApp(context, isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ─── Sign Out Button ────────────────────────────
              _buildGlassButton(
                isDark: isDark,
                label: context.tr('settings.sign_out'),
                color: AppColors.error,
                icon: HugeIcons.strokeRoundedLogout02,
                onTap: () => _showSignOutDialog(context, isDark),
              ),
              const SizedBox(height: 24),

              // ─── App Footer ─────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Text(
                      'Ngam Teams v0.1.0',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('settings.made_with_love'),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFF94A3B8),
                        fontSize: 11,
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

  // ─── Header Profil Card ───────────────────────────────────────
  Widget _buildProfileHeader(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _navigateToProfile,
        borderRadius: BorderRadius.circular(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                    AppColors.secondary.withValues(alpha: isDark ? 0.08 : 0.06),
                  ],
                ),
                color: isDark ? null : Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.65),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'AH',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Ahmad Haziq',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.success.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                context.tr('profile.active'),
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Senior Developer • Engineering',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ahmad.haziq@ngam.my',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.38)
                                : const Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action arrow
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Section Header ──────────────────────────────────────────
  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.45)
              : const Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ─── Glass Container Section ─────────────────────────────────
  Widget _buildGlassSection(bool isDark, Widget child) {
    return GlassContainer(
      useOwnLayer: true,
      quality: GlassQuality.standard,
      shape: const LiquidRoundedSuperellipse(borderRadius: 24.0),
      settings: LiquidGlassSettings(
        thickness: 0.1,
        blur: 15,
        refractiveIndex: 1.0,
        glassColor: Colors.transparent,
        lightAngle: 45.0,
        lightIntensity: isDark ? 0.1 : 0.2,
        ambientStrength: 1.0,
        saturation: 1.0,
        chromaticAberration: 0.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.65),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  // ─── Settings Tile ───────────────────────────────────────────
  Widget _buildSettingsTile(
    bool isDark,
    dynamic icon,
    String title, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(
                  icon: icon,
                  color: AppColors.primary,
                  size: 20,
                  strokeWidth: 2.1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.45)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                trailing,
              ] else ...[
                _buildArrow(isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Toggle Tile ─────────────────────────────────────────────
  Widget _buildToggleTile({
    required bool isDark,
    required dynamic icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: HugeIcon(
              icon: icon,
              color: AppColors.primary,
              size: 20,
              strokeWidth: 2.1,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
            inactiveThumbColor: isDark ? Colors.grey.shade400 : Colors.white,
            inactiveTrackColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.shade300,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ─── Glass Action Button ─────────────────────────────────────
  Widget _buildGlassButton({
    required bool isDark,
    required String label,
    required Color color,
    required dynamic icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        useOwnLayer: true,
        quality: GlassQuality.standard,
        shape: const LiquidRoundedSuperellipse(borderRadius: 20.0),
        settings: LiquidGlassSettings(
          thickness: 0.1,
          blur: 15,
          refractiveIndex: 1.0,
          glassColor: Colors.transparent,
          lightAngle: 45.0,
          lightIntensity: isDark ? 0.1 : 0.2,
          ambientStrength: 1.0,
          saturation: 1.0,
          chromaticAberration: 0.0,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.35 : 0.4),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: icon,
                color: color,
                size: 20,
                strokeWidth: 2.2,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) => Padding(
        padding: const EdgeInsets.only(left: 62, right: 18),
        child: Divider(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      );

  Widget _buildArrow(bool isDark) => HugeIcon(
        icon: HugeIcons.strokeRoundedArrowRight01,
        color: isDark
            ? Colors.white.withValues(alpha: 0.3)
            : const Color(0xFF94A3B8),
        size: 18,
      );

  // ─── Modal Sheets & Dialogs ──────────────────────────────────

  void _showLanguageSelector(BuildContext context, bool isDark) {
    final currentLang = AppSettings.instance.languageCode;

    ModalSheet.show(
      context: context,
      initialChildSize: 0.38,
      minChildSize: 0.3,
      maxChildSize: 0.5,
      builder: (ctx, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('settings.choose_language'),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            _buildLanguageOption(
              context: ctx,
              isDark: isDark,
              title: 'English (US)',
              code: 'en',
              isSelected: currentLang == 'en',
            ),
            const SizedBox(height: 10),
            _buildLanguageOption(
              context: ctx,
              isDark: isDark,
              title: 'Bahasa Melayu',
              code: 'ms',
              isSelected: currentLang == 'ms',
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String code,
    required bool isSelected,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.white12 : Colors.grey.shade300),
          width: 1.2,
        ),
      ),
      tileColor: isSelected
          ? AppColors.primary.withValues(alpha: 0.12)
          : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100),
      leading: HugeIcon(
        icon: HugeIcons.strokeRoundedTranslate,
        color: isSelected ? AppColors.primary : (isDark ? Colors.white60 : Colors.grey.shade600),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const HugeIcon(
              icon: HugeIcons.strokeRoundedTick01,
              color: AppColors.primary,
              size: 20,
            )
          : null,
      onTap: () {
        AppSettings.instance.setLanguageCode(code);
        Navigator.pop(context);
        showGlassToast(
          context,
          code == 'ms' ? 'Bahasa ditukar ke Bahasa Melayu' : 'Language set to English',
        );
      },
    );
  }

  void _showSecurityModal(BuildContext context, bool isDark) {
    ModalSheet.show(
      context: context,
      initialChildSize: 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.7,
      builder: (ctx, scrollController) {
        return ListView(
          controller: scrollController,
          children: [
            Text(
              context.tr('settings.security'),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('settings.security_sub'),
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingsTile(
              isDark,
              HugeIcons.strokeRoundedLockKey,
              'Change Password',
              subtitle: 'Last updated 45 days ago',
              onTap: () {
                Navigator.pop(ctx);
                showGlassToast(context, 'Password reset link sent to work email');
              },
            ),
            _buildDivider(isDark),
            _buildSettingsTile(
              isDark,
              HugeIcons.strokeRoundedBiometricAccess,
              'Biometric Sign-In',
              subtitle: 'Use fingerprint or face recognition',
              trailing: Switch.adaptive(
                value: true,
                activeColor: AppColors.primary,
                onChanged: (_) {},
              ),
            ),
            _buildDivider(isDark),
            _buildSettingsTile(
              isDark,
              HugeIcons.strokeRoundedSmartPhone01,
              'Active Sessions',
              subtitle: '1 mobile app, 1 web browser',
              onTap: () {
                showGlassToast(context, 'All sessions verified');
              },
            ),
          ],
        );
      },
    );
  }

  void _showHelpCenter(BuildContext context, bool isDark) {
    final currentLang = AppSettings.instance.languageCode;

    ModalSheet.show(
      context: context,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (ctx, scrollController) {
        return ListView(
          controller: scrollController,
          children: [
            Text(
              context.tr('settings.help_center'),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('settings.help_center_sub'),
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _buildFaqTile(
              isDark,
              currentLang == 'ms' ? 'Bagaimana cara mendaftar kehadiran?' : 'How do I check in for my shift?',
              currentLang == 'ms'
                  ? 'Pergi ke tab Kehadiran dan tekan "Daftar Masuk". Lokasi geofence dan WiFi akan disahkan secara automatik.'
                  : 'Head to the Attend tab and tap "Check In". Geofencing and WiFi authentication are automatically checked.',
            ),
            _buildFaqTile(
              isDark,
              currentLang == 'ms' ? 'Bagaimana memohon cuti tahunan atau perubatan?' : 'How to apply for annual or medical leave?',
              currentLang == 'ms'
                  ? 'Buka tab Cuti, tekan butang "+", pilih tarikh dan kategori cuti, kemudian hantar untuk kelulusan penyelia.'
                  : 'Open the Leave tab, tap the "+" button, select the dates and leave category, then submit for manager approval.',
            ),
            _buildFaqTile(
              isDark,
              currentLang == 'ms' ? 'Di mana saya boleh melihat pengumuman syarikat?' : 'Where can I see company announcements?',
              currentLang == 'ms'
                  ? 'Semua notis rasmi korporat dan siaran cawangan boleh didapati di bawah tab Notis.'
                  : 'All official corporate notices and branch broadcasts are located under the Notices tab.',
            ),
          ],
        );
      },
    );
  }

  Widget _buildFaqTile(bool isDark, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupport(BuildContext context, bool isDark) {
    ModalSheet.show(
      context: context,
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.65,
      builder: (ctx, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('settings.contact_support'),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('settings.contact_support_sub'),
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingsTile(
              isDark,
              HugeIcons.strokeRoundedMail01,
              'HR Support Email',
              subtitle: 'hr@ngam.my',
              onTap: () {
                Navigator.pop(ctx);
                showGlassToast(context, 'Opening email client to hr@ngam.my');
              },
            ),
            _buildDivider(isDark),
            _buildSettingsTile(
              isDark,
              HugeIcons.strokeRoundedCall02,
              'IT Helpdesk Hotline',
              subtitle: '+60 3-8888 1234 (Ext: 104)',
              onTap: () {
                Navigator.pop(ctx);
                showGlassToast(context, 'Calling IT Helpdesk...');
              },
            ),
          ],
        );
      },
    );
  }

  void _showLegalModal(BuildContext context, bool isDark, String title, String content) {
    ModalSheet.show(
      context: context,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return ListView(
          controller: scrollController,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.75) : const Color(0xFF334155),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutApp(BuildContext context, bool isDark) {
    ModalSheet.show(
      context: context,
      initialChildSize: 0.42,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset('assets/app.png', fit: BoxFit.cover),
            ),
            const SizedBox(height: 14),
            Text(
              'Ngam Teams',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Staff & Employee Companion Portal',
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                'Version 0.1.0 (Build 2026.09.18)',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161622) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          ),
        ),
        title: Row(
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedLogout02,
              color: AppColors.error,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              context.tr('settings.sign_out'),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          context.tr('settings.sign_out_confirm'),
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              context.tr('settings.cancel'),
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
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
            onPressed: () {
              Navigator.pop(dialogCtx);
              showGlassToast(context, 'Signed out successfully');
              context.go('/login');
            },
            child: Text(context.tr('settings.sign_out')),
          ),
        ],
      ),
    );
  }

  static const _termsContent = '''
Ngam Teams Portal Terms of Service

1. Acceptable Use
This platform is provided strictly for authorized staff and personnel of Ngam and its business partners. You agree to use the portal exclusively for employment-related duties including attendance recording, leave management, and company communications.

2. Account Responsibility
You are responsible for maintaining the confidentiality of your login credentials. Do not share your staff credentials with any third party. Report any unauthorized account activity immediately to IT Security.

3. Attendance & GPS Integrity
Attendance clock-ins use device geolocation and WiFi network signals. Tampering with geolocation, mock locations, or clocking in on behalf of another colleague constitutes gross misconduct.

4. Data Privacy
All company announcements, internal documents, and staff directories accessible via this application are proprietary and confidential.
''';

  static const _privacyContent = '''
Ngam Teams Privacy Policy

1. Data Collection
We collect personal information necessary for workplace administration, including your name, staff identification number, work email, office phone number, employment department, attendance timestamps, and geolocation during clock-in events.

2. Purpose of Processing
Your data is used solely to calculate work hours, process annual and medical leave entitlements, compute payroll allowances, and broadcast corporate notices.

3. Retention & Security
All records are protected using enterprise-grade encryption at rest and in transit. Access is limited strictly to authorized HR and management personnel in compliance with applicable data protection laws.
''';
}

// ─── Stat Card Glass Widget ────────────────────────────────────
class _StatCardGlass extends StatelessWidget {
  final String label;
  final String value;
  final dynamic icon;
  final bool isDark;

  const _StatCardGlass({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        useOwnLayer: true,
        quality: GlassQuality.standard,
        shape: const LiquidRoundedSuperellipse(borderRadius: 20.0),
        settings: LiquidGlassSettings(
          thickness: 0.1,
          blur: 15,
          refractiveIndex: 1.0,
          glassColor: Colors.transparent,
          lightAngle: 45.0,
          lightIntensity: isDark ? 0.1 : 0.2,
          ambientStrength: 1.0,
          saturation: 1.0,
          chromaticAberration: 0.0,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.65),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              HugeIcon(
                icon: icon,
                size: 22,
                color: AppColors.primary,
                strokeWidth: 2.2,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
