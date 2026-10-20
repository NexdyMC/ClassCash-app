import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'akun/akun_screen.dart';
import 'beranda/beranda_screen.dart';
import 'riwayat/riwayat_screen.dart';
import 'siswa/siswa_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const MainNavigationScreen({super.key, required this.onLogout});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 4 Halaman Navigasi Utama (Tab Bar)
    final List<Widget> pages = [
      // 0. Halaman Beranda
      BerandaScreen(
        onNavigateTab: (targetIndex) {
          setState(() => _currentIndex = targetIndex);
        },
      ),
      // 1. Halaman Data Siswa & Bayar Iuran
      const SiswaScreen(),
      // 2. Halaman Riwayat Transaksi & Struk
      const RiwayatScreen(),
      // 3. Halaman Akun & Pengaturan
      AkunScreen(onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.navyLight.withOpacity(0.12),
          onDestinationSelected: (idx) {
            setState(() => _currentIndex = idx);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.navyLight),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people, color: AppColors.navyLight),
              label: 'Siswa',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history, color: AppColors.navyLight),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.navyLight),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}
