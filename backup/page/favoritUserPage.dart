import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/page/widgets/bottomNavbar.dart';
import 'package:travel_app/page/detailUserPage.dart';

// KELAS ANIMASI: Untuk item daftar yang muncul dengan halus
class _ListItemAnimation extends StatelessWidget {
  final int index;
  final Widget child;
  const _ListItemAnimation({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<String> _favoriteIds = [];
  bool _isLoading = true;
  String _userEmail = '';
  
  // PALET WARNA BARU (Konsisten dengan HomePage)
  static const Color primaryColor = Color(0xFF00B2FF);
  static const Color secondaryColor = Color(0xFF2D3A8C);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF343A40);

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';
    if (mounted) {
      setState(() {
        _userEmail = email;
        _favoriteIds = prefs.getStringList('favorites') ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(String placeId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentFavs = _favoriteIds;

    currentFavs.remove(placeId);
    await prefs.setStringList('favorites', currentFavs);

    if (mounted) {
      setState(() {
        _favoriteIds = currentFavs;
      });
    }

    await FirebaseFirestore.instance.collection('favorite_logs').add({
      'user_email': _userEmail,
      'place_id': placeId,
      'action': 'removed',
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dihapus dari favorit'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              title: const Text('🤍 Favorit Saya'),
              titleTextStyle: const TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.white,
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.1),
              centerTitle: true,
            ),
            bottomNavigationBar: const BottomNavbar(currentIndex: 1),
            body: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (_favoriteIds.isEmpty) {
      return _buildEmptyState();
    }

    final placesRef = FirebaseFirestore.instance
        .collection('places')
        .where(FieldPath.documentId, whereIn: _favoriteIds);

    return FutureBuilder<QuerySnapshot>(
      future: placesRef.get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan memuat data'));
        }
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        final favPlaces = snapshot.data?.docs ?? [];

        if (favPlaces.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: favPlaces.length,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          itemBuilder: (context, index) {
            final placeDoc = favPlaces[index];
            final data = placeDoc.data() as Map<String, dynamic>;
            // Menerapkan animasi pada setiap item
            return _ListItemAnimation(
              index: index,
              child: _buildFavoriteCard(placeDoc.id, data),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Favorit',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 12),
            Text(
              'Tempat yang Anda sukai akan muncul di sini. Jelajahi destinasi dan tekan ikon hati!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(String docId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailPage(data: data, docId: docId)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    data['image_url'] ?? '',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data['name'] ?? 'Tanpa Nama',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 15, color: Colors.grey[600]),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              data['location'] ?? 'Tanpa Lokasi',
                              style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Rp ${data['price']?.toString() ?? '0'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: secondaryColor,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                  tooltip: 'Hapus dari favorit',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Hapus Favorit'),
                        content: Text('Anda yakin ingin menghapus "${data['name']}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _removeFavorite(docId);
                              Navigator.of(ctx).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}