import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_toast.dart';

// ============================================================
// IncidentReportScreen — Emergency SOS & Store Incident Logs
// ============================================================

enum IncidentSeverity { low, medium, critical }

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  late List<Map<String, dynamic>> _sosHotlines;
  late List<Map<String, dynamic>> _incidentReports;

  @override
  void initState() {
    super.initState();
    _sosHotlines = [
      {'name': 'Pengurus Kedai (Manager)', 'phone': '+60 17-234 5678', 'role': 'Pengurus', 'color': AppColors.primary},
      {'name': 'Pemilik Kedai (Boss)', 'phone': '+60 12-889 1234', 'role': 'Owner', 'color': const Color(0xFF10B981)},
      {'name': 'Balai Polis Melaka Tengah', 'phone': '999', 'role': 'Polis', 'color': const Color(0xFF3B82F6)},
      {'name': 'Bomba & Penyelamat', 'phone': '994', 'role': 'Bomba', 'color': const Color(0xFFEF4444)},
      {'name': 'Hospital Melaka (Kecemasan)', 'phone': '+60 6-282 2344', 'role': 'Hospital 24 Jam', 'color': const Color(0xFFEC4899)},
    ];

    _incidentReports = [
      {
        'id': 'INC-201',
        'type': 'Kerosakan Peralatan Dapur',
        'severity': IncidentSeverity.medium,
        'location': 'Dapur Memasak',
        'time': 'Hari Ini, 11:30 AM',
        'reporter': 'Chef Danial',
        'status': 'Dalam Tindakan',
        'desc': 'Blender heavy-duty mengeluarkan bau hangit bila dikisar lama. Telah ditutup suis utama.',
      },
      {
        'id': 'INC-198',
        'type': 'Pinggan Pecah & Tumpahan',
        'severity': IncidentSeverity.low,
        'location': 'Ruang Makan Meja 7',
        'time': 'Semalam, 08:15 PM',
        'reporter': 'Nurul Huda',
        'status': 'Selesai',
        'desc': 'Pelanggan terlanggar cawan kaca. Krew telah bersihkan serpihan kaca dan mop lantai serta-merta.',
      },
    ];
  }

  void _callNumber(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) showGlassToast(context, 'Could not open phone dialer', isError: true);
    }
  }

  void _openSubmitIncidentModal() {
    String selectedType = 'Kerosakan Peralatan Dapur';
    IncidentSeverity selectedSeverity = IncidentSeverity.medium;
    final locationCtrl = TextEditingController(text: 'Bahagian Dapur');
    final descCtrl = TextEditingController();
    bool photoAttached = false;

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
                        const HugeIcon(icon: HugeIcons.strokeRoundedAlert02, color: Color(0xFFEF4444), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Lapor Insiden / Kerosakan Kedai',
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
                      'Laporan segera kepada Boss & Pengurus untuk tindakan keselamatan atau pembaikan.',
                      style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Incident Type
                    Text('Jenis Insiden', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButton<String>(
                        value: selectedType,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: isDark ? const Color(0xFF1A1A28) : Colors.white,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                        items: [
                          'Kerosakan Peralatan Dapur',
                          'Kemalangan / Kecederaan Dapur (Luka/Melecur)',
                          'Pinggan Pecah & Tumpahan Minuman',
                          'Masalah Elektrik / Chiller / Peti Sejuk',
                          'Kekecohan / Pertikaian Pelanggan',
                        ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) => setModalState(() => selectedType = val!),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Severity Selector
                    Text('Tahap Kecemasan (Severity)', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => selectedSeverity = IncidentSeverity.low),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedSeverity == IncidentSeverity.low ? const Color(0xFF10B981).withValues(alpha: 0.2) : (isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: selectedSeverity == IncidentSeverity.low ? const Color(0xFF10B981) : Colors.transparent),
                              ),
                              child: const Center(
                                child: Text('Rendah', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => selectedSeverity = IncidentSeverity.medium),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedSeverity == IncidentSeverity.medium ? const Color(0xFFF59E0B).withValues(alpha: 0.2) : (isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: selectedSeverity == IncidentSeverity.medium ? const Color(0xFFF59E0B) : Colors.transparent),
                              ),
                              child: const Center(
                                child: Text('Sederhana', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => selectedSeverity = IncidentSeverity.critical),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedSeverity == IncidentSeverity.critical ? const Color(0xFFEF4444).withValues(alpha: 0.2) : (isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: selectedSeverity == IncidentSeverity.critical ? const Color(0xFFEF4444) : Colors.transparent),
                              ),
                              child: const Center(
                                child: Text('Kritikal (SOS)', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Location
                    Text('Lokasi Dalam Kedai', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationCtrl,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description
                    Text('Keterangan Insiden', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Terangkan apa yang berlaku dan tindakan segera yang telah diambil...',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Attach photo
                    GestureDetector(
                      onTap: () {
                        setModalState(() => photoAttached = true);
                        showGlassToast(context, 'Foto bukti insiden dilampirkan!');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: photoAttached ? const Color(0xFF10B981).withValues(alpha: 0.15) : (isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: photoAttached ? const Color(0xFF10B981) : Colors.white24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(photoAttached ? Icons.check_circle_rounded : Icons.camera_alt_rounded,
                                color: photoAttached ? const Color(0xFF10B981) : AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              photoAttached ? 'Foto Dilampirkan (EVIDENCE_01.jpg)' : 'Ambil Foto Bukti Kerosakan',
                              style: TextStyle(color: photoAttached ? const Color(0xFF10B981) : AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          if (descCtrl.text.trim().isEmpty) {
                            showGlassToast(context, 'Sila masukkan keterangan insiden', isError: true);
                            return;
                          }

                          setState(() {
                            _incidentReports.insert(0, {
                              'id': 'INC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              'type': selectedType,
                              'severity': selectedSeverity,
                              'location': locationCtrl.text.trim(),
                              'time': 'Hari Ini, sebentar tadi',
                              'reporter': 'Saya (Krew Bertugas)',
                              'status': 'Menunggu Tindakan',
                              'desc': descCtrl.text.trim(),
                            });
                          });

                          Navigator.pop(ctx);
                          showGlassToast(context, 'Laporan insiden telah dihantar ke telefon Pengurus & Boss!');
                        },
                        child: const Text('Hantar Laporan Insiden', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
              'Bantuan Kecemasan SOS & Insiden',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Panggilan pantas kecemasan & laporan kerosakan kedai',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SOS Emergency Hotline Grid
            Text(
              'Talian Pantas Kecemasan (SOS 24 Jam)',
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._sosHotlines.map((h) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161624) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (h['color'] as Color).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (h['color'] as Color).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.phone_in_talk_rounded, color: h['color'] as Color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('${h['role']} • ${h['phone']}', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: h['color'] as Color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _callNumber(h['phone'] as String),
                      child: const Text('Panggil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 28),

            // Report Incident Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _openSubmitIncidentModal,
                icon: const Icon(Icons.warning_amber_rounded, size: 20),
                label: const Text('Lapor Kerosakan / Kemalangan Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 28),

            // Incident History
            Text(
              'Laporan Insiden Terkini',
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._incidentReports.map((inc) {
              final sev = inc['severity'] as IncidentSeverity;
              final sevColor = sev == IncidentSeverity.critical
                  ? const Color(0xFFEF4444)
                  : sev == IncidentSeverity.medium
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF10B981);

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(inc['type'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: sevColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sev == IncidentSeverity.critical
                                ? 'KRITIKAL'
                                : sev == IncidentSeverity.medium
                                    ? 'SEDERHANA'
                                    : 'RENDAH',
                            style: TextStyle(color: sevColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${inc['location']} • ${inc['time']} • Oleh: ${inc['reporter']}',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      inc['desc'] as String,
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.sync_rounded, size: 14, color: Color(0xFF10B981)),
                        const SizedBox(width: 6),
                        Text(
                          'Status: ${inc['status']}',
                          style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
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
