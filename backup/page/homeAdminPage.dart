import 'package:flutter/material.dart';
import 'package:travel_app/page/addPage.dart';
import 'package:travel_app/page/widgets/bottomNavbar.dart'; // Jika kamu gunakan

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.deepPurple),
            SizedBox(height: 16),
            Text(
              'Selamat Datang Admin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Kelola destinasi, pengguna, dan transaksi di sini'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDestinationPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Destinasi',
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0), // opsional, jika kamu pakai BottomNavbar
    );
  }
}
