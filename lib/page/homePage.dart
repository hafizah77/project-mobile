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
  String? userName;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteIds = prefs.getStringList('favorites') ?? [];
      userName = prefs.getString('user_name') ?? "Traveler";
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
      appBar: AppBar(
        title: const Text('TravelKu'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Halo, $userName 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  places.orderBy('created_at', descending: true).snapshots(),
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

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GridView.builder(
                    itemCount: docs.length,
                    padding: const EdgeInsets.only(bottom: 70),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final isFavorite = favoriteIds.contains(doc.id);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(
                                data: data,
                                docId: doc.id,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: data['image_url'] != null &&
                                        data['image_url'] != ""
                                    ? Image.network(
                                        data['image_url'],
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            height: 120,
                                            color: Colors.grey[300],
                                            alignment: Alignment.center,
                                            child: const Text(
                                                'Gagal memuat gambar'),
                                          );
                                        },
                                      )
                                    : Container(
                                        height: 120,
                                        color: Colors.grey[300],
                                        alignment: Alignment.center,
                                        child: const Text('Tidak ada gambar'),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? 'Tanpa Nama',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['location'] ??
                                          'Lokasi tidak diketahui',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Rp${data['price'] ?? 0}',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: IconButton(
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite
                                              ? Colors.red
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          toggleFavorite(doc.id);
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
