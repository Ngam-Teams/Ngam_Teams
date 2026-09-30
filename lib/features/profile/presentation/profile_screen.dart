import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/localization/app_translations.dart';
import '../../../core/services/teams_supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/glass_toast.dart';
import '../../../widgets/ngam_nav_back_button.dart';

// ============================================================
// Ngam Teams — Staff Profile Screen
// Dedicated screen displaying employee details, department,
// designation, reporting line, and verification clearance.
// Staff members can edit, save, and update their personal info.
// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = TeamsSupabaseService.instance;

  bool _loading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final data = await _service.fetchStaffProfile();
    if (mounted) {
      setState(() {
        _profile = data;
        _loading = false;
      });
    }
  }

  Future<void> _saveStaffProfile(Map<String, dynamic> updates) async {
    try {
      await _service.updateStaffProfile(updates);
      if (mounted) {
        showGlassToast(
          context,
          'Your profile was updated successfully!',
          customIcon: Icons.check_circle_rounded,
          customColor: AppColors.success,
        );
        _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        showGlassToast(
          context,
          'Failed to update profile: $e',
          isError: true,
        );
      }
    }
  }

  void _showEditProfileSheet(BuildContext context, bool isDark) {
    final currentName = _profile?['name'] ?? _service.currentUser?.email?.split('@').first ?? '';
    final currentPhone = _profile?['phone'] ?? '';
    final currentDesignation = _profile?['designation'] ?? 'Staff';
    final currentOffice = _profile?['office_base'] ?? '';

    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone);
    final designationCtrl = TextEditingController(text: currentDesignation);
    final officeCtrl = TextEditingController(text: currentOffice);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF161622).withValues(alpha: 0.96)
                          : Colors.white.withValues(alpha: 0.96),
                      border: Border(
                        top: BorderSide(
                          color: isDark ? AppColors.glassBorder : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Edit My Profile',
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                          Text(
                            'Update your contact details and job info for your team roster.',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : const Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Name field
                          _buildSheetField(
                            isDark: isDark,
                            label: 'Full Name',
                            controller: nameCtrl,
                            hint: 'Your full name',
                          ),
                          const SizedBox(height: 14),

                          // Phone field
                          _buildSheetField(
                            isDark: isDark,
                            label: 'Phone Number',
                            controller: phoneCtrl,
                            hint: '+60 12-345 6789',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),

                          // Designation field
                          _buildSheetField(
                            isDark: isDark,
                            label: 'Job Title / Designation',
                            controller: designationCtrl,
                            hint: 'e.g. Senior Barista / Cashier',
                          ),
                          const SizedBox(height: 14),

                          // Office base field
                          _buildSheetField(
                            isDark: isDark,
                            label: 'Branch / Work Location',
                            controller: officeCtrl,
                            hint: 'e.g. Pavilion Branch / Main Store',
                          ),
                          const SizedBox(height: 24),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: saving
                                  ? null
                                  : () async {
                                      setSheetState(() => saving = true);
                                      final updates = {
                                        'name': nameCtrl.text.trim(),
                                        'phone': phoneCtrl.text.trim(),
                                        'designation': designationCtrl.text.trim(),
                                        'office_base': officeCtrl.text.trim(),
                                      };
                                      Navigator.pop(ctx);
                                      await _saveStaffProfile(updates);
                                    },
                              child: saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Save & Update Profile',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEnterStaffCodeSheet(BuildContext context, bool isDark) {
    final codeCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool linking = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF161622).withValues(alpha: 0.96)
                          : Colors.white.withValues(alpha: 0.96),
                      border: Border(
                        top: BorderSide(
                          color: isDark ? AppColors.glassBorder : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Connect Workplace',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter the Staff Code provided by your employer (e.g. STF-001) to link your account to your workplace.',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : const Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: codeCtrl,
                          textCapitalization: TextCapitalization.characters,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. STF-001',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white30 : Colors.black26,
                              letterSpacing: 1,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF1F5F9),
                            prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.glassBorder : Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: linking
                                ? null
                                : () async {
                                    final code = codeCtrl.text.trim();
                                    if (code.isEmpty) return;
                                    setSheetState(() => linking = true);
                                    final res = await _service.linkStaffWithCode(code);
                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      if (res['success'] == true) {
                                        showGlassToast(
                                          context,
                                          res['message'] ?? 'Successfully linked!',
                                          customIcon: Icons.check_circle_rounded,
                                          customColor: AppColors.success,
                                        );
                                        await _loadProfile();
                                      } else {
                                        showGlassToast(
                                          context,
                                          res['message'] ?? 'Failed to link code',
                                          isError: true,
                                        );
                                      }
                                    }
                                  },
                            child: linking
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Link My Workplace',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUnlinkedWarningCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.link_off_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workplace Not Linked Yet',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Connect with your employer\'s Staff Code to view your shifts, orders & roster.',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _showEnterStaffCodeSheet(context, isDark),
              icon: const Icon(Icons.badge_outlined, size: 18),
              label: const Text(
                'Enter Staff Code to Connect',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedWorkplaceCard(BuildContext context, bool isDark, String businessName, String staffCode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Linked as $staffCode • Active Staff Member',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showEnterStaffCodeSheet(context, isDark),
            child: const Text('Change', style: TextStyle(fontSize: 12, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetField({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF334155),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.black26,
            ),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.glassBorder : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.glassBorder : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isLinked = _profile != null && _profile?['business_id'] != null;
    final String staffName = _profile?['name'] ?? _service.currentUser?.email?.split('@').first ?? 'Staff Member';
    final String staffEmail = _profile?['email'] ?? _service.currentUser?.email ?? 'staff@ngam.my';
    final String staffPhone = _profile?['phone'] ?? 'Not set';
    final String staffCode = isLinked ? (_profile?['staff_code'] ?? 'STF-001') : 'Pending';
    final String designation = _profile?['designation'] ?? 'Staff';
    final String department = _profile?['department'] ?? 'General';
    final String joinedDate = _profile?['joined_date'] ?? 'Recently';
    final String officeBase = _profile?['office_base'] ?? 'Store Floor';
    final String businessName = isLinked
        ? (_profile?['businesses']?['business_name'] ?? 'Your Store')
        : 'Not Connected to Workplace';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                              // Edit Profile Button
                              IconButton(
                                tooltip: 'Edit Profile',
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
                                onPressed: () => _showEditProfileSheet(context, isDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ─── Profile Hero Header ──────────────────────────
                          _buildProfileHero(isDark, staffName, designation, businessName, staffCode, isLinked),
                          const SizedBox(height: 20),

                          // ─── Workplace Connection Banner ──────────────────
                          if (!isLinked) ...[
                            _buildUnlinkedWarningCard(context, isDark),
                            const SizedBox(height: 20),
                          ] else ...[
                            _buildLinkedWorkplaceCard(context, isDark, businessName, staffCode),
                            const SizedBox(height: 20),
                          ],

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
                                  value: staffEmail,
                                ),
                                _buildRowDivider(isDark),
                                _InfoRow(
                                  isDark: isDark,
                                  icon: HugeIcons.strokeRoundedSmartPhone01,
                                  label: context.tr('profile.phone'),
                                  value: staffPhone,
                                ),
                                _buildRowDivider(isDark),
                                _InfoRow(
                                  isDark: isDark,
                                  icon: HugeIcons.strokeRoundedTag01,
                                  label: context.tr('profile.staff_id'),
                                  value: staffCode,
                                ),
                                _buildRowDivider(isDark),
                                _InfoRow(
                                  isDark: isDark,
                                  icon: HugeIcons.strokeRoundedBuilding03,
                                  label: context.tr('profile.department'),
                                  value: department,
                                ),
                                _buildRowDivider(isDark),
                                _InfoRow(
                                  isDark: isDark,
                                  icon: HugeIcons.strokeRoundedStore01,
                                  label: 'Assigned Business',
                                  value: businessName,
                                ),
                                _buildRowDivider(isDark),
                                _InfoRow(
                                  isDark: isDark,
                                  icon: HugeIcons.strokeRoundedUserStar01,
                                  label: context.tr('profile.designation'),
                                  value: designation,
                                ),
                                _buildRowDivider(isDark),
                                _InfoRow(
                                  isDark: isDark,
                                  icon: HugeIcons.strokeRoundedCalendar03,
                                  label: context.tr('profile.joined'),
                                  value: joinedDate,
                                ),
                                _buildRowDivider(isDark),
                                _InfoRow(
                                  isDark: isDark,
                                  icon: HugeIcons.strokeRoundedLocation01,
                                  label: context.tr('profile.office_base'),
                                  value: officeBase,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ─── Edit Profile Action Button ─────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => _showEditProfileSheet(context, isDark),
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedUserEdit01,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                'Update My Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
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
      ),
    );
  }

  Widget _buildProfileHero(
    bool isDark,
    String name,
    String designation,
    String businessName,
    String staffCode,
    bool isLinked,
  ) {
    final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
          ),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials.isNotEmpty ? initials : 'ST',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                designation,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLinked
                      ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05))
                      : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: isLinked ? HugeIcons.strokeRoundedStore01 : HugeIcons.strokeRoundedAlertCircle,
                      color: isLinked ? AppColors.primary : const Color(0xFFF59E0B),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      businessName,
                      style: TextStyle(
                        color: isLinked
                            ? (isDark ? Colors.white70 : Colors.black87)
                            : const Color(0xFFF59E0B),
                        fontSize: 12,
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

  Widget _buildRowDivider(bool isDark) {
    return Divider(
      height: 20,
      thickness: 1,
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.05),
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
          size: 18,
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
                  fontSize: 14,
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
