import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../auth/change_password_screen.dart';

class AkunScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const AkunScreen({super.key, required this.onLogout});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  UserModel? _user;
  String _baseUrl = '';
  String _apiKey = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await AuthService.getUser();
    final url = await AuthService.getBaseUrl();
    final key = await AuthService.getApiKey();

    if (!mounted) return;

    setState(() {
      _user = user;
      _baseUrl = url;
      _apiKey = key;
    });
  }

  void _showServerSettingsDialog() {
    final urlController = TextEditingController(text: _baseUrl);
    final keyController = TextEditingController(text: _apiKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.dns_rounded, color: AppColors.navyLight),
            SizedBox(width: 8),
            Text('Konfigurasi API Server', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sesuaikan alamat backend server Laragon:',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Base URL API',
                hintText: 'http://localhost/classcash/api',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'cc_live_xxxxxxxx',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Chrome Browser: http://localhost/classcash/api\n• HP Fisik (WiFi): http://10.157.86.10/classcash/api',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await AuthService.setBaseUrl(urlController.text.trim());
              await AuthService.setApiKey(keyController.text.trim());
              _loadProfile();
              nav.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan API berhasil diperbarui!'),
                  backgroundColor: AppColors.greenSuccess,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
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
                color: AppColors.navyDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              AppConstants.appName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navyDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versi 1.0.0 (Mobile Client)',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aplikasi Manajemen Keuangan & Iuran Kas Kelas XII RPL 1\nSMKS Informatika Sumedang',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4),
            ),
            const Divider(height: 24),
            const Text(
              'Terhubung langsung ke database MySQL ClassCash via RESTful API.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin mengakhiri sesi dan keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redDanger,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.logout();
              widget.onLogout();
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Akun & Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ─── KARTU PROFIL USER ───
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.navyDark,
                    child: Text(
                      _user?.nama.isNotEmpty == true ? _user!.nama[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user?.nama ?? 'Bendahara Kelas',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${_user?.username ?? "-"}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.navyLight.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _user?.role == 'wali_kelas' ? 'Wali Kelas (Admin)' : 'Bendahara Kasir',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navyLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ─── PENGATURAN KEAMANAN & SISTEM ───
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Text(
              'Pengaturan & Keamanan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
          ),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.navyLight.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.lock_reset_rounded, color: AppColors.navyLight, size: 20),
                  ),
                  title: const Text('Ganti Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Perbarui kata sandi akun Anda', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => const ChangePasswordScreen()),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.blueInfo.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.dns_rounded, color: AppColors.blueInfo, size: 20),
                  ),
                  title: const Text('Pengaturan API Server', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(_baseUrl, style: const TextStyle(fontSize: 12, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                  onTap: _showServerSettingsDialog,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.amberWarning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.info_outline_rounded, color: AppColors.amberWarning, size: 20),
                  ),
                  title: const Text('Tentang ClassCash', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Versi aplikasi & informasi sekolah', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                  onTap: _showAboutDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── TOMBOL LOGOUT ───
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redDanger,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('Keluar dari Akun (Logout)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            onPressed: _confirmLogout,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
