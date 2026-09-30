import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_toast.dart';

// ============================================================
// MyServicesScreen — Staff Assigned Appointments & Service Queue
// ============================================================

enum ServiceStatus { pending, inProgress, completed, cancelled }

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Today', 'Upcoming', 'Completed'];

  late List<Map<String, dynamic>> _myServices;

  @override
  void initState() {
    super.initState();
    _myServices = [
      {
        'id': 'BK-1082',
        'customerName': 'Amirul Hakim',
        'phone': '+60 17-234 5678',
        'serviceName': 'Premium Haircut & Beard Trim',
        'timeSlot': 'Today, 2:30 PM (in 15m)',
        'duration': '45 mins',
        'price': 50.00,
        'commission': 17.50,
        'status': ServiceStatus.inProgress,
        'notes': 'Prefers sharp skin fade. Use beard oil after shave.',
        'dietary': 'Customer requested window seat barber chair.',
      },
      {
        'id': 'BK-1085',
        'customerName': 'Sarah Tan',
        'phone': '+60 12-889 1234',
        'serviceName': 'Organic Hair Treatment & Blowdry',
        'timeSlot': 'Today, 3:30 PM',
        'duration': '60 mins',
        'price': 85.00,
        'commission': 25.00,
        'status': ServiceStatus.pending,
        'notes': 'Sensitive scalp. Please use silicone-free organic shampoo.',
        'dietary': '',
      },
      {
        'id': 'BK-1080',
        'customerName': 'Zulhilmi Rahman',
        'phone': '+60 19-334 9988',
        'serviceName': 'Classic Gentleman Haircut',
        'timeSlot': 'Today, 11:00 AM',
        'duration': '30 mins',
        'price': 35.00,
        'commission': 12.00,
        'status': ServiceStatus.completed,
        'notes': 'Side parting. Customer gave RM 10 personal tip!',
        'dietary': '',
      },
      {
        'id': 'BK-1090',
        'customerName': 'Jessica Wong',
        'phone': '+60 16-555 4321',
        'serviceName': 'Full Hair Coloring & Scalp Spa',
        'timeSlot': 'Tomorrow, 10:30 AM',
        'duration': '90 mins',
        'price': 140.00,
        'commission': 42.00,
        'status': ServiceStatus.pending,
        'notes': 'Reference ash-grey shade saved in booking attachments.',
        'dietary': '',
      },
    ];
  }

  void _callCustomer(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) showGlassToast(context, 'Could not open phone dialer', isError: true);
    }
  }

  void _openWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) showGlassToast(context, 'Could not open WhatsApp', isError: true);
    }
  }

  void _updateStatus(Map<String, dynamic> item, ServiceStatus newStatus) {
    setState(() {
      item['status'] = newStatus;
    });
    final statusLabel = newStatus == ServiceStatus.inProgress
        ? 'Service Started (In Progress)'
        : newStatus == ServiceStatus.completed
            ? 'Service Completed! Commission credited.'
            : 'Status updated';
    showGlassToast(context, statusLabel);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredList = _myServices.where((s) {
      if (_selectedFilter == 0) return (s['timeSlot'] as String).contains('Today');
      if (_selectedFilter == 1) return (s['timeSlot'] as String).contains('Tomorrow');
      return s['status'] == ServiceStatus.completed;
    }).toList();

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
              'Tempahan & Servis Saya',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Pelanggan & giliran servis ditugaskan kepada anda',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: List.generate(_filters.length, (idx) {
                final isSel = idx == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      _filters[idx],
                      style: TextStyle(
                        color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? const Color(0xFF161624) : Colors.white,
                    side: BorderSide(color: isSel ? AppColors.primary : Colors.black12),
                    onSelected: (val) => setState(() => _selectedFilter = idx),
                  ),
                );
              }),
            ),
          ),

          // List of Services
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Text(
                      'Tiada servis dalam kategori ini.',
                      style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (ctx, idx) => _buildServiceCard(filteredList[idx], isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> item, bool isDark) {
    final status = item['status'] as ServiceStatus;
    final isInProgress = status == ServiceStatus.inProgress;
    final isCompleted = status == ServiceStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161624) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInProgress
              ? AppColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
          width: isInProgress ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isInProgress
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    (item['customerName'] as String).substring(0, 1),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['customerName'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        item['timeSlot'] as String,
                        style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                // Action icons
                IconButton(
                  icon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 20),
                  onPressed: () => _callCustomer(item['phone'] as String),
                ),
                IconButton(
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedMessage01, color: Color(0xFF25D366), size: 20),
                  onPressed: () => _openWhatsApp(item['phone'] as String),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),

          // Service Details & Commission
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['serviceName'] as String,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      'RM ${(item['price'] as double).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: isDark ? Colors.white54 : Colors.black54, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Tempoh: ${item['duration']}',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Komisen: +RM ${(item['commission'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                if ((item['notes'] as String).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['notes'] as String,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : const Color(0xFF334155),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bottom Action Status Button
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: isCompleted
                  ? Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Servis Telah Selesai',
                              style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInProgress ? const Color(0xFF10B981) : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (isInProgress) {
                          _updateStatus(item, ServiceStatus.completed);
                        } else {
                          _updateStatus(item, ServiceStatus.inProgress);
                        }
                      },
                      child: Text(
                        isInProgress ? 'Tandakan Selesai (Servis Tamat)' : 'Mula Servis Sekarang',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
