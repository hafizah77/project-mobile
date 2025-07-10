import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/page/detailUserPage.dart';
import 'package:travel_app/page/widgets/bottomNavbar.dart';
import 'dart:ui'; // Diperlukan untuk efek blur

// KELAS ANIMASI BARU: Untuk menganimasikan kartu saat muncul
class _FadeInAnimation extends StatefulWidget {
  final int index;
  final Widget child;

  const _FadeInAnimation({required this.index, required this.child});

  @override
  State<_FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<_FadeInAnimation> {
  @override
  Widget build(BuildContext context) {
    // Menggunakan TweenAnimationBuilder untuk animasi yang sederhana dan efisien
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (widget.index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20), // Efek slide dari bawah
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> favoriteIds = [];
  String? userName;
  final String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // PALET WARNA BARU
  static const Color primaryColor = Color(0xFF00B2FF);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textColor = Color(0xFF343A40);

  @override
  void initState() {
    super.initState();
    loadUserData();
    insertDummyDataIfNeeded();
    _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- FUNGSI INTI (TIDAK ADA PERUBAHAN LOGIKA) ---
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        favoriteIds = prefs.getStringList('favorites') ?? [];
        userName = prefs.getString('user_name') ?? "Traveler";
      });
    }
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

  Future<void> insertDummyDataIfNeeded() async {
    final places = FirebaseFirestore.instance.collection('places');
    final snapshot = await places.limit(1).get();
    if (snapshot.docs.isEmpty) {
      final dummyDestinations = [
         {
          'name': 'Pantai Kuta',
          'location': 'Bali',
          'price': 50000,
          'category': 'Pantai',
          'description':
              'Pantai populer di Bali dengan pasir putih dan sunset yang indah.',
          'image_url':
              'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'created_at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Gunung Bromo',
          'location': 'Jawa Timur',
          'price': 150000,
          'category': 'Gunung',
          'description':
              'Gunung berapi aktif dengan pemandangan matahari terbit yang menakjubkan.',
          'image_url':
              'https://images.unsplash.com/photo-1596228723693-3e1a15f31323?q=80&w=1931&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'created_at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Raja Ampat',
          'location': 'Papua Barat',
          'price': 250000,
          'category': 'Pantai',
          'description':
              'Surga bawah laut Indonesia dengan keindahan terumbu karang dan laut biru.',
          'image_url':
              'https://images.unsplash.com/photo-1593453899331-537446162357?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'created_at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Candi Borobudur',
          'location': 'Jawa Tengah',
          'price': 75000,
          'category': 'Budaya',
          'description':
              'Candi Buddha terbesar di dunia, sebuah mahakarya arsitektur kuno.',
          'image_url':
              'https://images.unsplash.com/photo-1596422846543-75c651473449?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'created_at': FieldValue.serverTimestamp(),
        },
      ];
      for (final dest in dummyDestinations) {
        await places.add(dest);
      }
    }
  }
  // --- END OF FUNGSI INTI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Scaffold(
            backgroundColor: backgroundColor,
            extendBodyBehindAppBar: true,
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: _buildMainContent(),
            bottomNavigationBar: const BottomNavbar(currentIndex: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    Query placesQuery = FirebaseFirestore.instance.collection('places');
    if (_selectedCategory != 'Semua') {
      placesQuery = placesQuery.where('category', isEqualTo: _selectedCategory);
    }
    placesQuery = placesQuery.orderBy('created_at', descending: true);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeaderImageStack(),
        StreamBuilder<QuerySnapshot>(
          stream: placesQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator(color: primaryColor)),
              );
            }

            final allDocs = snapshot.data?.docs ?? [];
            final filteredDocs = _searchQuery.isEmpty
                ? allDocs
                : allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] as String? ?? '').toLowerCase();
                    return name.contains(_searchQuery.toLowerCase());
                  }).toList();

            if (filteredDocs.isEmpty) return _buildEmptyState();

            final popularDocs = filteredDocs.take(4).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_searchQuery.isEmpty && _selectedCategory == 'Semua') ...[
                  _buildSectionTitle('Populer 🔥'),
                  _buildPopularCarousel(popularDocs),
                ],
                _buildSectionTitle(_getDynamicTitle()),
                _buildAllDestinationsGrid(filteredDocs),
              ],
            );
          },
        ),
      ],
    );
  }

  String _getDynamicTitle() {
    if (_searchQuery.isNotEmpty) return 'Hasil Pencarian';
    return 'Rekomendasi Untukmu 🏝️';
  }

  Widget _buildHeaderImageStack() {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/travel.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: const Alignment(0.0, -0.2), // Gradient lebih pendek
                ),
              ),
            ),
          ),
           Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $userName 👋',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Temukan Surga\nTersembunyi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: [Shadow(blurRadius: 10.0, color: Colors.black54)],
                    ),
                  ),
                  const Spacer(),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari di Raja Ampat, Bromo...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildPopularCarousel(List<QueryDocumentSnapshot> docs) {
    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24, right: 9, bottom: 10),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          return _FadeInAnimation(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: _DestinationCard(
                doc: docs[index],
                isFavorite: favoriteIds.contains(docs[index].id),
                onFavoriteToggle: () => toggleFavorite(docs[index].id),
                width: 220,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllDestinationsGrid(List<QueryDocumentSnapshot> docs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: GridView.builder(
        itemCount: docs.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          return _FadeInAnimation(
            index: index,
            child: _DestinationCard(
              doc: docs[index],
              isFavorite: favoriteIds.contains(docs[index].id),
              onFavoriteToggle: () => toggleFavorite(docs[index].id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMsg) {
    // ... (Error state tetap sama, namun bisa di-style juga jika mau)
    return Center(child: Text('Terjadi kesalahan: $errorMsg'));
  }

  Widget _buildEmptyState() {
     return Container(
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'Destinasi Tidak Ditemukan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah kata kunci pencarian atau kategori.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final double? width;

  const _DestinationCard({
    required this.doc,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.width,
  });
  
  static const Color secondaryColor = Color(0xFF2D3A8C);

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailPage(data: data, docId: doc.id),
        ),
      ),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: (data['image_url'] != null && data['image_url'] != "")
                        ? Image.network(
                            data['image_url'],
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.broken_image, color: Colors.grey))),
                          )
                        : Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image, color: Colors.grey))),
                  ),
                   Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                             decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.25),
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFavorite ? Colors.redAccent : Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                     child: Text(
                      data['name'] ?? 'Tanpa Nama',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black87)]
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          data['location'] ?? 'Tanpa Lokasi',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rp ${data['price']?.toString() ?? '0'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}