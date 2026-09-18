import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
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
  final List<_LeaveRequest> _requests = [
    _LeaveRequest(
      type: 'Annual Leave',
      from: 'Oct 15, 2026',
      to: 'Oct 17, 2026',
      days: 3,
      reason: 'Hari Raya family gathering',
      status: 'Approved',
      statusColor: AppColors.success,
    ),
    _LeaveRequest(
      type: 'Medical Leave',
      from: 'Sep 5, 2026',
      to: 'Sep 5, 2026',
      days: 1,
      reason: 'Doctor appointment',
      status: 'Approved',
      statusColor: AppColors.success,
    ),
    _LeaveRequest(
      type: 'Annual Leave',
      from: 'Nov 20, 2026',
      to: 'Nov 21, 2026',
      days: 2,
      reason: 'Personal errands',
      status: 'Pending',
      statusColor: AppColors.warning,
    ),
    _LeaveRequest(
      type: 'Emergency Leave',
      from: 'Aug 12, 2026',
      to: 'Aug 12, 2026',
      days: 1,
      reason: 'Family emergency',
      status: 'Approved',
      statusColor: AppColors.success,
    ),
  ];

  void _showApplyForm() {
    ModalSheet.show(
      context: context,
      initialChildSize: 0.75,
      builder: (context, scrollController) {
        String selectedType = 'Annual Leave';
        final reasonController = TextEditingController();

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return ListView(
              controller: scrollController,
              children: [
                Text(
                  'Apply for Leave',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in the details below',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // Leave Type
                Text(
                  'Leave Type',
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
                  children: [
                    'Annual Leave',
                    'Medical Leave',
                    'Emergency Leave',
                    'Unpaid Leave',
                  ].map((type) {
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
                          type,
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
                  'Date Range',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(label: 'From'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DatePickerField(label: 'To'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Reason
                Text(
                  'Reason',
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
                    hintText: 'Brief reason for your leave...',
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      showGlassToast(
                        this.context,
                        'Leave request submitted! ✅',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Submit Request',
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

    return SingleChildScrollView(
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
                'Apply for Leave',
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
            title: 'My Requests',
            icon: HugeIcons.strokeRoundedNote01,
            child: Column(
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
    );
  }

  Widget _buildLeaveBalance() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final items = [
          _BalanceItem(
            label: 'Annual Leave',
            used: 6,
            total: 18,
            color: AppColors.primary,
          ),
          _BalanceItem(
            label: 'Medical Leave',
            used: 2,
            total: 14,
            color: AppColors.info,
          ),
          _BalanceItem(
            label: 'Emergency Leave',
            used: 1,
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
    final remaining = item.total - item.used;
    final progress = item.used / item.total;

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
                '$remaining left',
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
                '${item.used} of ${item.total} used',
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
                '${request.from} — ${request.to} (${request.days} day${request.days > 1 ? 's' : ''})',
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
  final String type;
  final String from;
  final String to;
  final int days;
  final String reason;
  final String status;
  final Color statusColor;

  const _LeaveRequest({
    required this.type,
    required this.from,
    required this.to,
    required this.days,
    required this.reason,
    required this.status,
    required this.statusColor,
  });
}

// ─── Date Picker Field ───────────────────────────────────────
class _DatePickerField extends StatefulWidget {
  final String label;

  const _DatePickerField({required this.label});

  @override
  State<_DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<_DatePickerField> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
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
            Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : widget.label,
              style: TextStyle(
                color: _selectedDate != null
                    ? (isDark ? Colors.white : const Color(0xFF1E293B))
                    : (isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF94A3B8)),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
