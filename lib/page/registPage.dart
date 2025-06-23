import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/page/homePage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Simpan ke Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _name.text.trim());
      await prefs.setString('user_email', _email.text.trim());

      // Redirect ke HomePage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Pengguna")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Isi data lengkap untuk membuat akun.",
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: "Nama"),
                validator: (val) =>
                    val!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
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
                    val!.length < 6 ? 'Password minimal 6 karakter' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  child: const Text("Daftar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
