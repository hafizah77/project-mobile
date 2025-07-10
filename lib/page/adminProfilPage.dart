import 'package:flutter/material.dart'; // # Paket utama Flutter
import 'package:cloud_firestore/cloud_firestore.dart'; // # Untuk akses Firestore
import 'package:shared_preferences/shared_preferences.dart'; // # Untuk menyimpan data lokal (session)
import 'package:travel_app/page/loginPage.dart'; // # Halaman login
import 'package:travel_app/page/widgets/bottomNavbar.dart'; // # Widget navigasi bawah

// # Halaman Profil Admin sebagai StatefulWidget (karena data berubah)
class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

// # State utama dari halaman profil admin
class _AdminProfilePageState extends State<AdminProfilePage> with SingleTickerProviderStateMixin {
  String? _name; // # Nama admin yang ditampilkan
  String? _email; // # Email admin yang ditampilkan
  bool _isLoading = false; // # Menandakan apakah data sedang di-load

  // # Palet warna kustom
  static const Color primaryColor = Color(0xFF00B2FF);
  static const Color secondaryColor = Color(0xFF2D3A8C);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF343A40);

  // # Controller dan animasi
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadAdminProfile(); // # Ambil data dari SharedPreferences saat mulai

    // # Inisialisasi animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // # Animasi fade-in
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    // # Animasi geser dari bawah ke atas
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _animationController.dispose(); // # Hapus animasi saat widget dispose
    super.dispose();
  }

  // =================== LOGIKA INTI ===================

  // # Ambil data user_name dan user_email dari SharedPreferences
  Future<void> _loadAdminProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _name = prefs.getString('user_name') ?? 'Admin';
        _email = prefs.getString('user_email') ?? 'admin@example.com';
        _isLoading = false;
      });
      _animationController.forward(); // # Jalankan animasi saat data sudah siap
    }
  }

  // # Fungsi untuk logout: hapus SharedPreferences & navigasi ke LoginPage
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // # Hapus semua data
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // # Fungsi untuk menghapus akun dari Firestore dan SharedPreferences
  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Hapus Akun'),
        content: const Text('Apakah Anda yakin ingin menghapus akun ini? Semua data akan hilang secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');

      if (email != null) {
        try {
          // # Hapus dokumen user berdasarkan email
          final snapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

          for (var doc in snapshot.docs) {
            await doc.reference.delete();
          }

          await prefs.clear(); // # Hapus session lokal

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Akun berhasil dihapus')),
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus akun: $e')));
          }
        }
      }
    }
  }

  // =================== UI ===================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Profil Admin'),
        titleTextStyle: const TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2), // # Navigasi bawah halaman profil
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor)) // # Loading saat data belum siap
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation, // # Efek fade masuk
                    child: SlideTransition(
                      position: _slideAnimation, // # Efek geser masuk
                      child: _buildProfileCard(), // # Card utama
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // # Membangun tampilan kartu profil
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // # Ikon admin
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              size: 70,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // # Nama dan email admin
          Text(
            _name ?? 'Admin',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _email ?? 'admin@example.com',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 20),
          _buildActionButtons(), // # Tombol logout dan hapus akun
        ],
      ),
    );
  }

  // # Tombol aksi (logout dan hapus akun)
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text("Keluar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _deleteAccount,
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Hapus Akun'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
