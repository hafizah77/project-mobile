import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/page/widgets/bottomNavbar.dart';

class RiwayatAdminPage extends StatefulWidget {
  const RiwayatAdminPage({super.key});

  @override
  State<RiwayatAdminPage> createState() => _RiwayatAdminPageState();
}

class _RiwayatAdminPageState extends State<RiwayatAdminPage> {
  final String baseUrl = 'https://travel-app-e27ba-default-rtdb.firebaseio.com';

  List<Map<String, dynamic>> _aktivitas = [];

  @override
  void initState() {
    super.initState();
    _loadAktivitas();
  }

  Future<void> _loadAktivitas() async {
    final data = await _fetchAktivitas();
    setState(() {
      _aktivitas = data;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAktivitas() async {
    List<Map<String, dynamic>> aktivitas = [];

    try {
      final transaksiLogDocs = await FirebaseFirestore.instance
          .collection('transaction_logs')
          .get();

      for (var doc in transaksiLogDocs.docs) {
        aktivitas.add({
          'id': doc.id,
          'source': 'transaction_logs',
          'type': 'Transaksi',
          'email': doc['user_email'] ?? '-',
          'detail':
              'Transaksi ke ${doc['destination_name']} sebanyak ${doc['ticket_count']} tiket (Rp${doc['total_price']})',
          'timestamp': (doc['timestamp'] ?? Timestamp.now()).toDate(),
        });
      }
    } catch (e) {
      debugPrint("Error transaction_logs: $e");
    }

    try {
      final favLogDocs = await FirebaseFirestore.instance
          .collection('favorite_logs')
          .get();

      for (var doc in favLogDocs.docs) {
        final action = doc['action'] == 'added' ? 'menambahkan' : 'menghapus';
        aktivitas.add({
          'id': doc.id,
          'source': 'favorite_logs',
          'type': 'Favorit',
          'email': doc['user_email'] ?? '-',
          'detail': 'User $action favorit destinasi (ID: ${doc['place_id']})',
          'timestamp': (doc['timestamp'] ?? Timestamp.now()).toDate(),
        });
      }
    } catch (e) {
      debugPrint("Error favorite_logs: $e");
    }

    try {
      final loginDocs = await FirebaseFirestore.instance
          .collection('logins')
          .get();
      for (var doc in loginDocs.docs) {
        aktivitas.add({
          'id': doc.id,
          'source': 'logins',
          'type': 'Login',
          'email': doc['user_email'] ?? '-',
          'detail': 'Login ke aplikasi',
          'timestamp': (doc['timestamp'] ?? Timestamp.now()).toDate(),
        });
      }
    } catch (e) {
      debugPrint("Error logins: $e");
    }

    try {
      final regRes = await http.get(Uri.parse('$baseUrl/registers.json'));
      if (regRes.statusCode == 200 && regRes.body != 'null') {
        final regData = json.decode(regRes.body) as Map<String, dynamic>;
        regData.forEach((key, value) {
          aktivitas.add({
            'id': key,
            'source': 'registers',
            'type': 'Register',
            'email': value['user_email'] ?? '-',
            'detail': 'Registrasi pengguna baru',
            'timestamp': DateTime.tryParse(value['timestamp'] ?? '') ?? DateTime.now(),
          });
        });
      }
    } catch (e) {
      debugPrint("Error registers: $e");
    }

    aktivitas.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return aktivitas;
  }

  Icon _getIconByType(String type) {
    switch (type) {
      case 'Transaksi':
        return const Icon(Icons.shopping_cart, color: Colors.green);
      case 'Login':
        return const Icon(Icons.login, color: Colors.blue);
      case 'Favorit':
        return const Icon(Icons.favorite, color: Colors.pink);
      case 'Register':
        return const Icon(Icons.app_registration, color: Colors.orange);
      case 'Komentar':
        return const Icon(Icons.comment, color: Colors.teal);
      default:
        return const Icon(Icons.info_outline);
    }
  }

  Future<void> _deleteLog(Map<String, dynamic> item) async {
    if (item['source'] == 'registers') {
      await http.delete(Uri.parse('$baseUrl/registers/${item['id']}.json'));
    } else {
      await FirebaseFirestore.instance
          .collection(item['source'])
          .doc(item['id'])
          .delete();
    }

    setState(() {
      _aktivitas.removeWhere((a) => a['id'] == item['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Log berhasil dihapus'),
      backgroundColor: Colors.red,
    ));
  }

  void _editLog(Map<String, dynamic> item) {
    final controller = TextEditingController(text: item['detail']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Aktivitas'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Detail Aktivitas'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final newDetail = controller.text.trim();
              if (item['source'] != 'registers') {
                await FirebaseFirestore.instance
                    .collection(item['source'])
                    .doc(item['id'])
                    .update({'detail': newDetail});
              }
              setState(() {
                item['detail'] = newDetail;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _addLog() {
    final emailController = TextEditingController();
    final detailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Aktivitas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: detailController, decoration: const InputDecoration(labelText: 'Detail')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              final detail = detailController.text.trim();
              final newDoc = await FirebaseFirestore.instance.collection('logins').add({
                'user_email': email,
                'detail': detail,
                'timestamp': FieldValue.serverTimestamp(),
              });
              setState(() {
                _aktivitas.insert(0, {
                  'id': newDoc.id,
                  'source': 'logins',
                  'type': 'Login',
                  'email': email,
                  'detail': detail,
                  'timestamp': DateTime.now(),
                });
              });
              Navigator.pop(ctx);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas Pengguna'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addLog,
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
      body: _aktivitas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _aktivitas.length,
              itemBuilder: (context, index) {
                final item = _aktivitas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: _getIconByType(item['type']),
                    title: Text(item['detail']),
                    subtitle: Text(item['email']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatDate(item['timestamp']),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editLog(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteLog(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
