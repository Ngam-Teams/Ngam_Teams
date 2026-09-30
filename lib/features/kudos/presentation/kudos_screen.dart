import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_toast.dart';

// ============================================================
// KudosScreen — Peer Recognition, Shoutouts & Star of the Month
// ============================================================

class KudosScreen extends StatefulWidget {
  const KudosScreen({super.key});

  @override
  State<KudosScreen> createState() => _KudosScreenState();
}

class _KudosScreenState extends State<KudosScreen> {
  late List<Map<String, dynamic>> _kudosFeed;
  late List<Map<String, dynamic>> _leaderboard;

  @override
  void initState() {
    super.initState();
    _leaderboard = [
      {'name': 'Nurul Huda', 'role': 'Barista / Front', 'points': 48, 'avatar': 'N', 'rank': 1},
      {'name': 'Chef Danial', 'role': 'Ketua Dapur', 'points': 42, 'avatar': 'D', 'rank': 2},
      {'name': 'Ahmad Syafii', 'role': 'Juruwang', 'points': 35, 'avatar': 'A', 'rank': 3},
    ];

    _kudosFeed = [
      {
        'id': 'KD-1',
        'from': 'Farid Kamil',
        'to': 'Nurul Huda',
        'badge': 'Customer Whisperer ⭐',
        'message': 'Layan meja VIP dengan sangat profesional tadi, pelanggan bagi review 5-star di Ngam App!',
        'time': '1 jam lepas',
        'likes': 6,
      },
      {
        'id': 'KD-2',
        'from': 'Ahmad Syafii',
        'to': 'Chef Danial',
        'badge': 'Rush Hour Hero ⚡',
        'message': 'Siapkan 20 tiket order dalam masa 15 minit waktu lunch rush, memang padu chef!',
        'time': '3 jam lepas',
        'likes': 8,
      },
      {
        'id': 'KD-3',
        'from': 'Nurul Huda',
        'to': 'Ahmad Syafii',
        'badge': 'Positive Vibes ✨',
        'message': 'Selalu ceriakan suasana kaunter walaupun waktu sibuk hujung minggu!',
        'time': 'Semalam',
        'likes': 4,
      },
    ];
  }

  void _openSendKudosModal() {
    String selectedColleague = 'Nurul Huda';
    String selectedBadge = 'Rush Hour Hero ⚡';
    final msgCtrl = TextEditingController();

    final badges = [
      'Rush Hour Hero ⚡',
      'Customer Whisperer ⭐',
      'Chef Terpantas 🍳',
      'Positive Vibes ✨',
      'Penyelamat Shift 🛡️',
    ];

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
                        const HugeIcon(icon: HugeIcons.strokeRoundedChampion, color: Color(0xFFF59E0B), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Kirim Kudos & Penghargaan',
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
                      'Beri kata-kata semangat dan lencana pujian kepada rakan sepasukan anda.',
                      style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Recipient
                    Text('Pilih Rakan Sekerja', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButton<String>(
                        value: selectedColleague,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: isDark ? const Color(0xFF1A1A28) : Colors.white,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                        items: ['Nurul Huda', 'Chef Danial', 'Ahmad Syafii', 'Farid Kamil']
                            .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                            .toList(),
                        onChanged: (val) => setModalState(() => selectedColleague = val!),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Badge selector
                    Text('Pilih Lencana Penghargaan', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: badges.map((b) {
                        final isSel = selectedBadge == b;
                        return ChoiceChip(
                          label: Text(b, style: TextStyle(color: isSel ? Colors.black : (isDark ? Colors.white70 : Colors.black87), fontSize: 12, fontWeight: FontWeight.bold)),
                          selected: isSel,
                          selectedColor: const Color(0xFFF59E0B),
                          backgroundColor: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                          onSelected: (val) => setModalState(() => selectedBadge = b),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Message input
                    Text('Mesej Penghargaan', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: msgCtrl,
                      maxLines: 2,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Cth: Terima kasih tolong waktu meja tengah sesak!',
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
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (msgCtrl.text.trim().isEmpty) return;

                          setState(() {
                            _kudosFeed.insert(0, {
                              'id': 'KD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              'from': 'Saya',
                              'to': selectedColleague,
                              'badge': selectedBadge,
                              'message': msgCtrl.text.trim(),
                              'time': 'Sebentar tadi',
                              'likes': 1,
                            });
                          });

                          Navigator.pop(ctx);
                          showGlassToast(context, 'Kudos berjaya dikirim kepada $selectedColleague! 🎉');
                        },
                        child: const Text('Kirim Kudos Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              'Kudos & Rakan Sekerja',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Penghargaan rakan sepasukan & pekerja cemerlang',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: Color(0xFFEC4899), size: 22),
            tooltip: 'Kirim Kudos',
            onPressed: _openSendKudosModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Star of the Month Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF78350F), Color(0xFF451A03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: Colors.black, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pekerja Cemerlang Bulan Ini',
                          style: TextStyle(color: Color(0xFFFCD34D), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _leaderboard.first['name'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${_leaderboard.first['role']} • ${_leaderboard.first['points']} Mata Kudos',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Send Kudos Quick Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _openSendKudosModal,
                icon: const Icon(Icons.volunteer_activism_rounded, size: 18),
                label: const Text('Kirim Kudos Kepada Rakan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 28),

            // Live Kudos Feed
            Text(
              'Suapan Kudos Pasukan',
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._kudosFeed.map((kd) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          child: const Icon(Icons.favorite_rounded, color: Color(0xFFF59E0B), size: 14),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                              children: [
                                TextSpan(text: kd['from'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const TextSpan(text: ' ➔ '),
                                TextSpan(text: kd['to'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                        Text(kd['time'] as String, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        kd['badge'] as String,
                        style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kd['message'] as String,
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
