import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/siswa_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class SiswaScreen extends StatefulWidget {
  const SiswaScreen({super.key});

  @override
  State<SiswaScreen> createState() => _SiswaScreenState();
}

class _SiswaScreenState extends State<SiswaScreen> {
  List<SiswaModel> _allSiswa = [];
  List<SiswaModel> _filteredSiswa = [];

  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedFilter = 'semua'; // 'semua', 'menunggak', 'lunas'

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSiswa();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSiswa() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await ApiService.get('siswa.php', queryParams: {'status': 'aktif'});

    if (!mounted) return;

    if (response.success && response.data != null && response.data['items'] != null) {
      final List list = response.data['items'];
      setState(() {
        _allSiswa = list.map((item) => SiswaModel.fromJson(item)).toList();
        _applyFilter();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    List<SiswaModel> temp = List.from(_allSiswa);

    // Filter kategori
    if (_selectedFilter == 'menunggak') {
      temp = temp.where((s) => s.totalTunggakanMinggu > 0).toList();
    } else if (_selectedFilter == 'lunas') {
      temp = temp.where((s) => s.totalTunggakanMinggu == 0).toList();
    }

    // Filter pencarian
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      temp = temp.where((s) {
        return s.nama.toLowerCase().contains(q) || s.nis.toLowerCase().contains(q);
      }).toList();
    }

    setState(() {
      _filteredSiswa = temp;
    });
  }

  String _formatRupiah(num value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  // ─── MODAL BOTTOM SHEET PEMBAYARAN IURAN SISWA (POST) ───
  void _openPaymentModal(SiswaModel siswa) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PaymentModalContent(
        siswa: siswa,
        formatRupiah: _formatRupiah,
        onPaymentSuccess: () {
          _fetchSiswa(); // Refresh daftar siswa setelah bayar
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Data Siswa & Kas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: _fetchSiswa,
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── SEARCH & FILTER BAR ───
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                // Input Pencarian
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau NIS siswa...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _applyFilter();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) {
                    _searchQuery = val;
                    _applyFilter();
                  },
                ),
                const SizedBox(height: 10),

                // Filter Kategori (Semua, Menunggak, Lunas)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('semua', 'Semua Siswa (${_allSiswa.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'menunggak',
                        'Belum Lunas (${_allSiswa.where((s) => s.totalTunggakanMinggu > 0).length})',
                        color: AppColors.redDanger,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'lunas',
                        'Lunas (${_allSiswa.where((s) => s.totalTunggakanMinggu == 0).length})',
                        color: AppColors.greenSuccess,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── DAFTAR SISWA ───
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
                              ElevatedButton(onPressed: _fetchSiswa, child: const Text('Coba Lagi')),
                            ],
                          ),
                        ),
                      )
                    : _filteredSiswa.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.person_search, size: 56, color: AppColors.textMuted),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Tidak ditemukan siswa dengan kata kunci "$_searchQuery"'
                                        : 'Tidak ada data siswa',
                                    style: const TextStyle(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchSiswa,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              itemCount: _filteredSiswa.length,
                              itemBuilder: (context, idx) {
                                final s = _filteredSiswa[idx];
                                final bool isLunas = s.totalTunggakanMinggu == 0;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => _openPaymentModal(s),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Row(
                                        children: [
                                          // Avatar Siswa
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: isLunas
                                                ? AppColors.greenSuccess.withOpacity(0.15)
                                                : AppColors.redDanger.withOpacity(0.15),
                                            child: Text(
                                              s.nama.isNotEmpty ? s.nama[0].toUpperCase() : 'S',
                                              style: TextStyle(
                                                color: isLunas ? AppColors.greenSuccess : AppColors.redDanger,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),

                                          // Info Nama & NIS
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  s.nama,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'NIS: ${s.nis}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),

                                                // Badge Status Tunggakan
                                                isLunas
                                                    ? Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.greenSuccess.withOpacity(0.12),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(Icons.check_circle, size: 12, color: AppColors.greenSuccess),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              'Lunas',
                                                              style: TextStyle(
                                                                color: AppColors.greenSuccess,
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.redDanger.withOpacity(0.12),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.redDanger),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              'Tunggakan ${s.totalTunggakanMinggu} Minggu (${_formatRupiah(s.totalTunggakanNominal)})',
                                                              style: const TextStyle(
                                                                color: AppColors.redDanger,
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),

                                          // Tombol Bayar
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isLunas ? const Color(0xFFF1F5F9) : AppColors.navyLight,
                                              foregroundColor: isLunas ? AppColors.textMuted : Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              elevation: 0,
                                            ),
                                            onPressed: () => _openPaymentModal(s),
                                            child: Text(
                                              isLunas ? 'Detail' : 'Bayar',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
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
    final bool isSelected = _selectedFilter == value;
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
          _selectedFilter = value;
          _applyFilter();
        });
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WIDGET MODAL PEMBAYARAN IURAN SISWA
// ─────────────────────────────────────────────────────────────
class _PaymentModalContent extends StatefulWidget {
  final SiswaModel siswa;
  final String Function(num) formatRupiah;
  final VoidCallback onPaymentSuccess;

  const _PaymentModalContent({
    required this.siswa,
    required this.formatRupiah,
    required this.onPaymentSuccess,
  });

  @override
  State<_PaymentModalContent> createState() => _PaymentModalContentState();
}

class _PaymentModalContentState extends State<_PaymentModalContent> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';

  List<dynamic> _unpaidWeeks = [];
  final Set<int> _selectedPeriodeIds = {};

  final _keteranganController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUnpaidWeeks();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _fetchUnpaidWeeks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await ApiService.get('iuran.php', queryParams: {'nis': widget.siswa.nis});

    if (!mounted) return;

    if (response.success && response.data != null) {
      final List items = response.data['items'] ?? [];
      setState(() {
        _unpaidWeeks = items;
        // Default: Centang semua minggu yang belum bayar
        _selectedPeriodeIds.clear();
        for (var item in items) {
          _selectedPeriodeIds.add(item['periode_id'] is int ? item['periode_id'] : int.parse(item['periode_id'].toString()));
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  double get _totalNominalSelected {
    double sum = 0.0;
    for (var item in _unpaidWeeks) {
      final id = item['periode_id'] is int ? item['periode_id'] : int.parse(item['periode_id'].toString());
      if (_selectedPeriodeIds.contains(id)) {
        sum += (item['nominal_wajib'] != null ? double.parse(item['nominal_wajib'].toString()) : 0.0);
      }
    }
    return sum;
  }

  // ─── POST BAYAR IURAN KE DATABASE ───
  Future<void> _submitPayment() async {
    if (_selectedPeriodeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu minggu yang akan dibayar!'),
          backgroundColor: AppColors.redDanger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final currentUser = await AuthService.getUser();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final payload = {
      'nis': widget.siswa.nis,
      'periode_ids': _selectedPeriodeIds.toList(),
      'tanggal': today,
      'keterangan': _keteranganController.text.trim().isNotEmpty
          ? _keteranganController.text.trim()
          : 'Iuran kas mingguan – ${_selectedPeriodeIds.length} minggu',
      'dibuat_oleh': currentUser?.id ?? 1,
    };

    final response = await ApiService.post('iuran.php', payload);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (response.success && response.data != null) {
      Navigator.pop(context); // Tutup modal
      widget.onPaymentSuccess();

      final resData = response.data;
      final nomorStruk = resData['nomor_struk'] ?? '-';
      final totalNominal = resData['total_nominal'] ?? _totalNominalSelected;

      // Tampilkan Dialog Sukses Struk Pembayaran
      _showSuccessReceiptDialog(nomorStruk, totalNominal);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.redDanger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessReceiptDialog(String noStruk, num nominal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greenSuccess.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.greenSuccess, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              'Setoran iuran kas untuk ${widget.siswa.nama} berhasil dicatat ke database.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Text('Nomor Struk Resmi', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    noStruk,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Setoran', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(
                        widget.formatRupiah(nominal),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.greenSuccess),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyLight,
              minimumSize: const Size(double.infinity, 44),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garis handle atas
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Siswa
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.siswa.nama,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    Text(
                      'NIS: ${widget.siswa.nis}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 24),

          // Konten Minggu Iuran
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: AppColors.redDanger)))
                    : _unpaidWeeks.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_rounded, size: 56, color: AppColors.greenSuccess),
                                SizedBox(height: 12),
                                Text(
                                  'Semua Iuran Siswa Ini Lunas!',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tidak ada tunggakan kas kelas.',
                                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Pilih Minggu yang Dibayar:',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_selectedPeriodeIds.length == _unpaidWeeks.length) {
                                          _selectedPeriodeIds.clear();
                                        } else {
                                          for (var item in _unpaidWeeks) {
                                            final id = item['periode_id'] is int ? item['periode_id'] : int.parse(item['periode_id'].toString());
                                            _selectedPeriodeIds.add(id);
                                          }
                                        }
                                      });
                                    },
                                    child: Text(
                                      _selectedPeriodeIds.length == _unpaidWeeks.length ? 'Batal Semua' : 'Pilih Semua',
                                      style: const TextStyle(fontSize: 12, color: AppColors.navyLight),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              ..._unpaidWeeks.map((item) {
                                final id = item['periode_id'] is int ? item['periode_id'] : int.parse(item['periode_id'].toString());
                                final mingguKe = item['minggu_ke'] ?? '-';
                                final nominal = item['nominal_wajib'] != null ? double.parse(item['nominal_wajib'].toString()) : 0.0;
                                final isSelected = _selectedPeriodeIds.contains(id);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.navyLight : const Color(0xFFE2E8F0),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: CheckboxListTile(
                                    value: isSelected,
                                    activeColor: AppColors.navyLight,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                    title: Text(
                                      'Minggu ke-$mingguKe',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                    ),
                                    subtitle: Text(
                                      '${item["tanggal_mulai"] ?? ""} – ${item["tanggal_selesai"] ?? ""}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                    secondary: Text(
                                      widget.formatRupiah(nominal),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppColors.navyLight : AppColors.textMuted,
                                      ),
                                    ),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _selectedPeriodeIds.add(id);
                                        } else {
                                          _selectedPeriodeIds.remove(id);
                                        }
                                      });
                                    },
                                  ),
                                );
                              }),

                              const SizedBox(height: 12),
                              // Keterangan Tambahan
                              TextField(
                                controller: _keteranganController,
                                decoration: const InputDecoration(
                                  labelText: 'Keterangan (Opsional)',
                                  hintText: 'Contoh: Titip lewat ketua kelas',
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
          ),

          // Total & Tombol Konfirmasi Bayar
          if (_unpaidWeeks.isNotEmpty) ...[
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedPeriodeIds.length} Minggu Terpilih',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    Text(
                      widget.formatRupiah(_totalNominalSelected),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navyDark),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenSuccess,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline, size: 20),
                  label: Text(_isSubmitting ? 'Menyimpan...' : 'Bayar Sekarang'),
                  onPressed: _isSubmitting ? null : _submitPayment,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
