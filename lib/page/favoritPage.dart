import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/page/widgets/bottomNavbar.dart';
class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
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

  @override
  Widget build(BuildContext context) {
    final placesRef = FirebaseFirestore.instance.collection('places');

    return Scaffold(
      appBar: AppBar(title: const Text('Tempat Favorit')),
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
      body: favoriteIds.isEmpty
          ? const Center(child: Text('Belum ada tempat favorit'))
          : FutureBuilder<QuerySnapshot>(
              future: placesRef.get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allPlaces = snapshot.data!.docs;
                final favPlaces = allPlaces.where((doc) =>
                    favoriteIds.contains(doc.id)).toList();

                if (favPlaces.isEmpty) {
                  return const Center(child: Text('Data tidak ditemukan'));
                }

                return ListView.builder(
                  itemCount: favPlaces.length,
                  itemBuilder: (context, index) {
                    final data =
                        favPlaces[index].data() as Map<String, dynamic>;

                    return ListTile(
                      leading: Image.network(
                        data['image_url'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.image_not_supported),
                      ),
                      title: Text(data['name'] ?? ''),
                      subtitle: Text(data['location'] ?? ''),
                    );
                  },
                );
              },
            ),
    );
  }
}
