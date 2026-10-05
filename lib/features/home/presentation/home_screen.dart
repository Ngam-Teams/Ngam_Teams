import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/teams_supabase_service.dart';
import '../../../core/services/app_update_service.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/glass_toast.dart';
import '../../../widgets/stat_card.dart';
import '../../dashboard/presentation/dashboard_shell.dart';

/// Ngam Teams — Elevated Staff & Crew Command Dashboard.
/// Designed for operational speed, high-end glassmorphism, and seamless daily workflow.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _service = TeamsSupabaseService.instance;

  // Attendance state
  bool _isCheckedIn = true;
  bool _isOnBreak = false;
  DateTime _checkInDateTime = DateTime.now().subtract(const Duration(hours: 4, minutes: 28));
  String _checkInTimeString = '09:00 AM';
  Timer? _liveClockTimer;
  Duration _durationWorked = const Duration(hours: 4, minutes: 28);

  // Profile state
  Map<String, dynamic>? _profile;

  // Interactive quick checklist on dashboard
  final List<Map<String, dynamic>> _quickTasks = [
    {'title': 'Hidupkan chiller & periksa suhu (-4°C)', 'done': true},
    {'title': 'Panaskan mesin espresso & lakukan backflush', 'done': true},
    {'title': 'Sediakan laci tunai float RM 200.00', 'done': true},
    {'title': 'Top-up ais batu di bar minuman sebelum rush', 'done': false},
    {'title': 'Semak bekalan cawan takeaway & beg', 'done': false},
  ];

  @override
  void initState() {
    super.initState();
    _startLiveTimer();
    _loadInitialData();
    _service.attendanceNotifier.addListener(_syncAttendanceFromNotifier);
    AppUpdateService.checkOnStartup(context);
  }

  void _syncAttendanceFromNotifier() {
    final todayAttendance = _service.attendanceNotifier.value;
    if (!mounted) return;
    setState(() {
      if (todayAttendance != null) {
        final inStr = todayAttendance['check_in_time'];
        final outStr = todayAttendance['check_out_time'];
        if (inStr != null && outStr == null) {
          _isCheckedIn = true;
          final parsed = DateTime.tryParse(inStr)?.toLocal();
          if (parsed != null) {
            _checkInDateTime = parsed;
            _checkInTimeString = DateFormat('hh:mm a').format(parsed);
          }
        } else if (outStr != null) {
          _isCheckedIn = false;
        }
      } else {
        _isCheckedIn = false;
      }
    });
  }

  @override
  void dispose() {
    _service.attendanceNotifier.removeListener(_syncAttendanceFromNotifier);
    _liveClockTimer?.cancel();
    super.dispose();
  }

  void _startLiveTimer() {
    _updateDuration();
    _liveClockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isCheckedIn && !_isOnBreak) {
        _updateDuration();
      }
    });
  }

  void _updateDuration() {
    final now = DateTime.now();
    setState(() {
      _durationWorked = now.difference(_checkInDateTime);
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}j ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
  }

  Future<void> _loadInitialData() async {
    try {
      final profile = await _service.fetchStaffProfile();
      final todayAttendance = await _service.fetchTodayAttendance();

      if (mounted) {
        setState(() {
          _profile = profile;

          if (todayAttendance != null) {
            final inStr = todayAttendance['check_in_time'];
            final outStr = todayAttendance['check_out_time'];
            if (inStr != null && outStr == null) {
              _isCheckedIn = true;
              final parsed = DateTime.tryParse(inStr)?.toLocal();
              if (parsed != null) {
                _checkInDateTime = parsed;
                _checkInTimeString = DateFormat('hh:mm a').format(parsed);
              }
            } else if (outStr != null) {
              _isCheckedIn = false;
            }
          }
        });
      }
    } catch (_) {
      // ignore
    }
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Selamat Pagi 🌅';
    if (hour >= 12 && hour < 17) return 'Selamat Tengah Hari ☀️';
    if (hour >= 17 && hour < 20) return 'Selamat Petang 🌇';
    return 'Selamat Malam 🌙';
  }

  Future<void> _handleClockIn() async {
    try {
      await _service.checkIn();
    } catch (_) {}
    setState(() {
      _isCheckedIn = true;
      _isOnBreak = false;
      _checkInDateTime = DateTime.now();
      _checkInTimeString = DateFormat('hh:mm a').format(_checkInDateTime);
    });
    if (mounted) {
      showGlassToast(
        context,
        'Berjaya Clock In! Selamat bertugas krew 👍',
        customIcon: Icons.check_circle_rounded,
        customColor: AppColors.success,
      );
    }
  }

  void _showClockOutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161626) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedLogout01,
                      color: AppColors.error,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tamat Syif Bekerja?',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anda telah bertugas selama ${_formatDuration(_durationWorked)} hari ini. Pastikan semua SOP penutupan dan serahan tunai telah disempurnakan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          try {
                            await _service.checkOut();
                          } catch (_) {}
                          setState(() {
                            _isCheckedIn = false;
                            _isOnBreak = false;
                          });
                          if (mounted) {
                            showGlassToast(
                              context,
                              'Tamat syif direkodkan. Terima kasih atas usaha anda! 👋',
                              customIcon: Icons.check_circle_outline_rounded,
                              customColor: AppColors.info,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Ya, Clock Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleBreak() {
    setState(() => _isOnBreak = !_isOnBreak);
    showGlassToast(
      context,
      _isOnBreak ? 'Mod Rehat Dimulakan ☕' : 'Rehat Tamat! Kembali Bertugas 🚀',
      customIcon: _isOnBreak ? Icons.coffee_rounded : Icons.play_arrow_rounded,
      customColor: _isOnBreak ? AppColors.warning : AppColors.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Top Staff Header ──────────────────────────────────────
          _buildStaffHeader(context),
          const SizedBox(height: 18),

          // ─── Hero Attendance & Duty Command Card ───────────────────
          _buildDutyCommandCard(context),
          const SizedBox(height: 24),

          // ─── Pusat Operasi Krew (Operations Hub) ───────────────────
          _buildOperationsHub(context),
          const SizedBox(height: 24),

          // ─── Pelanggan Seterusnya (Next Customer Spotlight) ─────────
          _buildNextCustomerSpotlight(context),
          const SizedBox(height: 24),

          // ─── SOP & Tugasan Hari Ini (Live Checklist Glance) ─────────
          _buildSopChecklistGlance(context),
          const SizedBox(height: 24),

          // ─── Rakan Krew Bertugas (Coworkers On Duty) ────────────────
          _buildCoworkersOnDuty(context),
          const SizedBox(height: 24),

          // ─── Ringkasan Prestasi Krew (4 Stat Cards) ─────────────────
          _buildPerformanceMetrics(context),
          const SizedBox(height: 24),

          // ─── Jadual Minggu Ini (Weekly Shift Strip) ─────────────────
          _buildWeeklyScheduleStrip(context),
          const SizedBox(height: 24),

          // ─── Notis & Pengumuman Krew ───────────────────────────────
          _buildAnnouncementsSection(context),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, size: 13, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Ngam Teams • Build Terkini v1.0.5',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 1. TOP STAFF HEADER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStaffHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final staffName = _profile?['name'] ?? _profile?['full_name'] ?? 'Ahmad Haziq';
    final role = _profile?['designation'] ?? _profile?['role'] ?? 'Ketua Syif & Servis Lead';
    final bizName = _profile?['businesses']?['business_name'] ?? 'Ngam Cafe & Studio';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          // Avatar with Active Indicator
          Stack(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    staffName.isNotEmpty ? staffName.substring(0, 1).toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -1,
                right: -1,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _isCheckedIn ? AppColors.success : AppColors.warning,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkBackground : Colors.white,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Greeting & Staff Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getTimeGreeting(),
                      style: TextStyle(
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: (_isCheckedIn ? AppColors.success : AppColors.textTertiary)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _isCheckedIn ? 'ON DUTY' : 'OFF DUTY',
                        style: TextStyle(
                          color: _isCheckedIn ? AppColors.success : (isDark ? Colors.white60 : Colors.black45),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: const Text(
                        'v1.0.5',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  staffName,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '📍 $bizName • $role',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Notification / Profile Jump
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 2. HERO ATTENDANCE & DUTY COMMAND CARD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildDutyCommandCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
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
                _isCheckedIn
                    ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.14)
                    : const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.18 : 0.10),
                isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isCheckedIn
                  ? AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.25)
                  : const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.35 : 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isCheckedIn ? AppColors.primary : const Color(0xFFF59E0B))
                    .withValues(alpha: isDark ? 0.15 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge (Top)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (_isCheckedIn
                          ? (_isOnBreak ? AppColors.warning : AppColors.success)
                          : const Color(0xFF94A3B8))
                      .withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (_isCheckedIn
                            ? (_isOnBreak ? AppColors.warning : AppColors.success)
                            : const Color(0xFF94A3B8))
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isCheckedIn
                            ? (_isOnBreak ? AppColors.warning : AppColors.success)
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        _isCheckedIn
                            ? (_isOnBreak ? 'SEDANG REHAT (ON BREAK)' : 'SEDANG BERTUGAS (ON DUTY)')
                            : 'BELUM CLOCK IN (OFF DUTY)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _isCheckedIn
                              ? (_isOnBreak ? AppColors.warning : AppColors.success)
                              : (isDark ? Colors.white70 : const Color(0xFF475569)),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Station Tag (Placed underneath per user instruction to eliminate overflow completely)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedStore01,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Stesen Kaunter & Bar • Ngam Cafe & Studio',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Duty Details Matrix
              if (_isCheckedIn) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Waktu Masuk',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : const Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _checkInTimeString,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Tempoh Bertugas',
                                style: TextStyle(
                                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(_durationWorked),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Action Buttons for On-Duty Staff
                Row(
                  children: [
                    // Break Toggle Button
                    Expanded(
                      child: InkWell(
                        onTap: _toggleBreak,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: (_isOnBreak ? AppColors.warning : AppColors.primary)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: (_isOnBreak ? AppColors.warning : AppColors.primary)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: _isOnBreak
                                    ? HugeIcons.strokeRoundedPlay
                                    : HugeIcons.strokeRoundedCoffee01,
                                color: _isOnBreak ? AppColors.warning : AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                _isOnBreak ? 'Sambung Kerja' : 'Ambil Rehat',
                                style: TextStyle(
                                  color: _isOnBreak ? AppColors.warning : AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Clock Out Button
                    Expanded(
                      child: InkWell(
                        onTap: _showClockOutDialog,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedLogout01,
                                color: AppColors.error,
                                size: 16,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Tamat Syif',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // When Off Duty
                Text(
                  'Syif anda hari ini dijadualkan pada 09:00 AM – 06:00 PM. Sila pastikan anda berada di lokasi cawangan sebelum punch in.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _handleClockIn,
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedClock01,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Punch In / Masuk Syif Sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 3. PUSAT OPERASI KREW (THE REVAMPED OPERATIONS HUB)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildOperationsHub(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedTasks = _quickTasks.where((t) => t['done'] == true).length;
    final totalTasks = _quickTasks.length;
    final taskPercent = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    return GlassPanel(
      title: 'Pusat Operasi Krew',
      icon: HugeIcons.strokeRoundedZap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Akses pantas servis, syif, SOP harian & kebajikan krew',
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

          // ─── 4 Primary Core Operational Cards (2x2 Grid) ────────────
          Row(
            children: [
              // 1. Servis Saya
              Expanded(
                child: _CoreOpCard(
                  title: 'Servis Saya',
                  subtitle: '3 Janji Temu',
                  badge: '1 Sedang Servis',
                  badgeColor: AppColors.primary,
                  icon: HugeIcons.strokeRoundedCalendar01,
                  accentColor: const Color(0xFF2563EB),
                  onTap: () => context.push('/my-services'),
                ),
              ),
              const SizedBox(width: 12),

              // 2. Jadual Syif
              Expanded(
                child: _CoreOpCard(
                  title: 'Jadual Syif',
                  subtitle: '09:00 – 18:00',
                  badge: '4 Krew Hari Ini',
                  badgeColor: const Color(0xFF06B6D4),
                  icon: HugeIcons.strokeRoundedTime02,
                  accentColor: const Color(0xFF06B6D4),
                  onTap: () => context.push('/shift-roster'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 3. SOP Tugasan
              Expanded(
                child: _CoreOpCard(
                  title: 'SOP Tugas',
                  subtitle: '$completedTasks / $totalTasks Selesai',
                  badge: '${(taskPercent * 100).toInt()}% Siap',
                  badgeColor: AppColors.success,
                  icon: HugeIcons.strokeRoundedTask01,
                  accentColor: const Color(0xFF10B981),
                  progress: taskPercent,
                  onTap: () => context.push('/task-checklist'),
                ),
              ),
              const SizedBox(width: 12),

              // 4. Gaji & Tip
              Expanded(
                child: _CoreOpCard(
                  title: 'Gaji & Tip',
                  subtitle: '+RM 82.50 Hari Ini',
                  badge: 'Tip Jar Aktif',
                  badgeColor: const Color(0xFFF59E0B),
                  icon: HugeIcons.strokeRoundedCoins01,
                  accentColor: const Color(0xFFF59E0B),
                  onTap: () => context.push('/earnings'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ─── 4 Secondary Quick Utilities (Balanced 4 Grid) ──────────
          Text(
            'UTILITI & SOKONGAN KREW',
            style: TextStyle(
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Klaim Belanja
              Expanded(
                child: _UtilityMiniCard(
                  icon: HugeIcons.strokeRoundedInvoice02,
                  label: 'Klaim',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => context.push('/claims'),
                ),
              ),
              const SizedBox(width: 8),

              // Kudos Krew
              Expanded(
                child: _UtilityMiniCard(
                  icon: HugeIcons.strokeRoundedChampion,
                  label: 'Kudos',
                  color: const Color(0xFFEC4899),
                  onTap: () => context.push('/kudos'),
                ),
              ),
              const SizedBox(width: 8),

              // SOS Insiden
              Expanded(
                child: _UtilityMiniCard(
                  icon: HugeIcons.strokeRoundedAlert02,
                  label: 'SOS Alert',
                  color: const Color(0xFFEF4444),
                  onTap: () => context.push('/incident-report'),
                ),
              ),
              const SizedBox(width: 8),

              // Mohon Cuti (Direct tab switch)
              Expanded(
                child: _UtilityMiniCard(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  label: 'Cuti',
                  color: const Color(0xFF6366F1),
                  onTap: () {
                    DashboardShell.activeTabNotifier.value = 3;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 4. NEXT CUSTOMER SPOTLIGHT (PELANGGAN SETERUSNYA)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildNextCustomerSpotlight(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassPanel(
      title: 'Pelanggan Seterusnya',
      icon: HugeIcons.strokeRoundedUserCheck01,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'AH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Amirul Hakim',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'VIP',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Premium Haircut & Beard Trim (45m)',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Slot: Hari ini, 2:30 PM (Lagi 15 Minit)',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price & Estimated Commission Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Harga: ',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'RM 50.00',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Komisen Anda: ',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      '+RM 17.50',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              // Contact Customer
              OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('tel:+60172345678');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCall02,
                  color: AppColors.primary,
                  size: 16,
                ),
                label: const Text(
                  'Hubungi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Open Queue
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/my-services'),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: const Text(
                    'Buka Antrean Servis',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 5. LIVE SOP CHECKLIST GLANCE
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSopChecklistGlance(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedCount = _quickTasks.where((t) => t['done'] == true).length;
    final totalCount = _quickTasks.length;

    return GlassPanel(
      title: 'Status SOP & Tugasan Hari Ini',
      icon: HugeIcons.strokeRoundedTask01,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SOP Pembukaan & Syif Petang',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completedCount / $totalCount Selesai',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: totalCount > 0 ? (completedCount / totalCount) : 0,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Checkbox Items
          ...List.generate(_quickTasks.length, (index) {
            final task = _quickTasks[index];
            final done = task['done'] as bool;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _quickTasks[index]['done'] = !done;
                  });
                  showGlassToast(
                    context,
                    !done ? 'Tugasan ditandakan selesai! 👍' : 'Tugasan dikembalikan ke senarai',
                    customIcon: !done ? Icons.check_circle_rounded : Icons.replay_rounded,
                    customColor: !done ? AppColors.success : AppColors.info,
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: done ? AppColors.success : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: done ? AppColors.success : (isDark ? Colors.white38 : Colors.grey.shade400),
                            width: 1.5,
                          ),
                        ),
                        child: done
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          task['title'] as String,
                          style: TextStyle(
                            color: done
                                ? (isDark ? Colors.white38 : Colors.grey.shade400)
                                : (isDark ? Colors.white : const Color(0xFF1E293B)),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            decoration: done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),

          // View Full Checklist Button
          Center(
            child: TextButton.icon(
              onPressed: () => context.push('/task-checklist'),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedTask01,
                color: AppColors.primary,
                size: 16,
              ),
              label: const Text(
                'Buka Senarai Lengkap SOP & Serahan Syif',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 6. COWORKERS ON DUTY WIDGET
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildCoworkersOnDuty(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final coworkers = [
      {'name': 'Ahmad Syafii', 'role': 'Ketua Juruwang', 'shift': '08:00 – 16:30', 'avatar': 'A', 'color': const Color(0xFF3B82F6)},
      {'name': 'Nurul Huda', 'role': 'Barista / Front', 'shift': '14:00 – 22:30', 'avatar': 'N', 'color': const Color(0xFF10B981)},
      {'name': 'Farid Kamil', 'role': 'Barber Stylist', 'shift': '14:00 – 22:30', 'avatar': 'F', 'color': const Color(0xFFF59E0B)},
      {'name': 'Chef Danial', 'role': 'Ketua Dapur', 'shift': '13:00 – 22:00', 'avatar': 'D', 'color': const Color(0xFF8B5CF6)},
    ];

    return GlassPanel(
      title: 'Rakan Bertugas Bersama',
      icon: HugeIcons.strokeRoundedUserGroup,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '4 Krew Aktif Bertugas Hari Ini',
                style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/shift-roster'),
                child: const Text(
                  'Lihat Roster',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Teammate list
          ...coworkers.map((c) {
            final col = c['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: col.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          c['avatar'] as String,
                          style: TextStyle(
                            color: col,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['name'] as String,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            c['role'] as String,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : const Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        c['shift'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 7. PERFORMANCE & QUICK STATS METRICS (4 CARDS)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildPerformanceMetrics(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Kadar Kehadiran',
                    value: '98%',
                    subtitle: 'Bulan ini',
                    icon: HugeIcons.strokeRoundedChartIncrease,
                    accentColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Jam Bertugas',
                    value: '${_durationWorked.inHours}.${(_durationWorked.inMinutes.remainder(60) / 6).round()} j',
                    subtitle: 'Hari ini',
                    icon: HugeIcons.strokeRoundedClock01,
                    accentColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Tip & Komisen',
                    value: 'RM 82.50',
                    subtitle: 'Hari ini',
                    icon: HugeIcons.strokeRoundedCoins01,
                    accentColor: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Baki Cuti',
                    value: '12 Hari',
                    subtitle: 'Tersedia',
                    icon: HugeIcons.strokeRoundedCalendar03,
                    accentColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 8. WEEKLY SCHEDULE STRIP (JADUAL MINGGU INI)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildWeeklyScheduleStrip(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final weekDays = [
      {'day': 'Isnin', 'date': '28 Sep', 'shift': '08:00 – 16:30', 'status': 'Hadir', 'color': AppColors.success, 'isToday': false},
      {'day': 'Selasa', 'date': '29 Sep', 'shift': '08:00 – 16:30', 'status': 'Hadir', 'color': AppColors.success, 'isToday': false},
      {'day': 'Rabu', 'date': '30 Sep', 'shift': '14:00 – 22:30', 'status': 'Hadir', 'color': AppColors.success, 'isToday': false},
      {'day': 'Khamis', 'date': '01 Okt', 'shift': '09:00 – 18:00', 'status': 'Hari Ini', 'color': AppColors.primary, 'isToday': true},
      {'day': 'Jumaat', 'date': '02 Okt', 'shift': '10:00 – 22:00', 'status': 'Rush Hour', 'color': const Color(0xFF06B6D4), 'isToday': false},
      {'day': 'Sabtu', 'date': '03 Okt', 'shift': '08:00 – 16:30', 'status': 'Pagi', 'color': const Color(0xFF8B5CF6), 'isToday': false},
      {'day': 'Ahad', 'date': '04 Okt', 'shift': '—', 'status': 'Cuti Rehat', 'color': AppColors.textTertiary, 'isToday': false},
    ];

    return GlassPanel(
      title: 'Jadual Syif Minggu Ini',
      icon: HugeIcons.strokeRoundedCalendar03,
      child: Column(
        children: weekDays.map((d) {
          final isToday = d['isToday'] as bool;
          final color = d['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.primary.withValues(alpha: isDark ? 0.16 : 0.08)
                  : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isToday
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
                width: isToday ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['day'] as String,
                        style: TextStyle(
                          color: isToday
                              ? AppColors.primary
                              : (isDark ? Colors.white : const Color(0xFF1E293B)),
                          fontSize: 13,
                          fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      Text(
                        d['date'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ],
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
                    d['status'] as String,
                    style: TextStyle(
                      color: isToday ? AppColors.primary : color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  d['shift'] as String,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 9. ANNOUNCEMENTS SECTION
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAnnouncementsSection(BuildContext context) {
    return GlassPanel(
      title: 'Notis & Pengumuman Syarikat',
      icon: HugeIcons.strokeRoundedMegaphone01,
      child: Column(
        children: [
          const _AnnouncementTile(
            title: 'Penutupan Cawangan Sempena Hari Raya',
            body: 'Operasi cawangan akan ditutup sepenuhnya pada 15 hingga 17 Oktober. Sila semak jadual serahan kunci.',
            date: 'Hari Ini',
            isPinned: true,
          ),
          const SizedBox(height: 12),
          const _AnnouncementTile(
            title: 'Taklimat SOP & Mesyuarat Bulanan Krew',
            body: 'Peringatan: Mesyuarat koordinasi krew akan diadakan pada Jumaat ini jam 3:00 petang di ruang rehat staf.',
            date: '2 hari lalu',
            isPinned: false,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () {
                DashboardShell.activeTabNotifier.value = 1;
              },
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMegaphone01,
                color: AppColors.primary,
                size: 16,
              ),
              label: const Text(
                'Lihat Semua Notis Penting',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════

/// Primary Core Operational Card (2x2 Grid Item)
class _CoreOpCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final dynamic icon;
  final Color accentColor;
  final double? progress;
  final VoidCallback onTap;

  const _CoreOpCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.icon,
    required this.accentColor,
    this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.transparent,
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade200,
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Icon Container
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(
                  icon: icon,
                  color: accentColor,
                  size: 20,
                  strokeWidth: 2.1,
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),

              // Subtitle
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              if (progress != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Straight continuous progress bar
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress! * 100).toInt()}%',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 10),
                // Badge (Placed underneath title & subtitle to avoid horizontal overflow completely)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary Utility Mini Card (4 Items in a Row)
class _UtilityMiniCard extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _UtilityMiniCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.transparent,
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.08 : 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.22 : 0.16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: icon,
                color: color,
                size: 20,
                strokeWidth: 2.1,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Announcement Preview Tile
class _AnnouncementTile extends StatelessWidget {
  final String title;
  final String body;
  final String date;
  final bool isPinned;

  const _AnnouncementTile({
    required this.title,
    required this.body,
    required this.date,
    required this.isPinned,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPinned
              ? AppColors.warning.withValues(alpha: 0.3)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isPinned) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedPin,
                        color: AppColors.warning,
                        size: 11,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'PINNED',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
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
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
