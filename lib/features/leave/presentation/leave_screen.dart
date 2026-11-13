import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../core/services/teams_supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/glass_toast.dart';
import '../../../widgets/modal_sheet.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  List<_LeaveRequest> _requests = [];
  bool _isLoading = true;

  static const Map<String, String> _leaveTypeLabels = {
    'Annual Leave': 'Cuti Tahunan',
    'Medical Leave': 'Cuti Sakit (MC)',
    'Emergency Leave': 'Cuti Kecemasan',
    'Unpaid Leave': 'Cuti Tanpa Gaji',
  };

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    setState(() => _isLoading = true);
    try {
      final rows = await TeamsSupabaseService.instance.fetchLeaves();
      if (!mounted) return;
      setState(() {
        _requests = rows.map((row) {
          final rawType = (row['leave_type'] as String?) ?? 'Annual Leave';
          final startRaw = (row['start_date'] as String?) ?? '';
          final endRaw = (row['end_date'] as String?) ?? '';
          final startDt = DateTime.tryParse(startRaw);
          final endDt = DateTime.tryParse(endRaw);
          final fromStr = startDt != null ? DateFormat('dd MMM yyyy').format(startDt) : startRaw;
          final toStr = endDt != null ? DateFormat('dd MMM yyyy').format(endDt) : endRaw;
          final daysCount = (row['days_count'] as num?)?.toInt() ??
              ((startDt != null && endDt != null) ? (endDt.difference(startDt).inDays + 1).clamp(1, 365) : 1);
          final rawStatus = (row['status'] as String?) ?? 'Pending';
          final statusNorm = rawStatus.toLowerCase();

          Color statusColor = AppColors.warning;
          String statusLabel = 'Menunggu';
          if (statusNorm == 'approved') {
            statusColor = AppColors.success;
            statusLabel = 'Diluluskan';
          } else if (statusNorm == 'rejected') {
            statusColor = AppColors.error;
            statusLabel = 'Ditolak';
          }

          return _LeaveRequest(
            rawType: rawType,
            type: _leaveTypeLabels[rawType] ?? rawType,
            from: fromStr,
            to: toStr,
            days: daysCount,
            reason: (row['reason'] as String?) ?? '-',
            rawStatus: rawStatus,
            status: statusLabel,
            statusColor: statusColor,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _usedDaysFor(String rawType) {
    return _requests
        .where((r) => r.rawType == rawType && r.rawStatus.toLowerCase() == 'approved')
        .fold(0, (sum, r) => sum + r.days);
  }

  void _showApplyForm() {
    ModalSheet.show(
      context: context,
      initialChildSize: 0.78,
      builder: (sheetCtx, scrollController) {
        String selectedType = 'Annual Leave';
        DateTime? startDate = DateTime.now();
        DateTime? endDate = DateTime.now();
        bool submitting = false;
        final reasonController = TextEditingController();

        final isDark = Theme.of(sheetCtx).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return ListView(
              controller: scrollController,
              children: [
                Text(
                  'Mohon Cuti Baharu',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lengkapkan butiran permohonan cuti anda di bawah',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Leave Type
                Text(
                  'Jenis Cuti',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF334155),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _leaveTypeLabels.entries.map((entry) {
                    final type = entry.key;
                    final label = entry.value;
                    final isSelected = selectedType == type;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12)
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : const Color(0xFF475569)),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Date Range
                Text(
                  'Tempoh Tarikh',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF334155),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(
                        label: 'Tarikh Mula',
                        initialDate: startDate,
                        onDateSelected: (d) {
                          setSheetState(() {
                            startDate = d;
                            if (endDate == null || endDate!.isBefore(d)) {
                              endDate = d;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DatePickerField(
                        label: 'Tarikh Tamat',
                        initialDate: endDate,
                        onDateSelected: (d) {
                          setSheetState(() {
                            endDate = d;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Reason
                Text(
                  'Sebab Permohonan',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF334155),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Nyatakan sebab permohonan cuti anda...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.3) : const Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: submitting
                        ? null
                        : () async {
                            final reason = reasonController.text.trim();
                            if (reason.isEmpty) {
                              showGlassToast(this.context, 'Sila nyatakan sebab permohonan cuti.', isError: true);
                              return;
                            }
                            final sDate = startDate ?? DateTime.now();
                            final eDate = (endDate != null && !endDate!.isBefore(sDate)) ? endDate! : sDate;

                            setSheetState(() => submitting = true);
                            try {
                              final res = await TeamsSupabaseService.instance.submitLeaveRequest(
                                leaveType: selectedType,
                                startDate: sDate,
                                endDate: eDate,
                                reason: reason,
                              );
                              if (!mounted) return;
                              Navigator.of(sheetCtx).pop();
                              if (res != null) {
                                showGlassToast(
                                  this.context,
                                  'Permohonan cuti berjaya dihantar! ✅',
                                );
                                _loadLeaves();
                              } else {
                                showGlassToast(
                                  this.context,
                                  'Sila log masuk dan pautkan Kod Staf terlebih dahulu.',
                                  isError: true,
                                );
                              }
                            } catch (e) {
                              setSheetState(() => submitting = false);
                              if (mounted) {
                                showGlassToast(
                                  this.context,
                                  'Gagal menghantar permohonan cuti. Pastikan akaun telah dipautkan ke kedai.',
                                  isError: true,
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Hantar Permohonan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadLeaves,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Leave Balance ────────────────────────────────────
            _buildLeaveBalance(),
            const SizedBox(height: 24),

            // ─── Apply Button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _showApplyForm,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedAdd01,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Mohon Cuti Baharu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Leave History ────────────────────────────────────
            GlassPanel(
              title: 'Senarai Permohonan Saya',
              icon: HugeIcons.strokeRoundedNote01,
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  : _requests.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'Tiada permohonan cuti direkodkan.',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: _requests.asMap().entries.map((entry) {
                            final index = entry.key;
                            final r = entry.value;
                            return Column(
                              children: [
                                if (index > 0)
                                  Divider(
                                    color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07),
                                    height: 24,
                                  ),
                                _LeaveRequestRow(request: r),
                              ],
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveBalance() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final items = [
          _BalanceItem(
            label: 'Cuti Tahunan',
            used: _usedDaysFor('Annual Leave'),
            total: 18,
            color: AppColors.primary,
          ),
          _BalanceItem(
            label: 'Cuti Sakit (MC)',
            used: _usedDaysFor('Medical Leave'),
            total: 14,
            color: AppColors.info,
          ),
          _BalanceItem(
            label: 'Cuti Kecemasan',
            used: _usedDaysFor('Emergency Leave'),
            total: 5,
            color: AppColors.warning,
          ),
        ];

        if (constraints.maxWidth >= 600) {
          return Row(
            children: items
                .map((item) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: items.indexOf(item) == 0 ? 0 : 12,
                        ),
                        child: _buildBalanceCard(item),
                      ),
                    ))
                .toList(),
          );
        }
        return SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 180,
                child: _buildBalanceCard(items[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(_BalanceItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = (item.total - item.used).clamp(0, item.total);
    final progress = (item.used / item.total).clamp(0.0, 1.0);

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Baki $remaining',
                style: TextStyle(
                  color: item.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Text(
            '$remaining',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation(item.color),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${item.used} daripada ${item.total} hari digunakan',
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem {
  final String label;
  final int used;
  final int total;
  final Color color;

  const _BalanceItem({
    required this.label,
    required this.used,
    required this.total,
    required this.color,
  });
}

// ─── Leave Request Row ───────────────────────────────────────
class _LeaveRequestRow extends StatelessWidget {
  final _LeaveRequest request;

  const _LeaveRequestRow({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: request.statusColor.withValues(alpha: isDark ? 0.15 : 0.12),
            shape: BoxShape.circle,
          ),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedCalendar03,
            color: request.statusColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.type,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${request.from} — ${request.to} (${request.days} hari)',
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                request.reason,
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: request.statusColor.withValues(alpha: isDark ? 0.12 : 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: request.statusColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            request.status,
            style: TextStyle(
              color: request.statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaveRequest {
  final String rawType;
  final String type;
  final String from;
  final String to;
  final int days;
  final String reason;
  final String rawStatus;
  final String status;
  final Color statusColor;

  const _LeaveRequest({
    required this.rawType,
    required this.type,
    required this.from,
    required this.to,
    required this.days,
    required this.reason,
    required this.rawStatus,
    required this.status,
    required this.statusColor,
  });
}

// ─── Date Picker Field ───────────────────────────────────────
class _DatePickerField extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateSelected;

  const _DatePickerField({
    required this.label,
    this.initialDate,
    this.onDateSelected,
  });

  @override
  State<_DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<_DatePickerField> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 7)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? const ColorScheme.dark(
                        primary: AppColors.primary,
                        surface: AppColors.surface,
                        onSurface: Colors.white,
                      )
                    : const ColorScheme.light(
                        primary: AppColors.primary,
                        surface: Colors.white,
                        onSurface: Color(0xFF1E293B),
                      ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => _selectedDate = date);
          widget.onDateSelected?.call(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCalendar03,
              color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF64748B),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _selectedDate != null
                      ? (isDark ? Colors.white : const Color(0xFF1E293B))
                      : (isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF94A3B8)),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
