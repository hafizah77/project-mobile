import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionPage extends StatefulWidget {
  final Map<String, dynamic> destinationData;
  final String docId; // ID destinasi

  const TransactionPage({super.key, required this.destinationData, required this.docId});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ticketController = TextEditingController();
  DateTime? _selectedDate;

  bool _isLoading = false;

  void _submitTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    final int ticketCount = int.parse(_ticketController.text.trim());
    final int price = widget.destinationData['price'] ?? 0;
    final int total = ticketCount * price;

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance.collection('transactions').add({
      'destination_id': widget.docId,
      'destination_name': widget.destinationData['name'],
      'user_name': _nameController.text.trim(),
      'ticket_count': ticketCount,
      'total_price': total,
      'visit_date': _selectedDate,
      'created_at': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil disimpan!')),
    );

    Navigator.pop(context);
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
              Text(data['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Pilih Tanggal Kunjungan'
                    : 'Tanggal: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitTransaction,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Pesan Sekarang'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
