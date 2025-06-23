import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameCtrl.text.trim());
      await prefs.setString('user_email', _emailCtrl.text.trim());
      await prefs.setString('user_password', _passwordCtrl.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi berhasil!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Buat Akun Baru",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (val) =>
                    val!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) =>
                    val!.isEmpty ? 'Email tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (val) =>
                    val!.isEmpty ? 'Password tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
