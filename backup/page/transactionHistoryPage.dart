import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/page/widgets/bottomNavbar.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('created_at', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
      body: StreamBuilder<QuerySnapshot>(
        stream: transactions.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada transaksi.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(data['destination_name'] ?? 'Tempat'),
                subtitle: Text(
                  'Pemesan: ${data['user_name'] ?? '-'}\n'
                  'Jumlah Tiket: ${data['ticket_count']}\n'
                  'Tanggal: ${data['visit_date'] != null ? (data['visit_date'] as Timestamp).toDate().toString().split(' ')[0] : '-'}',
                ),
                trailing: Text(
                  'Rp${data['total_price']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
