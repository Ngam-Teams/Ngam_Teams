import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_toast.dart';

// ============================================================
// TaskChecklistScreen — Daily SOP Checklist & Shift Handover
// ============================================================

class TaskChecklistScreen extends StatefulWidget {
  const TaskChecklistScreen({super.key});

  @override
  State<TaskChecklistScreen> createState() => _TaskChecklistScreenState();
}

class _TaskChecklistScreenState extends State<TaskChecklistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late List<Map<String, dynamic>> _openingTasks;
  late List<Map<String, dynamic>> _midTasks;
  late List<Map<String, dynamic>> _closingTasks;
  late List<Map<String, dynamic>> _handoverNotes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _openingTasks = [
      {'title': 'Hidupkan chiller & periksa suhu peti sejuk (-4°C)', 'done': true},
      {'title': 'Panaskan mesin espresso & lakukan backflush pembersihan', 'done': true},
      {'title': 'Sediakan laci tunai dengan duit float RM 200.00', 'done': true},
      {'title': 'Semak stok susu segar, sirap gula & biji kopi', 'done': false},
      {'title': 'Buka grill utama & pasang lampu signboard kedai', 'done': true},
    ];

    _midTasks = [
      {'title': 'Periksa kebersihan tandas pelanggan jam 2:00 PM', 'done': true},
      {'title': 'Top-up ais batu di bar minuman sebelum lunch rush', 'done': false},
      {'title': 'Buang hampas kopi & lap steam wand', 'done': false},
      {'title': 'Semak bekalan cawan takeaway & beg plastik', 'done': false},
    ];

    _closingTasks = [
      {'title': 'Buang semua sisa makanan dapur & basuh tong sampah', 'done': false},
      {'title': 'Mop lantai ruang makan & bahagian dapur', 'done': false},
      {'title': 'Tutup semua injap tong gas memasak (PENTING)', 'done': false},
      {'title': 'Kira duit jualan laci tunai & cetak Z-Report POS', 'done': false},
      {'title': 'Kunci pintu belakang, tutup aircond & aktifkan penggera', 'done': false},
    ];

    _handoverNotes = [
      {
        'id': 'HN-01',
        'author': 'Ahmad (Syif Pagi)',
        'time': '02:15 PM',
        'note': 'Ais batu tinggal 1 beg sahaja di freezer. Lori ais dah janji hantar jam 4:30 petang nanti.',
        'tag': 'PENTING',
        'color': const Color(0xFFF59E0B),
      },
      {
        'id': 'HN-02',
        'author': 'Chef Danial',
        'time': '01:30 PM',
        'note': 'Rendang daging periuk kedua siap jam 2 petang. Kuah laksa masih cukup untuk dinner.',
        'tag': 'DAPUR',
        'color': const Color(0xFF10B981),
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _calculateProgress(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) return 0;
    final done = tasks.where((t) => t['done'] as bool).length;
    return done / tasks.length;
  }

  void _openAddHandoverNoteModal() {
    final noteCtrl = TextEditingController();
    String tag = 'OPERASI';

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
                        const HugeIcon(icon: HugeIcons.strokeRoundedNote01, color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Catat Nota Serahan Syif',
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
                      'Tinggalkan pesanan stok, peralatan atau peringatan untuk krew syif seterusnya.',
                      style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Tag selector
                    Row(
                      children: ['PENTING', 'DAPUR', 'BAR / FRONT', 'OPERASI'].map((t) {
                        final isSel = tag == t;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(t, style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            backgroundColor: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                            onSelected: (val) => setModalState(() => tag = t),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: noteCtrl,
                      maxLines: 3,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Cth: Tong gas baru dah tukar jam 1 petang. Kunci stor ada di laci juruwang.',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (noteCtrl.text.trim().isEmpty) return;

                          setState(() {
                            _handoverNotes.insert(0, {
                              'id': 'HN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              'author': 'Saya (Syif Semasa)',
                              'time': 'Sebentar tadi',
                              'note': noteCtrl.text.trim(),
                              'tag': tag,
                              'color': tag == 'PENTING' ? const Color(0xFFEF4444) : AppColors.primary,
                            });
                          });

                          Navigator.pop(ctx);
                          showGlassToast(context, 'Nota serahan syif berjaya disimpan dalam log!');
                        },
                        child: const Text('Simpan Nota Serahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              'Tugas & Serahan Syif',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'SOP pembukaan, operasi, penutupan & log serahan',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedNoteAdd, color: AppColors.primary, size: 22),
            tooltip: 'Tambah Nota Serahan',
            onPressed: _openAddHandoverNoteModal,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: isDark ? Colors.white : AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          tabs: const [
            Tab(text: 'SOP Pembukaan'),
            Tab(text: 'Semasa Syif'),
            Tab(text: 'SOP Penutupan'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(_openingTasks, 'SOP Pembukaan Kedai (Pagi)', isDark),
                _buildTaskList(_midTasks, 'Tugasan Semasa Operasi (Mid-Shift)', isDark),
                _buildTaskList(_closingTasks, 'SOP Penutupan Kedai (Closing)', isDark),
              ],
            ),
          ),
          _buildHandoverSection(isDark),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks, String sectionTitle, bool isDark) {
    final progress = _calculateProgress(tasks);
    final percentage = (progress * 100).toInt();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161624) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(sectionTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('$percentage%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(percentage == 100 ? const Color(0xFF10B981) : AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Task Items
          ...tasks.map((t) {
            final isDone = t['done'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161624) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDone ? const Color(0xFF10B981).withValues(alpha: 0.3) : (isDark ? Colors.white10 : Colors.black12)),
              ),
              child: CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                activeColor: const Color(0xFF10B981),
                checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                value: isDone,
                title: Text(
                  t['title'] as String,
                  style: TextStyle(
                    color: isDone ? (isDark ? Colors.white38 : Colors.black38) : (isDark ? Colors.white : Colors.black87),
                    fontWeight: isDone ? FontWeight.normal : FontWeight.w600,
                    fontSize: 13,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                onChanged: (val) {
                  setState(() => t['done'] = val ?? false);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHandoverSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12121E) : const Color(0xFFF1F5F9),
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_edu_rounded, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Log Serahan Syif (Handover Notes)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              TextButton(
                onPressed: _openAddHandoverNoteModal,
                child: const Text('+ Catat', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _handoverNotes.length,
              itemBuilder: (ctx, idx) {
                final n = _handoverNotes[idx];
                return Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A28) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (n['color'] as Color).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(n['author'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: (n['color'] as Color).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(n['tag'] as String, style: TextStyle(color: n['color'] as Color, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          n['note'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
