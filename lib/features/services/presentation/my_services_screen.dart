import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_toast.dart';
import '../../../core/services/teams_supabase_service.dart';

// ============================================================
// MyServicesScreen — Staff Smart Queue (Walk-In) & Appointments
// ============================================================

enum ServiceStatus { pending, inProgress, completed, cancelled }

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  // 0: Walk-In Queue (Live), 1: Tempahan Berjadual
  int _activeTopTab = 0;

  // Appointment filters
  int _selectedFilter = 0;
  final List<String> _filters = ['Hari Ini', 'Akan Datang', 'Selesai'];

  // Queue filters
  int _queueFilter = 0;
  final List<String> _queueFilters = ['Semua', 'Menunggu', 'Sedang Servis', 'Selesai'];

  bool _isLoadingQueue = false;
  Timer? _queueRefreshTimer;

  // Live Queue Tickets
  List<Map<String, dynamic>> _queueTickets = [];

  // Appointments
  late List<Map<String, dynamic>> _myServices;

  @override
  void initState() {
    super.initState();
    _initDemoServices();
    _loadQueueTickets();

    // Auto-refresh queue every 15 seconds
    _queueRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted && _activeTopTab == 0) {
        _loadQueueTickets(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _queueRefreshTimer?.cancel();
    super.dispose();
  }

  void _initDemoServices() {
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

  Future<void> _loadQueueTickets({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoadingQueue = true);
    }
    try {
      final tickets = await TeamsSupabaseService.instance.fetchQueueTickets();
      if (mounted) {
        if (tickets.isNotEmpty) {
          setState(() {
            _queueTickets = tickets;
            _isLoadingQueue = false;
          });
        } else {
          // Fallback realistic demo tickets if backend has none yet
          if (_queueTickets.isEmpty) {
            _queueTickets = [
              {
                'id': 'tk-001',
                'ticket_number': 'A001',
                'customer_name': 'Hafiz Firdaus',
                'phone_number': '+60 12-345 6789',
                'service_name': 'Classic Fade & Beard Trim',
                'station_or_chair': 'Kerusi 1',
                'assigned_staff_name': 'Saya (Barber)',
                'status': 'serving',
                'estimated_wait_minutes': 0,
                'created_at': DateTime.now().subtract(const Duration(minutes: 25)).toIso8601String(),
                'serving_at': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
              },
              {
                'id': 'tk-002',
                'ticket_number': 'A002',
                'customer_name': 'Khairul Anwar',
                'phone_number': '+60 13-987 6543',
                'service_name': 'Haircut & Head Wash',
                'station_or_chair': 'Kerusi 2',
                'assigned_staff_name': null,
                'status': 'calling',
                'estimated_wait_minutes': 5,
                'created_at': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
                'called_at': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
              },
              {
                'id': 'tk-003',
                'ticket_number': 'A003',
                'customer_name': 'Danish Aiman',
                'phone_number': '+60 17-654 3210',
                'service_name': 'Pompadour Styling',
                'station_or_chair': null,
                'assigned_staff_name': null,
                'status': 'waiting',
                'estimated_wait_minutes': 15,
                'created_at': DateTime.now().subtract(const Duration(minutes: 8)).toIso8601String(),
              },
              {
                'id': 'tk-004',
                'ticket_number': 'A004',
                'customer_name': 'Muhammad Syukri',
                'phone_number': '+60 18-223 3445',
                'service_name': 'Kids Haircut',
                'station_or_chair': null,
                'assigned_staff_name': null,
                'status': 'waiting',
                'estimated_wait_minutes': 25,
                'created_at': DateTime.now().subtract(const Duration(minutes: 3)).toIso8601String(),
              },
              {
                'id': 'tk-000',
                'ticket_number': 'A000',
                'customer_name': 'Azman Shah',
                'phone_number': '+60 11-123 4567',
                'service_name': 'Signature Buzzcut',
                'station_or_chair': 'Kerusi 1',
                'assigned_staff_name': 'Saya (Barber)',
                'status': 'completed',
                'estimated_wait_minutes': 0,
                'created_at': DateTime.now().subtract(const Duration(hours: 1, minutes: 10)).toIso8601String(),
                'completed_at': DateTime.now().subtract(const Duration(minutes: 35)).toIso8601String(),
              },
            ];
          }
          setState(() => _isLoadingQueue = false);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingQueue = false);
    }
  }

  void _callCustomer(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) showGlassToast(context, 'Tidak dapat membuka aplikasi panggilan', isError: true);
    }
  }

  void _openWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) showGlassToast(context, 'Tidak dapat membuka WhatsApp', isError: true);
    }
  }

  // Action: Call ticket to counter/chair
  Future<void> _handleCallTicket(Map<String, dynamic> ticket) async {
    final ticketId = ticket['id'] as String;
    final ticketNum = ticket['ticket_number'] ?? 'Giliran';
    final station = ticket['station_or_chair'] ?? 'Kerusi 1';

    setState(() {
      ticket['status'] = 'calling';
      ticket['station_or_chair'] = station;
      ticket['called_at'] = DateTime.now().toIso8601String();
    });

    await TeamsSupabaseService.instance.callQueueTicket(
      ticketId: ticketId,
      staffName: 'Barber Bertugas',
      station: station,
    );

    if (mounted) {
      showGlassToast(context, 'Nombor $ticketNum dipanggil ke $station');
    }
  }

  // Action: Pick station & start service
  void _promptStartServing(Map<String, dynamic> ticket) {
    final chairs = ['Kerusi 1', 'Kerusi 2', 'Kerusi 3', 'Kerusi 4', 'Bilik VIP'];
    String chosenChair = ticket['station_or_chair'] ?? 'Kerusi 1';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161624),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ticket['ticket_number'] ?? 'A000',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Mula Servis Pelanggan',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih stesen / kerusi untuk pelanggan ${ticket['customer_name'] ?? 'Walk-In'}:',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: chairs.map((ch) {
                      final isSel = ch == chosenChair;
                      return ChoiceChip(
                        label: Text(ch),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        backgroundColor: const Color(0xFF222238),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => chosenChair = ch);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        final parentCtx = this.context;
                        Navigator.pop(ctx);
                        final ticketId = ticket['id'] as String;
                        setState(() {
                          ticket['status'] = 'serving';
                          ticket['station_or_chair'] = chosenChair;
                          ticket['assigned_staff_name'] = 'Saya';
                          ticket['serving_at'] = DateTime.now().toIso8601String();
                        });

                        await TeamsSupabaseService.instance.startServingQueueTicket(
                          ticketId: ticketId,
                          staffName: 'Saya (Barber)',
                          station: chosenChair,
                        );

                        if (!parentCtx.mounted) return;
                        showGlassToast(parentCtx, 'Servis dimulakan di $chosenChair!');
                      },
                      child: const Text('Sahkan & Mula Servis', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Action: Mark completed
  Future<void> _handleCompleteTicket(Map<String, dynamic> ticket) async {
    final ticketId = ticket['id'] as String;
    final ticketNum = ticket['ticket_number'] ?? 'Giliran';

    setState(() {
      ticket['status'] = 'completed';
      ticket['completed_at'] = DateTime.now().toIso8601String();
    });

    await TeamsSupabaseService.instance.completeQueueTicket(ticketId: ticketId);

    if (mounted) {
      showGlassToast(context, 'Giliran $ticketNum telah selesai! Tahniah.');
    }
  }

  // Action: Cancel ticket
  Future<void> _handleCancelTicket(Map<String, dynamic> ticket) async {
    final ticketId = ticket['id'] as String;
    final ticketNum = ticket['ticket_number'] ?? 'Giliran';

    setState(() {
      ticket['status'] = 'cancelled';
    });

    await TeamsSupabaseService.instance.cancelQueueTicket(ticketId: ticketId);

    if (mounted) {
      showGlassToast(context, 'Giliran $ticketNum telah dibatalkan');
    }
  }

  void _updateStatus(Map<String, dynamic> item, ServiceStatus newStatus) {
    setState(() {
      item['status'] = newStatus;
    });
    final statusLabel = newStatus == ServiceStatus.inProgress
        ? 'Servis Bermula (Sedang Dijalankan)'
        : newStatus == ServiceStatus.completed
            ? 'Servis Selesai! Komisen dikreditkan.'
            : 'Status dikemaskini';
    showGlassToast(context, statusLabel);
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
              'Servis & Giliran Krew',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Urus walk-in queue langsung & janji temu',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          if (_activeTopTab == 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              onPressed: () => _loadQueueTickets(),
              tooltip: 'Segarkan Giliran',
            ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Switcher: Walk-In Queue vs Appointments
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161624) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTopTab = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _activeTopTab == 0 ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              size: 16,
                              color: _activeTopTab == 0 ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Giliran Walk-In',
                              style: TextStyle(
                                color: _activeTopTab == 0 ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (_queueTickets.where((t) => t['status'] == 'waiting' || t['status'] == 'calling').isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _activeTopTab == 0 ? Colors.black26 : AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_queueTickets.where((t) => t['status'] == 'waiting' || t['status'] == 'calling').length}',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTopTab = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _activeTopTab == 1 ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 15,
                              color: _activeTopTab == 1 ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Janji Temu',
                              style: TextStyle(
                                color: _activeTopTab == 1 ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content based on selected tab
          Expanded(
            child: _activeTopTab == 0
                ? _buildWalkInQueueTab(isDark)
                : _buildAppointmentsTab(isDark),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 1. WALK-IN QUEUE TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildWalkInQueueTab(bool isDark) {
    final filteredQueue = _queueTickets.where((t) {
      final status = t['status'] as String? ?? 'waiting';
      if (_queueFilter == 1) return status == 'waiting' || status == 'calling';
      if (_queueFilter == 2) return status == 'serving';
      if (_queueFilter == 3) return status == 'completed' || status == 'cancelled';
      return true;
    }).toList();

    return Column(
      children: [
        // Filter Chips for Queue
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_queueFilters.length, (idx) {
                final isSel = idx == _queueFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      _queueFilters[idx],
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
                    onSelected: (val) => setState(() => _queueFilter = idx),
                  ),
                );
              }),
            ),
          ),
        ),

        // Live Queue List
        Expanded(
          child: _isLoadingQueue
              ? const Center(child: CircularProgressIndicator())
              : filteredQueue.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 48, color: isDark ? Colors.white24 : Colors.black26),
                          const SizedBox(height: 12),
                          Text(
                            'Tiada giliran pelanggan dalam kategori ini.',
                            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadQueueTickets(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredQueue.length,
                        itemBuilder: (ctx, idx) => _buildQueueCard(filteredQueue[idx], isDark),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildQueueCard(Map<String, dynamic> ticket, bool isDark) {
    final status = ticket['status'] as String? ?? 'waiting';
    final ticketNum = ticket['ticket_number'] as String? ?? 'A000';
    final customerName = ticket['customer_name'] as String? ?? 'Pelanggan';
    final phone = ticket['phone_number'] as String?;
    final service = ticket['service_name'] as String? ?? 'Haircut Walk-In';
    final station = ticket['station_or_chair'] as String?;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'serving':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Sedang Diservis';
        statusIcon = Icons.cut_rounded;
        break;
      case 'calling':
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Sedang Dipanggil';
        statusIcon = Icons.notifications_active_rounded;
        break;
      case 'completed':
        statusColor = const Color(0xFF6B7280);
        statusLabel = 'Selesai';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'Dibatalkan';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = const Color(0xFF3B82F6);
        statusLabel = 'Menunggu Giliran';
        statusIcon = Icons.hourglass_top_rounded;
    }

    final isServing = status == 'serving';
    final isCalling = status == 'calling';
    final isWaiting = status == 'waiting';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161624) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isServing
              ? const Color(0xFF10B981)
              : (isCalling ? const Color(0xFFF59E0B) : (isDark ? Colors.white10 : Colors.black12)),
          width: isServing || isCalling ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isServing
                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Ticket Number & Status Badge
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    ticketNum,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        service,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Station info (if assigned)
          if (station != null && station.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_seat_rounded, color: AppColors.primary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Stesen Bertugas: $station',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Colors.white10),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (phone != null && phone.isNotEmpty) ...[
                  IconButton(
                    icon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 18),
                    onPressed: () => _callCustomer(phone),
                    tooltip: 'Hubungi Pelanggan',
                  ),
                  IconButton(
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedMessage01, color: Color(0xFF25D366), size: 18),
                    onPressed: () => _openWhatsApp(phone),
                    tooltip: 'WhatsApp Pelanggan',
                  ),
                  const SizedBox(width: 4),
                ],

                // Dynamic State-based Main Button
                Expanded(
                  child: isWaiting
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFF59E0B)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () => _handleCallTicket(ticket),
                                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFF59E0B), size: 16),
                                label: const Text(
                                  'Panggil',
                                  style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () => _promptStartServing(ticket),
                                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                                label: const Text(
                                  'Mula Servis',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        )
                      : isCalling
                          ? Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFF59E0B)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    onPressed: () => _handleCallTicket(ticket),
                                    icon: const Icon(Icons.repeat_rounded, color: Color(0xFFF59E0B), size: 16),
                                    label: const Text(
                                      'Ulang Panggil',
                                      style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    onPressed: () => _promptStartServing(ticket),
                                    icon: const Icon(Icons.play_arrow_rounded, size: 16),
                                    label: const Text(
                                      'Mula Servis',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : isServing
                              ? SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    onPressed: () => _handleCompleteTicket(ticket),
                                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                                    label: const Text(
                                      'Selesai & Tamat Servis',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  alignment: Alignment.center,
                                  child: Text(
                                    status == 'completed' ? 'Servis telah selesai' : 'Dibatalkan',
                                    style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12),
                                  ),
                                ),
                ),

                if (isWaiting || isCalling)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 18),
                    onPressed: () => _handleCancelTicket(ticket),
                    tooltip: 'Batal Giliran',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 2. APPOINTMENTS TAB (PRESERVED)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildAppointmentsTab(bool isDark) {
    final filteredList = _myServices.where((s) {
      if (_selectedFilter == 0) return (s['timeSlot'] as String).contains('Today');
      if (_selectedFilter == 1) return (s['timeSlot'] as String).contains('Tomorrow');
      return s['status'] == ServiceStatus.completed;
    }).toList();

    return Column(
      children: [
        // Filter Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                    'Tiada tempahan berjadual dalam kategori ini.',
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
