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
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      bottomNavigationBar: const BottomNavbar(currentIndex: 3),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
          ),
          const SizedBox(height: 12),
          Text(
            _name ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            _email ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Profil (nonaktif)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Keluar', style: TextStyle(color: Colors.red)),
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
