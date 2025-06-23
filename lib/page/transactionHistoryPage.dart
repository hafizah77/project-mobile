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
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text(
                    'Apakah Anda yakin ingin menghapus semua transaksi?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );

              if (shouldDelete == true) {
                final snapshot = await FirebaseFirestore.instance
                    .collection('transactions')
                    .get();

                for (var doc in snapshot.docs) {
                  await doc.reference.delete();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua transaksi dihapus')),
                );
              }
            },
          ),
        ],
      ),

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
                trailing: SizedBox(
                  width: 80, // Atur lebar sesuai kebutuhan
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp${data['total_price']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus Transaksi'),
                              content: const Text(
                                'Apakah Anda yakin ingin menghapus transaksi ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await docs[index].reference.delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transaksi dihapus'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
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
