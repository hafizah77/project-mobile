import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/page/homePage.dart';
import 'package:travel_app/page/registPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _email.text.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _showError('Email tidak terdaftar.');
        return;
      }

      final user = query.docs.first.data();
      if (user['password'] != _password.text.trim()) {
        _showError('Password salah.');
        return;
      }

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', user['name']);
      await prefs.setString('user_email', user['email']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Image.network(
                'https://cdn-icons-png.flaticon.com/512/201/201623.png',
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                "Selamat Datang di TravelKu!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("Silakan login untuk melanjutkan."),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (val) =>
                          val!.isEmpty ? 'Email wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Password"),
                      validator: (val) =>
                          val!.isEmpty ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text("Masuk"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage()),
                        );
                      },
                      child: const Text("Belum punya akun? Daftar sekarang"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
