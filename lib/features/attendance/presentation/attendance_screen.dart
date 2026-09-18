import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
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
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
  }

  void _toggleCheckIn() {
    final now = DateFormat('hh:mm a').format(DateTime.now());
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

    if (_isCheckedIn) {
      showGlassToast(context, 'Checked in at $_checkInTime ✅');
    } else {
      showGlassToast(context, 'Checked out at $_checkOutTime 👋');
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
            title: 'Weekly History',
            icon: HugeIcons.strokeRoundedActivity01,
            child: Column(
              children: [
                _HistoryRow(
                  date: 'Mon, Sep 14',
                  checkIn: '09:02 AM',
                  checkOut: '06:00 PM',
                  status: 'Present',
                  statusColor: AppColors.success,
                ),
                Divider(
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
                  height: 24,
                ),
                _HistoryRow(
                  date: 'Tue, Sep 15',
                  checkIn: '08:55 AM',
                  checkOut: '06:15 PM',
                  status: 'Present',
                  statusColor: AppColors.success,
                ),
                Divider(
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
                  height: 24,
                ),
                _HistoryRow(
                  date: 'Wed, Sep 16',
                  checkIn: '09:32 AM',
                  checkOut: '06:05 PM',
                  status: 'Late',
                  statusColor: AppColors.warning,
                ),
                Divider(
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
                  height: 24,
                ),
                _HistoryRow(
                  date: 'Thu, Sep 17',
                  checkIn: _checkInTime ?? '—',
                  checkOut: _checkOutTime ?? '—',
                  status: _isCheckedIn ? 'Active' : (_checkInTime != null ? 'Done' : 'Pending'),
                  statusColor: _isCheckedIn
                      ? AppColors.primary
                      : (_checkInTime != null ? AppColors.success : AppColors.textTertiary),
                ),
                Divider(
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
                  height: 24,
                ),
                _HistoryRow(
                  date: 'Fri, Sep 18',
                  checkIn: '—',
                  checkOut: '—',
                  status: '—',
                  statusColor: AppColors.textTertiary,
                ),
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
