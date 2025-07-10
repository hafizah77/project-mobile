import 'package:flutter/material.dart'; // # Import package utama Flutter untuk UI
import 'package:travel_app/page/addPage.dart'; // # Import halaman untuk menambahkan destinasi
import 'package:travel_app/page/widgets/bottomNavbar.dart'; // # (Opsional) Import widget navbar bawah jika digunakan

// # Stateless widget untuk halaman utama admin
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key}); // # Constructor default

  @override
  Widget build(BuildContext context) {
    // # Scaffold adalah kerangka utama halaman
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'), // # Judul di app bar
        backgroundColor: Colors.deepPurple, // # Warna latar belakang AppBar
        centerTitle: true, // # Menengahkan teks di AppBar
      ),

      // # Body halaman: menampilkan ucapan selamat datang admin
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // # Menengahkan konten secara vertikal
          children: const [
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.deepPurple), // # Ikon admin besar
            SizedBox(height: 16), // # Jarak vertikal
            Text(
              'Selamat Datang Admin', // # Teks sambutan
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // # Gaya teks tebal
            ),
            SizedBox(height: 8), // # Spasi
            Text('Kelola destinasi, pengguna, dan transaksi di sini'), // # Deskripsi singkat halaman
          ],
        ),
      ),

      // # Tombol tambah di kanan bawah layar
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple, // # Warna tombol
        onPressed: () {
          // # Navigasi ke halaman penambahan destinasi saat tombol ditekan
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDestinationPage()), // # Pindah ke AddDestinationPage
          );
        },
        child: const Icon(Icons.add), // # Ikon tambah
        tooltip: 'Tambah Destinasi', // # Tooltip saat hover (di web atau long-press di mobile)
      ),

      // #  Navigasi bawah, misal tab Home, Riwayat, Profil, dll.
      bottomNavigationBar: const BottomNavbar(currentIndex: 0), // # currentIndex menunjukkan tab aktif
    );
  }
}
