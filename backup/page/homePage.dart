import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/page/addPage.dart';
import 'package:travel_app/page/detailPage.dart';
import 'package:travel_app/page/widgets/bottomNavbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> favoriteIds = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteIds = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> toggleFavorite(String placeId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList('favorites') ?? [];

    setState(() {
      if (favs.contains(placeId)) {
        favs.remove(placeId);
      } else {
        favs.add(placeId);
      }
      prefs.setStringList('favorites', favs);
      favoriteIds = favs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference places =
        FirebaseFirestore.instance.collection('places');

    return Scaffold(
      appBar: AppBar(title: const Text('TravelKu'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: places.orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada tempat wisata'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isFavorite = favoriteIds.contains(doc.id);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailPage(data: data, docId: docs[index].id,)),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      data['image_url'] != null && data['image_url'] != ""
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                data['image_url'],
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(
                                    height: 180,
                                    child: Center(
                                      child: Text('Gagal memuat gambar'),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('Tidak ada gambar'),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    data['name'] ?? 'Tanpa Nama',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    toggleFavorite(doc.id);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['location'] ?? 'Lokasi tidak diketahui',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['description'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Harga Tiket: Rp${data['price'] ?? 0}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDestinationPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }
}
