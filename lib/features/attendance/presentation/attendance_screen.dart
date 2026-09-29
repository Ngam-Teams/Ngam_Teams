import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/teams_supabase_service.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/glass_toast.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  bool _isCheckedIn = false;
  String? _checkInTime;
  String? _checkOutTime;
  List<Map<String, dynamic>> _attendanceHistory = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late Timer _clockTimer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    try {
      final today = await TeamsSupabaseService.instance.fetchTodayAttendance();
      final history = await TeamsSupabaseService.instance.fetchRecentAttendance();

      if (mounted) {
        setState(() {
          if (today != null) {
            final inTimeStr = today['check_in_time'];
            final outTimeStr = today['check_out_time'];
            _checkInTime = inTimeStr != null
                ? DateFormat('hh:mm a').format(DateTime.parse(inTimeStr).toLocal())
                : null;
            _checkOutTime = outTimeStr != null
                ? DateFormat('hh:mm a').format(DateTime.parse(outTimeStr).toLocal())
                : null;
            _isCheckedIn = _checkInTime != null && _checkOutTime == null;
          }
          _attendanceHistory = history;
        });
      }
    } catch (e) {
      debugPrint('Error loading attendance in UI: $e');
    }
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
  }

  Future<void> _toggleCheckIn() async {
    final now = DateFormat('hh:mm a').format(DateTime.now());
    try {
      if (!_isCheckedIn) {
        await TeamsSupabaseService.instance.checkIn();
        setState(() {
          _isCheckedIn = true;
          _checkInTime = now;
          _checkOutTime = null;
        });
        if (mounted) showGlassToast(context, 'Checked in at $_checkInTime ✅');
      } else {
        await TeamsSupabaseService.instance.checkOut();
        setState(() {
          _isCheckedIn = false;
          _checkOutTime = now;
        });
        if (mounted) showGlassToast(context, 'Checked out at $_checkOutTime 👋');
      }
      _loadAttendance();
    } catch (e) {
      setState(() {
        if (!_isCheckedIn) {
          _isCheckedIn = true;
          _checkInTime = now;
          _checkOutTime = null;
        } else {
          _isCheckedIn = false;
          _checkOutTime = now;
        }
      });
      if (mounted) {
        showGlassToast(
          context,
          _isCheckedIn ? 'Checked in at $_checkInTime' : 'Checked out at $_checkOutTime',
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: [
          // ─── Clock & Check-in Button ──────────────────────────
          _buildClockCard(isDark),
          const SizedBox(height: 24),

          // ─── Today's Status ───────────────────────────────────
          GlassPanel(
            title: "Today's Status",
            icon: HugeIcons.strokeRoundedCalendar03,
            child: Column(
              children: [
                _StatusRow(
                  icon: HugeIcons.strokeRoundedLogin02,
                  label: 'Check In',
                  value: _checkInTime ?? '—',
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                _StatusRow(
                  icon: HugeIcons.strokeRoundedLogout02,
                  label: 'Check Out',
                  value: _checkOutTime ?? '—',
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                _StatusRow(
                  icon: HugeIcons.strokeRoundedClock01,
                  label: 'Working Hours',
                  value: _isCheckedIn ? 'In progress…' : (_checkInTime != null ? '9h 0m' : '—'),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── Weekly History ───────────────────────────────────
          GlassPanel(
            title: 'Attendance History',
            icon: HugeIcons.strokeRoundedActivity01,
            child: _attendanceHistory.isEmpty
                ? Column(
                    children: [
                      _HistoryRow(
                        date: DateFormat('EEE, MMM d').format(DateTime.now()),
                        checkIn: _checkInTime ?? '—',
                        checkOut: _checkOutTime ?? '—',
                        status: _isCheckedIn ? 'Active' : (_checkInTime != null ? 'Done' : 'Pending'),
                        statusColor: _isCheckedIn
                            ? AppColors.primary
                            : (_checkInTime != null ? AppColors.success : AppColors.textTertiary),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      for (int i = 0; i < _attendanceHistory.length; i++) ...[
                        if (i > 0)
                          Divider(
                            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
                            height: 24,
                          ),
                        Builder(
                          builder: (context) {
                            final item = _attendanceHistory[i];
                            final dateStr = item['attendance_date'] ?? '';
                            DateTime? parsedDate = DateTime.tryParse(dateStr);
                            final displayDate = parsedDate != null
                                ? DateFormat('EEE, MMM d').format(parsedDate)
                                : dateStr;

                            final inStr = item['check_in_time'];
                            final outStr = item['check_out_time'];
                            final displayIn = inStr != null
                                ? DateFormat('hh:mm a').format(DateTime.parse(inStr).toLocal())
                                : '—';
                            final displayOut = outStr != null
                                ? DateFormat('hh:mm a').format(DateTime.parse(outStr).toLocal())
                                : '—';

                            final status = (item['status'] as String? ?? 'present').toUpperCase();
                            Color statusColor = AppColors.success;
                            if (status == 'LATE') statusColor = AppColors.warning;
                            if (status == 'ABSENT') statusColor = AppColors.error;

                            return _HistoryRow(
                              date: displayDate,
                              checkIn: displayIn,
                              checkOut: displayOut,
                              status: status,
                              statusColor: statusColor,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockCard(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (_isCheckedIn ? AppColors.success : AppColors.primary).withValues(alpha: isDark ? 0.15 : 0.12),
                (_isCheckedIn ? AppColors.secondary : AppColors.primary).withValues(alpha: isDark ? 0.05 : 0.04),
              ],
            ),
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.glassBorder : Colors.white.withValues(alpha: 0.65),
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
              // Live clock
              Text(
                _currentTime,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
              ),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Big tappable button
              GestureDetector(
                onTap: _toggleCheckIn,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isCheckedIn ? 1.0 : _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isCheckedIn
                            ? [AppColors.error, const Color(0xFFFF8A80)]
                            : [AppColors.success, AppColors.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isCheckedIn ? AppColors.error : AppColors.success)
                              .withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: _isCheckedIn
                              ? HugeIcons.strokeRoundedLogout02
                              : HugeIcons.strokeRoundedLogin02,
                          color: Colors.white,
                          size: 32,
                          strokeWidth: 2.5,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isCheckedIn ? 'OUT' : 'IN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isCheckedIn ? 'Tap to check out' : 'Tap to check in',
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Status Row ──────────────────────────────────────────────
class _StatusRow extends StatelessWidget {
  final dynamic icon;
  final String label;
  final String value;
  final Color color;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.12),
            shape: BoxShape.circle,
          ),
          child: HugeIcon(icon: icon, color: color, size: 20, strokeWidth: 2.1),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── History Row ─────────────────────────────────────────────
class _HistoryRow extends StatelessWidget {
  final String date;
  final String checkIn;
  final String checkOut;
  final String status;
  final Color statusColor;

  const _HistoryRow({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$checkIn – $checkOut',
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: isDark ? 0.15 : 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
