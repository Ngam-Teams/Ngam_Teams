import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_toast.dart';

// ============================================================
// ShiftRosterScreen — Weekly Schedule, Coworkers & Shift Swap
// ============================================================

class ShiftRosterScreen extends StatefulWidget {
  const ShiftRosterScreen({super.key});

  @override
  State<ShiftRosterScreen> createState() => _ShiftRosterScreenState();
}

class _ShiftRosterScreenState extends State<ShiftRosterScreen> {
  late List<Map<String, dynamic>> _weeklyRoster;
  late List<Map<String, dynamic>> _coworkersToday;
  late List<Map<String, dynamic>> _swapRequests;

  @override
  void initState() {
    super.initState();
    _weeklyRoster = [
      {'day': 'Isnin (Mon)', 'date': '28 Sep', 'shift': 'Shift Pagi', 'time': '08:00 AM – 04:30 PM', 'isOff': false, 'isToday': false},
      {'day': 'Selasa (Tue)', 'date': '29 Sep', 'shift': 'Shift Pagi', 'time': '08:00 AM – 04:30 PM', 'isOff': false, 'isToday': false},
      {'day': 'Rabu (Wed)', 'date': '30 Sep', 'shift': 'Shift Petang', 'time': '02:00 PM – 10:30 PM', 'isOff': false, 'isToday': true},
      {'day': 'Khamis (Thu)', 'date': '01 Oct', 'shift': 'Shift Petang', 'time': '02:00 PM – 10:30 PM', 'isOff': false, 'isToday': false},
      {'day': 'Jumaat (Fri)', 'date': '02 Oct', 'shift': 'Shift Penuh (Rush)', 'time': '10:00 AM – 10:00 PM', 'isOff': false, 'isToday': false},
      {'day': 'Sabtu (Sat)', 'date': '03 Oct', 'shift': 'Shift Pagi', 'time': '08:00 AM – 04:30 PM', 'isOff': false, 'isToday': false},
      {'day': 'Ahad (Sun)', 'date': '04 Oct', 'shift': 'Cuti Rehat (Off Day)', 'time': '—', 'isOff': true, 'isToday': false},
    ];

    _coworkersToday = [
      {'name': 'Ahmad Syafii', 'role': 'Ketua Juruwang', 'shift': '08:00 AM – 04:30 PM', 'avatar': 'A'},
      {'name': 'Nurul Huda', 'role': 'Barista / Front', 'shift': '02:00 PM – 10:30 PM', 'avatar': 'N'},
      {'name': 'Farid Kamil', 'role': 'Master Barber / Stylist', 'shift': '02:00 PM – 10:30 PM', 'avatar': 'F'},
      {'name': 'Chef Danial', 'role': 'Ketua Dapur', 'shift': '01:00 PM – 10:00 PM', 'avatar': 'D'},
    ];

    _swapRequests = [
      {
        'id': 'SW-101',
        'targetDate': 'Khamis, 01 Oct',
        'targetStaff': 'Nurul Huda',
        'status': 'Pending Approval',
        'reason': 'Kecemasan keluarga di kampung',
      },
    ];
  }

  void _openShiftSwapModal() {
    String selectedDate = 'Khamis, 01 Oct';
    String selectedCoworker = _coworkersToday.first['name'] as String;
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161624) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const HugeIcon(icon: HugeIcons.strokeRoundedRepeat, color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Permohonan Tukar Syif',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pilih rakan sekerja untuk menggantikan syif anda. Permohonan akan dihantar kepada Pengurus untuk kelulusan.',
                      style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Date dropdown
                    Text('Pilih Tarikh Syif Anda', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButton<String>(
                        value: selectedDate,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: isDark ? const Color(0xFF1A1A28) : Colors.white,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                        items: ['Khamis, 01 Oct', 'Jumaat, 02 Oct', 'Sabtu, 03 Oct']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) => setModalState(() => selectedDate = val!),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Coworker dropdown
                    Text('Pilih Rakan Sekerja Pengganti', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButton<String>(
                        value: selectedCoworker,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: isDark ? const Color(0xFF1A1A28) : Colors.white,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                        items: _coworkersToday
                            .map((c) => DropdownMenuItem(value: c['name'] as String, child: Text('${c['name']} (${c['role']})')))
                            .toList(),
                        onChanged: (val) => setModalState(() => selectedCoworker = val!),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reason input
                    Text('Sebab Permohonan', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonCtrl,
                      maxLines: 2,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Cth: Ada kecemasan keluarga / temu janji doktor',
                        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (reasonCtrl.text.trim().isEmpty) {
                            showGlassToast(context, 'Sila nyatakan sebab permohonan', isError: true);
                            return;
                          }
                          setState(() {
                            _swapRequests.insert(0, {
                              'id': 'SW-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              'targetDate': selectedDate,
                              'targetStaff': selectedCoworker,
                              'status': 'Pending Approval',
                              'reason': reasonCtrl.text.trim(),
                            });
                          });
                          Navigator.pop(ctx);
                          showGlassToast(context, 'Permohonan tukar syif berjaya dihantar kepada Pengurus!');
                        },
                        child: const Text('Hantar Permohonan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadual Syif & Rakan Bertugas',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Roster mingguan & rakan sekerja bertugas',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedRepeat, color: AppColors.primary, size: 22),
            tooltip: 'Tukar Syif',
            onPressed: _openShiftSwapModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // On Duty Today Banner
            Text(
              'Rakan Bertugas Hari Ini (${_coworkersToday.length} Krew)',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _coworkersToday.length,
                itemBuilder: (ctx, idx) {
                  final c = _coworkersToday[idx];
                  return Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161624) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                c['avatar'] as String,
                                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c['name'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c['role'] as String,
                          style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          c['shift'] as String,
                          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 10),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Weekly Roster List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Roster Syif Mingguan',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _openShiftSwapModal,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primary),
                  label: const Text('Tukar Syif', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._weeklyRoster.map((r) => _buildRosterCard(r, isDark)),
            const SizedBox(height: 24),

            // Shift Swap Requests History (if any)
            if (_swapRequests.isNotEmpty) ...[
              Text(
                'Status Permohonan Tukar Syif',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ..._swapRequests.map((sw) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161624) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_top_rounded, color: Color(0xFFF59E0B), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${sw['targetDate']} ➔ ${sw['targetStaff']}',
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              sw['reason'] as String,
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sw['status'] as String,
                          style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRosterCard(Map<String, dynamic> r, bool isDark) {
    final isOff = r['isOff'] as bool;
    final isToday = r['isToday'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
            : (isDark ? const Color(0xFF161624) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? AppColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06)),
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : (isDark ? Colors.white10 : Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              r['date'] as String,
              style: TextStyle(
                color: isToday ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      r['day'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                        child: const Text('HARI INI', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  r['shift'] as String,
                  style: TextStyle(
                    color: isOff ? const Color(0xFFEF4444) : (isDark ? const Color(0xFF10B981) : const Color(0xFF059669)),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            r['time'] as String,
            style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
