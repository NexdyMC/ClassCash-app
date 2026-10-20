import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class BerandaScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const BerandaScreen({super.key, required this.onNavigateTab});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  UserModel? _user;
  bool _isLoading = true;
  String _errorMessage = '';

  // Data Dashboard
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final user = await AuthService.getUser();
    final response = await ApiService.get('dashboard.php');

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _user = user;
        _dashboardData = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _user = user;
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  String _formatRupiah(num value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty && _dashboardData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Beranda')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.redDanger),
                const SizedBox(height: 16),
                const Text(
                  'Gagal Memuat Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadAllData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final saldo = _dashboardData?['saldo'] ?? {};
    final num saldoSaatIni = saldo['saldo_saat_ini'] ?? 0;
    final num totalMasuk = saldo['total_pemasukan'] ?? 0;
    final num totalKeluar = saldo['total_pengeluaran'] ?? 0;

    final ta = _dashboardData?['tahun_ajaran'] ?? {};
    final periode = _dashboardData?['periode_aktif'];
    final statIuran = _dashboardData?['statistik_iuran'] ?? {};
    final num persenLunas = statIuran['persentase_lunas'] ?? 0;
    final int lunasCount = statIuran['siswa_lunas'] ?? 0;
    final int belumCount = statIuran['siswa_belum'] ?? 0;

    final List recentTrx = _dashboardData?['transaksi_terbaru'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Halo, ${_user?.nama ?? "Bendahara"}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              'TA ${ta["label"] ?? "-"}',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ─── 1. KARTU SALDO UTAMA ───
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navyDark, AppColors.navyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navyDark.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Saldo Kas Kelas',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _user?.role == 'wali_kelas' ? 'Wali Kelas' : 'Bendahara',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatRupiah(saldoSaatIni),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),

                  // Arus Kas: Pemasukan & Pengeluaran
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.greenSuccess.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_downward_rounded, color: AppColors.greenSuccess, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pemasukan', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  Text(
                                    _formatRupiah(totalMasuk),
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.redDanger.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_upward_rounded, color: AppColors.redDanger, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pengeluaran', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  Text(
                                    _formatRupiah(totalKeluar),
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ─── 2. KARTU IURAN MINGGU BERJALAN ───
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Iuran Kas Minggu Ini',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.navyLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            periode != null ? 'Minggu ke-${periode["minggu_ke"]}' : '-',
                            style: const TextStyle(color: AppColors.navyLight, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      periode?['label_minggu'] ?? 'Belum ada periode iuran',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (persenLunas / 100).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.greenSuccess),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rincian Lunas vs Belum
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: AppColors.greenSuccess, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text('$lunasCount Siswa Lunas', style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: AppColors.redDanger, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text('$belumCount Belum Bayar', style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Text(
                          '$persenLunas%',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navyLight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ─── 3. TOMBOL AKSI CEPAT ───
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyLight,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: const Icon(Icons.payments_outlined, size: 20),
                    label: const Text('Catat Iuran Siswa', style: TextStyle(fontSize: 13)),
                    onPressed: () {
                      widget.onNavigateTab(1); // Buka Tab Siswa
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navyDark,
                      side: const BorderSide(color: AppColors.navyDark),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.history_rounded, size: 20),
                    label: const Text('Lihat Riwayat', style: TextStyle(fontSize: 13)),
                    onPressed: () {
                      widget.onNavigateTab(2); // Buka Tab Riwayat
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── 4. TRANSAKSI TERBARU ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaksi Terbaru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                TextButton(
                  onPressed: () {
                    widget.onNavigateTab(2);
                  },
                  child: const Text('Lihat Semua →', style: TextStyle(fontSize: 12, color: AppColors.navyLight)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (recentTrx.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textMuted),
                      SizedBox(height: 8),
                      Text('Belum ada transaksi di tahun ajaran ini', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              )
            else
              ...recentTrx.map((trx) {
                final isMasuk = trx['jenis'] == 'masuk';
                final num nominal = trx['nominal'] ?? 0;
                final namaSiswa = trx['nama_siswa'];
                final keterangan = trx['keterangan'] ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isMasuk ? AppColors.greenSuccess.withOpacity(0.12) : AppColors.redDanger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isMasuk ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: isMasuk ? AppColors.greenSuccess : AppColors.redDanger,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      namaSiswa != null ? '$namaSiswa' : keterangan,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${trx["tanggal"] ?? ""} • ${trx["nomor_struk"] ?? ""}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    trailing: Text(
                      '${isMasuk ? "+" : "-"}${_formatRupiah(nominal)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isMasuk ? AppColors.greenSuccess : AppColors.redDanger,
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
