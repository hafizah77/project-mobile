import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/page/loginPage.dart';
import 'package:travel_app/page/widgets/bottomNavbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  String? _email;
  String? _imageType; // 'network' atau 'local'
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'Pengguna';
      _email = prefs.getString('user_email') ?? 'email@contoh.com';
      _imageType = prefs.getString('profile_image_type') ?? 'network';
      _imagePath =
          prefs.getString('profile_image_path') ??
          'https://i.pravatar.cc/150?img=3';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  ImageProvider<Object> _getImageProvider() {
    if (_imageType == 'local' && _imagePath != null) {
      return FileImage(File(_imagePath!));
    } else {
      return NetworkImage(_imagePath ?? 'https://i.pravatar.cc/150?img=3');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      bottomNavigationBar: const BottomNavbar(currentIndex: 3),
      body: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(radius: 50, backgroundImage: _getImageProvider()),
          const SizedBox(height: 12),
          Text(
            _name ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(_email ?? '', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Foto (simulasi ganti URL)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    // Ganti ke gambar baru dari internet (simulasi)
                    await prefs.setString('profile_image_type', 'network');
                    await prefs.setString(
                      'profile_image_path',
                      'https://i.pravatar.cc/150?img=5',
                    );
                    _loadProfile(); // refresh UI
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Keluar',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
