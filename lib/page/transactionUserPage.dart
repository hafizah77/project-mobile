import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionPage extends StatefulWidget {
  final Map<String, dynamic> destinationData;
  final String docId;

  const TransactionPage({
    super.key,
    required this.destinationData,
    required this.docId,
    required userName,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ticketController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedMethod = 'Bayar di Tempat';
  bool _isLoading = false;
  String _userEmail = '';

  num get _totalPrice {
    final count = int.tryParse(_ticketController.text.trim()) ?? 0;
    final price = widget.destinationData['price'] ?? 0;
    return count * price;
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('user_email') ?? '';
    });
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    final int ticketCount = int.parse(_ticketController.text.trim());
    final int price = widget.destinationData['price'] ?? 0;
    final int total = ticketCount * price;

    setState(() => _isLoading = true);

    try {
      // Simpan transaksi utama
      await FirebaseFirestore.instance.collection('transactions').add({
        'destination_id': widget.docId,
        'destination_name': widget.destinationData['name'],
        'user_name': _nameController.text.trim(),
        'user_email': _userEmail,
        'ticket_count': ticketCount,
        'total_price': total,
        'visit_date': _selectedDate,
        'payment_method': _selectedMethod,
        'created_at': FieldValue.serverTimestamp(),
      });

      // ✅ Simpan log transaksi untuk admin
      await FirebaseFirestore.instance.collection('transaction_logs').add({
        'user_email': _userEmail,
        'destination_name': widget.destinationData['name'],
        'ticket_count': ticketCount,
        'total_price': total,
        'visit_date': _selectedDate,
        'payment_method': _selectedMethod,
        'action': 'transaksi',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil disimpan!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ticketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.destinationData;

    return Scaffold(
      appBar: AppBar(title: const Text('Form Pemesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                data['name'] ?? '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Pemesan'),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ticketController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah Tiket'),
                validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                items: const [
                  DropdownMenuItem(value: 'Bayar di Tempat', child: Text('Bayar di Tempat')),
                  DropdownMenuItem(value: 'Transfer Bank', child: Text('Transfer Bank')),
                  DropdownMenuItem(value: 'E-Wallet', child: Text('E-Wallet')),
                ],
                onChanged: (value) => setState(() => _selectedMethod = value),
                decoration: const InputDecoration(labelText: 'Metode Pembayaran'),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Pilih Tanggal Kunjungan'
                      : 'Tanggal: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              if (_ticketController.text.isNotEmpty)
                Text(
                  'Total Harga: Rp$_totalPrice',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitTransaction,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Pesan Sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
