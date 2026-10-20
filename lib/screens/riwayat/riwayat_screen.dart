import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/transaksi_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  List<TransaksiModel> _allTransaksi = [];
  List<TransaksiModel> _filteredTransaksi = [];

  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedJenis = 'semua'; // 'semua', 'masuk', 'keluar'
  String _searchQuery = '';

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTransaksi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransaksi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final Map<String, String> params = {'limit': '100'};
    if (_selectedJenis != 'semua') {
      params['jenis'] = _selectedJenis;
    }

    final response = await ApiService.get('transaksi.php', queryParams: params);

    if (!mounted) return;

    if (response.success && response.data != null && response.data['items'] != null) {
      final List items = response.data['items'];
      setState(() {
        _allTransaksi = items.map((item) => TransaksiModel.fromJson(item)).toList();
        _applySearchFilter();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  void _applySearchFilter() {
    if (_searchQuery.trim().isEmpty) {
      setState(() => _filteredTransaksi = List.from(_allTransaksi));
      return;
    }

    final q = _searchQuery.toLowerCase().trim();
    setState(() {
      _filteredTransaksi = _allTransaksi.where((trx) {
        final nama = trx.namaSiswa?.toLowerCase() ?? '';
        final ket = trx.keterangan.toLowerCase();
        final struk = trx.nomorStruk?.toLowerCase() ?? '';
        return nama.contains(q) || ket.contains(q) || struk.contains(q);
      }).toList();
    });
  }

  String _formatRupiah(num value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  // ─── DIALOG DETAIL STRUK DIGITAL ───
  void _showDetailStruk(TransaksiModel trx) {
    final bool isMasuk = trx.jenis == 'masuk';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Struk
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isMasuk ? AppColors.greenSuccess.withOpacity(0.12) : AppColors.redDanger.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isMasuk ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isMasuk ? AppColors.greenSuccess : AppColors.redDanger,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMasuk ? 'BUKTI PEMBAYARAN KAS' : 'BUKTI PENGELUARAN KAS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isMasuk ? AppColors.greenSuccess : AppColors.redDanger,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trx.nomorStruk ?? 'Trx #${trx.id}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Nominal Besar
            Center(
              child: Column(
                children: [
                  const Text('Nominal Mutasi', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(
                    '${isMasuk ? "+" : "-"}${_formatRupiah(trx.nominal)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isMasuk ? AppColors.greenSuccess : AppColors.redDanger,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rincian Baris Data
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Tanggal', trx.tanggal),
                  if (trx.namaSiswa != null) _buildDetailRow('Nama Siswa', trx.namaSiswa!),
                  _buildDetailRow('Keperluan / Catatan', trx.keterangan),
                  if (trx.dibuatOlehNama != null) _buildDetailRow('Dicatat Oleh', trx.dibuatOlehNama!),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyLight,
              minimumSize: const Size(double.infinity, 42),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  // ─── MODAL CATAT KAS KELUAR / BELANJA ───
  void _openCatatKeluarModal() {
    final ketController = TextEditingController();
    final nominalController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Catat Kas Keluar (Belanja Kelas)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              const Text(
                'Masukkan pengeluaran untuk keperluan kelas',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 18),

              // Keterangan
              TextField(
                controller: ketController,
                decoration: const InputDecoration(
                  labelText: 'Keperluan / Keterangan',
                  hintText: 'Contoh: Beli spidol & penghapus papan tulis',
                ),
              ),
              const SizedBox(height: 14),

              // Nominal
              TextField(
                controller: nominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Pengeluaran (Rp)',
                  hintText: 'Contoh: 15000',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redDanger,
                  minimumSize: const Size(double.infinity, 46),
                ),
                icon: isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.arrow_upward_rounded),
                label: Text(isSaving ? 'Menyimpan...' : 'Simpan Kas Keluar'),
                onPressed: isSaving
                    ? null
                    : () async {
                        final ket = ketController.text.trim();
                        final nom = double.tryParse(nominalController.text.replaceAll('.', '').replaceAll(',', '').trim()) ?? 0;

                        if (ket.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Keterangan pengeluaran wajib diisi!'), backgroundColor: AppColors.redDanger),
                          );
                          return;
                        }
                        if (nom <= 0) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Nominal harus lebih dari 0!'), backgroundColor: AppColors.redDanger),
                          );
                          return;
                        }

                        final nav = Navigator.of(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        setModalState(() => isSaving = true);
                        final user = await AuthService.getUser();
                        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

                        final res = await ApiService.post('transaksi.php', {
                          'jenis': 'keluar',
                          'nominal': nom,
                          'tanggal': today,
                          'keterangan': ket,
                          'dibuat_oleh': user?.id ?? 1,
                        });

                        setModalState(() => isSaving = false);

                        if (res.success) {
                          nav.pop();
                          _fetchTransaksi(); // Refresh daftar riwayat
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(res.message),
                              backgroundColor: AppColors.greenSuccess,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(res.message), backgroundColor: AppColors.redDanger),
                            );
                          }
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Riwayat',
            onPressed: _fetchTransaksi,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.navyDark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
        label: const Text('Catat Kas Keluar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        onPressed: _openCatatKeluarModal,
      ),
      body: Column(
        children: [
          // ─── SEARCH & FILTER BAR ───
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi, siswa, atau nomor struk...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _applySearchFilter();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _applySearchFilter();
                  },
                ),
                const SizedBox(height: 10),

                // Filter Tipe (Semua, Masuk, Keluar)
                Row(
                  children: [
                    _buildFilterChip('semua', 'Semua Mutasi'),
                    const SizedBox(width: 8),
                    _buildFilterChip('masuk', 'Kas Masuk', color: AppColors.greenSuccess),
                    const SizedBox(width: 8),
                    _buildFilterChip('keluar', 'Kas Keluar', color: AppColors.redDanger),
                  ],
                ),
              ],
            ),
          ),

          // ─── DAFTAR TRANSAKSI ───
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off, size: 48, color: AppColors.redDanger),
                              const SizedBox(height: 12),
                              Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
                              const SizedBox(height: 16),
                              ElevatedButton(onPressed: _fetchTransaksi, child: const Text('Coba Lagi')),
                            ],
                          ),
                        ),
                      )
                    : _filteredTransaksi.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textMuted),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Tidak ditemukan transaksi dengan kata kunci "$_searchQuery"'
                                        : 'Belum ada data transaksi',
                                    style: const TextStyle(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchTransaksi,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 80.0),
                              itemCount: _filteredTransaksi.length,
                              itemBuilder: (context, idx) {
                                final trx = _filteredTransaksi[idx];
                                final isMasuk = trx.jenis == 'masuk';

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    onTap: () => _showDetailStruk(trx),
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isMasuk
                                            ? AppColors.greenSuccess.withOpacity(0.12)
                                            : AppColors.redDanger.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        isMasuk ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                        color: isMasuk ? AppColors.greenSuccess : AppColors.redDanger,
                                        size: 22,
                                      ),
                                    ),
                                    title: Text(
                                      trx.namaSiswa != null ? trx.namaSiswa! : trx.keterangan,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 2),
                                        Text(
                                          '${trx.tanggal}${trx.nomorStruk != null ? " • ${trx.nomorStruk}" : ""}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                        if (trx.namaSiswa != null && trx.keterangan.isNotEmpty)
                                          Text(
                                            trx.keterangan,
                                            style: const TextStyle(fontSize: 11, color: AppColors.navyLight),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${isMasuk ? "+" : "-"}${_formatRupiah(trx.nominal)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isMasuk ? AppColors.greenSuccess : AppColors.redDanger,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Lihat Struk ›',
                                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, {Color? color}) {
    final bool isSelected = _selectedJenis == value;
    final activeColor = color ?? AppColors.navyLight;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: activeColor.withOpacity(0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? activeColor : AppColors.textMuted,
      ),
      side: BorderSide(
        color: isSelected ? activeColor : const Color(0xFFE2E8F0),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) {
        setState(() {
          _selectedJenis = value;
          _fetchTransaksi();
        });
      },
    );
  }
}
