import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_translations.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/glass_toast.dart';
import '../../../widgets/modal_sheet.dart';
import '../../../widgets/ngam_nav_back_button.dart';

// ============================================================
// Ngam Teams — Staff Profile Screen
// Dedicated screen displaying employee details, department,
// designation, reporting line, and verification clearance.
// Theme-adaptive (Dark/Light) and localized (EN/MS).
// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Top Navigation Bar ───────────────────────────
                  Row(
                    children: [
                      if (canPop) ...[
                        const NgamNavBackButton(),
                        const SizedBox(width: 14),
                      ],
                      Text(
                        context.tr('profile.title'),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: context.tr('profile.request_update'),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedUserEdit01,
                            color: isDark ? Colors.white : Colors.black87,
                            size: 18,
                          ),
                        ),
                        onPressed: () => _showRequestUpdateSheet(context, isDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── Profile Hero Header ──────────────────────────
                  _buildProfileHero(isDark),
                  const SizedBox(height: 24),

                  // ─── Staff Information ────────────────────────────
                  GlassPanel(
                    title: context.tr('profile.info_panel'),
                    icon: HugeIcons.strokeRoundedUserAccount,
                    child: Column(
                      children: [
                        _InfoRow(
                          isDark: isDark,
                          icon: HugeIcons.strokeRoundedMail01,
                          label: context.tr('profile.email'),
                          value: 'ahmad.haziq@ngam.my',
                        ),
                        _buildRowDivider(isDark),
                        _InfoRow(
                          isDark: isDark,
                          icon: HugeIcons.strokeRoundedSmartPhone01,
                          label: context.tr('profile.phone'),
                          value: '+60 12-345 6789',
                        ),
                        _buildRowDivider(isDark),
                        _InfoRow(
                          isDark: isDark,
                          icon: HugeIcons.strokeRoundedTag01,
                          label: context.tr('profile.staff_id'),
                          value: 'NGM-2024-0042',
                        ),
                        _buildRowDivider(isDark),
                        _InfoRow(
                          isDark: isDark,
                          icon: HugeIcons.strokeRoundedBuilding03,
                          label: context.tr('profile.department'),
                          value: 'Engineering & Tech',
                        ),
                        _buildRowDivider(isDark),
                        _InfoRow(
                          isDark: isDark,
                          icon: HugeIcons.strokeRoundedUserStar01,
                          label: context.tr('profile.designation'),
                          value: 'Senior Flutter Developer',
                        ),
                        _buildRowDivider(isDark),
                        _InfoRow(
                          isDark: isDark,
                          icon: HugeIcons.strokeRoundedCalendar03,
                          label: context.tr('profile.joined'),
                          value: 'March 15, 2024 (2 yrs)',
                        ),
                        _buildRowDivider(isDark),
                        _InfoRow(
                          isDark: isDark,
                          icon: HugeIcons.strokeRoundedUserGroup,
                          label: context.tr('profile.reporting_line'),
                          value: 'Siti Aminah (VP Engineering)',
                        ),
                        _buildRowDivider(isDark),
                        _InfoRow(
                          isDark: isDark,
                          icon: HugeIcons.strokeRoundedLocation01,
                          label: context.tr('profile.office_base'),
                          value: 'HQ — Bangsar South, KL',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Employment & Access Clearance ───────────────
                  GlassPanel(
                    title: context.tr('profile.security_clearance'),
                    icon: HugeIcons.strokeRoundedShield01,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildClearanceRow(
                          isDark,
                          context.tr('profile.door_pass'),
                          'HQ Level 12 & Server Room',
                          HugeIcons.strokeRoundedKey01,
                          context.tr('profile.granted'),
                        ),
                        _buildRowDivider(isDark),
                        _buildClearanceRow(
                          isDark,
                          context.tr('profile.git_access'),
                          'Write access to core codebase',
                          HugeIcons.strokeRoundedCode,
                          context.tr('profile.granted'),
                        ),
                        _buildRowDivider(isDark),
                        _buildClearanceRow(
                          isDark,
                          context.tr('profile.cloud_access'),
                          'Developer Tier Admin',
                          HugeIcons.strokeRoundedCloudUpload,
                          context.tr('profile.granted'),
                        ),
                        _buildRowDivider(isDark),
                        _buildClearanceRow(
                          isDark,
                          context.tr('profile.fuel_card'),
                          'Assigned • Standard Tier',
                          HugeIcons.strokeRoundedCreditCard,
                          context.tr('profile.granted'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ─── Request Update Action Button ─────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _showRequestUpdateSheet(context, isDark),
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedNote01,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      label: Text(
                        context.tr('profile.request_update'),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHero(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                AppColors.secondary.withValues(alpha: isDark ? 0.1 : 0.05),
              ],
            ),
            color: isDark ? null : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.glassBorder
                  : Colors.black.withValues(alpha: 0.07),
              width: 1.2,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
              Text(
                'Ahmad Haziq',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Senior Developer • Engineering',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              // Status badges row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        const Icon(Icons.circle, color: AppColors.success, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('profile.active'),
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      context.tr('profile.full_time'),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearanceRow(
    bool isDark,
    String title,
    String subtitle,
    dynamic icon,
    String grantedText,
  ) {
    return Row(
      children: [
        HugeIcon(
          icon: icon,
          color: AppColors.primary,
          size: 20,
          strokeWidth: 2.0,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, size: 12, color: AppColors.success),
              const SizedBox(width: 4),
              Text(
                grantedText,
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRowDivider(bool isDark) => Divider(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        height: 24,
      );

  void _showRequestUpdateSheet(BuildContext context, bool isDark) {
    final noteController = TextEditingController();

    ModalSheet.show(
      context: context,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (ctx, scrollController) {
        return ListView(
          controller: scrollController,
          children: [
            Text(
              context.tr('profile.request_update'),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('profile.update_hint'),
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: noteController,
              maxLines: 4,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Please update my phone number to +60 19-876 5432',
                hintStyle: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey.shade400,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.glassBorder : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.glassBorder : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  showGlassToast(
                    context,
                    'Correction request submitted to HR',
                  );
                },
                child: Text(
                  context.tr('profile.submit_request'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Info Row Widget ─────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final bool isDark;
  final dynamic icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.isDark,
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
          color: isDark ? Colors.white70 : Colors.black54,
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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : const Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
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
