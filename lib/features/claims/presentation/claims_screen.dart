import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_toast.dart';

// ============================================================
// ClaimsScreen — Staff Expense Claims & Reimbursements
// ============================================================

enum ClaimStatus { pending, approved, reimbursed, rejected }

class ClaimsScreen extends StatefulWidget {
  const ClaimsScreen({super.key});

  @override
  State<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends State<ClaimsScreen> {
  late List<Map<String, dynamic>> _claims;

  @override
  void initState() {
    super.initState();
    _claims = [
      {
        'id': 'CLM-8821',
        'category': 'Ais Batu (Ice Refill)',
        'amount': 15.00,
        'vendor': 'Kedai Runcit Ah Seng',
        'date': 'Hari Ini, 10:45 AM',
        'status': ClaimStatus.pending,
        'hasReceipt': true,
        'notes': 'Stok ais habis waktu lunch rush.',
      },
      {
        'id': 'CLM-8819',
        'category': 'Tong Gas Memasak (Petroleum)',
        'amount': 42.00,
        'vendor': 'Stesen Minyak Petronas',
        'date': 'Semalam, 01:15 PM',
        'status': ClaimStatus.approved,
        'hasReceipt': true,
        'notes': 'Tong gas dapur ganti waktu memasak rendang.',
      },
      {
        'id': 'CLM-8802',
        'category': 'Petrol Hantar Makanan (COD)',
        'amount': 20.00,
        'vendor': 'Shell Bandar Hilir',
        'date': '26 Sep 2026',
        'status': ClaimStatus.reimbursed,
        'hasReceipt': true,
        'notes': 'Hantar 50 pek bento tempahan korporat.',
      },
      {
        'id': 'CLM-8790',
        'category': 'Sabun Cuci & Plastik Sampah',
        'amount': 28.50,
        'vendor': 'Speedmart 99',
        'date': '22 Sep 2026',
        'status': ClaimStatus.reimbursed,
        'hasReceipt': true,
        'notes': 'Sabun pencuci pinggan & mop lantai.',
      },
    ];
  }

  double get _totalPending => _claims.where((c) => c['status'] == ClaimStatus.pending).fold(0.0, (sum, c) => sum + (c['amount'] as double));
  double get _totalReimbursed => _claims.where((c) => c['status'] == ClaimStatus.reimbursed).fold(0.0, (sum, c) => sum + (c['amount'] as double));

  void _openSubmitClaimModal() {
    final amountCtrl = TextEditingController();
    final vendorCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedCategory = 'Ais Batu (Ice Refill)';
    bool receiptAttached = false;

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
                        const HugeIcon(icon: HugeIcons.strokeRoundedInvoice02, color: Color(0xFF10B981), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Tuntutan Belanja Staf (Claim)',
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
                      'Tuntut semula duit anda bagi pembelian kecemasan atau alatan kedai. Resit diperlukan.',
                      style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Category
                    Text('Kategori Belanja', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: isDark ? const Color(0xFF1A1A28) : Colors.white,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                        items: [
                          'Ais Batu (Ice Refill)',
                          'Tong Gas Memasak (Petroleum)',
                          'Bahan Dapur Kecemasan (Groceries)',
                          'Petrol Hantar Makanan (COD)',
                          'Sabun Cuci & Kebersihan',
                          'Baiki Alatan Kecil Kedai',
                        ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setModalState(() => selectedCategory = val!),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Amount input
                    Text('Jumlah Tuntutan (RM)', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: 'RM ',
                        prefixStyle: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                        hintText: '0.00',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Vendor name
                    Text('Nama Kedai / Penjual', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: vendorCtrl,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Cth: Kedai Runcit Ah Seng / Petronas',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Photo receipt attachment simulation
                    GestureDetector(
                      onTap: () {
                        setModalState(() => receiptAttached = true);
                        showGlassToast(context, 'Foto resit berjaya dimuat naik!');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: receiptAttached
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : (isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: receiptAttached ? const Color(0xFF10B981) : Colors.white24,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              receiptAttached ? Icons.check_circle_rounded : Icons.camera_alt_rounded,
                              color: receiptAttached ? const Color(0xFF10B981) : AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              receiptAttached ? 'Foto Resit Dilampirkan (IMG_2026.jpg)' : 'Ambil Foto Resit Belanja',
                              style: TextStyle(
                                color: receiptAttached ? const Color(0xFF10B981) : AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Remarks
                    Text('Catatan Tambahan', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesCtrl,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Cth: Beli 2 beg ais kerana ais blender habis',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F0F1B) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                          if (amt <= 0) {
                            showGlassToast(context, 'Sila masukkan jumlah perbelanjaan yang sah', isError: true);
                            return;
                          }

                          setState(() {
                            _claims.insert(0, {
                              'id': 'CLM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              'category': selectedCategory,
                              'amount': amt,
                              'vendor': vendorCtrl.text.trim().isEmpty ? 'Kedai Runcit' : vendorCtrl.text.trim(),
                              'date': 'Hari Ini, sebentar tadi',
                              'status': ClaimStatus.pending,
                              'hasReceipt': receiptAttached,
                              'notes': notesCtrl.text.trim(),
                            });
                          });

                          Navigator.pop(ctx);
                          showGlassToast(context, 'Tuntutan RM ${amt.toStringAsFixed(2)} berjaya dihantar untuk kelulusan Boss!');
                        },
                        child: const Text('Hantar Tuntutan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
              'Tuntutan Belanja Staf',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Klaim pembelian kecemasan & bayaran balik tunai',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF10B981), size: 24),
            tooltip: 'Buat Tuntutan Baru',
            onPressed: _openSubmitClaimModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Metrics Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161624) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.hourglass_top_rounded, color: Color(0xFFF59E0B), size: 20),
                        const SizedBox(height: 8),
                        Text('Menunggu Kelulusan', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('RM ${_totalPending.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161624) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                        const SizedBox(height: 8),
                        Text('Telah Dibayar (Bulan Ini)', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('RM ${_totalReimbursed.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button Action Card
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _openSubmitClaimModal,
                icon: const Icon(Icons.receipt_long_rounded, size: 20),
                label: const Text('Buat Tuntutan Baru (+ Resit)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 28),

            // Claims History
            Text(
              'Sejarah Tuntutan Saya',
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._claims.map((clm) => _buildClaimCard(clm, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimCard(Map<String, dynamic> clm, bool isDark) {
    final status = clm['status'] as ClaimStatus;
    final isPending = status == ClaimStatus.pending;
    final isApproved = status == ClaimStatus.approved;

    final badgeColor = isPending
        ? const Color(0xFFF59E0B)
        : isApproved
            ? AppColors.primary
            : const Color(0xFF10B981);

    final statusText = isPending
        ? 'Menunggu Boss'
        : isApproved
            ? 'Diluluskan'
            : 'Telah Dibayar';

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
              Expanded(
                child: Text(
                  clm['category'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'RM ',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  ' • ',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if ((clm['notes'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              clm['notes'] as String,
              style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
