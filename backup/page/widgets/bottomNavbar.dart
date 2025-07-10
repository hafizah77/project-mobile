import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/page/adminProfilPage.dart';
import 'package:travel_app/page/historyAdminPage.dart';
import 'package:travel_app/page/homeAdminPage.dart';

// User Pages
import 'package:travel_app/page/homeUserPage.dart';
import 'package:travel_app/page/favoritUserPage.dart';
import 'package:travel_app/page/userProfilPage.dart';
import 'package:travel_app/page/transactionHistoryUserPage.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    if (mounted) {
      setState(() {
        _role = role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return const SizedBox(); // Bisa diganti dengan loader jika perlu
    }

    return _role == 'admin' ? _buildAdminNavbar() : _buildUserNavbar();
  }

  void _navigateWithoutStack(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // ✅ NAVBAR UNTUK ADMIN - Dashboard, Riwayat, Profil
  Widget _buildAdminNavbar() {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        if (index == widget.currentIndex) return;
        switch (index) {
          case 0:
            _navigateWithoutStack(const AdminHomePage());
            break;
          case 1:
            _navigateWithoutStack(const RiwayatAdminPage());
            break;
          case 2:
            _navigateWithoutStack(const AdminProfilePage());
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Riwayat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  // ✅ NAVBAR UNTUK USER - Beranda, Favorit, Riwayat, Profil
  Widget _buildUserNavbar() {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        if (index == widget.currentIndex) return;
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FavoritePage()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TransactionHistoryPage()),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Riwayat',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}
