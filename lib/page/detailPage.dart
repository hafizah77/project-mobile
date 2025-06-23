import 'package:flutter/material.dart';
import 'transactionPage.dart'; // pastikan import ini sesuai dengan lokasi file kamu

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const DetailPage({super.key, required this.data, required this.docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Detail Tempat'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (data['image_url'] != null && data['image_url'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                data['image_url'],
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Text("Gagal memuat gambar"),
                  );
                },
              ),
            )
          else
            Container(
              height: 220,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Text("Tidak ada gambar"),
            ),
          const SizedBox(height: 16),
          Text(
            data['name'] ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                data['location'] ?? 'Lokasi tidak diketahui',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data['description'] ?? 'Tidak ada deskripsi.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            'Harga Tiket: Rp${data['price'] ?? 0}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionPage(
                    destinationData: data,
                    docId: docId,
                  ),
                ),
              );
            },
            child: const Text('Pesan Sekarang'),
          ),
        ],
      ),
    );
  }
}
