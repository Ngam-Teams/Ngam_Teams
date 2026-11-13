import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/teams_supabase_service.dart';
import '../../../widgets/glass_toast.dart';

// ============================================================
// EarningsScreen — Digital Payslips, Commission & Tips Tracker
// ============================================================

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double _basicSalary = 0.00;
  final double _overtimePay = 0.00;
  double _commissionPay = 0.00;
  final double _tipsPay = 0.00;
  bool _isLoading = false;

  double get _grossPay => _basicSalary + _overtimePay + _commissionPay + _tipsPay;
  double get _epfDeduction => _basicSalary * 0.11; // 11% EPF
  double get _socsoDeduction => _basicSalary > 0 ? 9.25 : 0.0; // SOCSO
  double get _eisDeduction => _basicSalary > 0 ? 3.70 : 0.0; // EIS
  double get _netPay => _grossPay - (_epfDeduction + _socsoDeduction + _eisDeduction);

  List<Map<String, dynamic>> _payslipHistory = [];
  List<Map<String, dynamic>> _commissionsToday = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPayrollData();
  }

  Future<void> _loadPayrollData() async {
    setState(() => _isLoading = true);
    try {
      final settings = await TeamsSupabaseService.instance.fetchMyPayrollSettings();
      final payslips = await TeamsSupabaseService.instance.fetchMyPayroll();
      final tempahan = await TeamsSupabaseService.instance.fetchMyTempahan();

      if (mounted) {
        double basic = 0.0;
        if (settings != null) {
          basic = (settings['base_salary'] as num?)?.toDouble() ?? 0.0;
        }

        double commToday = 0.0;
        final List<Map<String, dynamic>> commItems = [];
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);

        for (final b in tempahan) {
          final bDate = (b['booking_date'] as String? ?? '');
          final comm = (b['commission_amount'] as num?)?.toDouble() ?? 0.0;
          if (comm > 0) {
            commToday += comm;
            if (bDate == todayStr) {
              commItems.add({
                'service': b['service_name'] ?? b['title'] ?? 'Perkhidmatan',
                'time': b['booking_time'] ?? '',
                'price': (b['total_amount'] as num?)?.toDouble() ?? 0.0,
                'comm': comm,
              });
            }
          }
        }

        setState(() {
          _basicSalary = basic;
          _commissionPay = commToday;
          _commissionsToday = commItems;
          _payslipHistory = payslips.map((p) {
            final month = p['month'] as String? ?? 'Bulan Semasa';
            final basicVal = (p['base_salary'] as num?)?.toDouble() ?? 0.0;
            final allowance = (p['allowance'] as num?)?.toDouble() ?? 0.0;
            final bonus = (p['bonus'] as num?)?.toDouble() ?? 0.0;
            final commVal = (p['commission'] as num?)?.toDouble() ?? 0.0;
            final netVal = (p['net_salary'] as num?)?.toDouble() ?? 0.0;
            final statusStr = p['status'] as String? ?? 'pending';

            return {
              'month': month,
              'payDate': p['created_at'] != null ? (p['created_at'] as String).substring(0, 10) : '—',
              'basic': basicVal,
              'ot': allowance + bonus,
              'commission': commVal,
              'tips': 0.0,
              'net': netVal,
              'status': statusStr == 'paid' || statusStr == 'approved' ? 'Dibayar' : 'Menunggu Kelulusan',
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _downloadPayslip(String month) {
    showGlassToast(context, 'Memuat turun slip gaji rasmi PDF bagi bulan $month...');
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
              'Gaji, Komisen & Tip Saya',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Slip gaji digital, komisen servis & pecahan tip harian',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: isDark ? Colors.white : AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          tabs: const [
            Tab(text: 'Bulan Semasa (Sep 2026)'),
            Tab(text: 'Arkib Slip Gaji'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentMonthTab(isDark),
          _buildHistoryTab(isDark),
        ],
      ),
    );
  }

  Widget _buildCurrentMonthTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Earnings Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Anggaran Gaji Bersih (Sep 2026)',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('TERKUMPUL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'RM ${_netPay.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gaji Pokok', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('RM ${_basicSalary.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OT (16 Jam)', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('RM ${_overtimePay.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Komisen Servis', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('RM ${_commissionPay.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFF9C80E), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Shared Tip Pool Today
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161624) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedCoins01, color: Color(0xFFF59E0B), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tabung Tip Bersama Hari Ini (Pool)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'RM 120.00 dikongsi antara 5 krew bertugas',
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+RM 24.00',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text('Bahagian anda', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Statutory Deductions Overview
          Text(
            'Potongan Statutori Malaysia (Anggaran)',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161624) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Column(
              children: [
                _buildDeductionRow('KWSP (EPF) Pekerja (11%)', 'RM ${_epfDeduction.toStringAsFixed(2)}', isDark),
                const Divider(height: 16, color: Colors.white10),
                _buildDeductionRow('PERKESO (SOCSO) Syif A', 'RM ${_socsoDeduction.toStringAsFixed(2)}', isDark),
                const Divider(height: 16, color: Colors.white10),
                _buildDeductionRow('Sistem Insurans Pekerjaan (EIS/SIP)', 'RM ${_eisDeduction.toStringAsFixed(2)}', isDark),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Commissions Log
          Text(
            'Komisen Servis Hari Ini',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (_commissionsToday.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Tiada komisen dicatatkan hari ini.',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ..._commissionsToday.map((c) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161624) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['service'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${c['time']} • Nilai Jualan: RM ${(c['price'] as double).toStringAsFixed(2)}',
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(
                      '+RM ${(c['comm'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDeductionRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
        Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildHistoryTab(bool isDark) {
    if (_payslipHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              const SizedBox(height: 12),
              Text(
                'Tiada Rekod Slip Gaji',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Slip gaji bulanan yang telah diluluskan oleh majikan akan dipaparkan di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _payslipHistory.length,
      itemBuilder: (ctx, idx) {
        final p = _payslipHistory[idx];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161624) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p['month'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      p['status'] as String,
                      style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tarikh Bayaran: ${p['payDate']}', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                  Text(
                    'RM ${(p['net'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ],
              ),
              const Divider(height: 20, color: Colors.white10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _downloadPayslip(p['month'] as String),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: const Text('Muat Turun Slip Gaji (PDF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
