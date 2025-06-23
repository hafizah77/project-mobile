import 'package:flutter/material.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;

  void toggleFavorite(String docId) {
    if (_favoriteIds.contains(docId)) {
      _favoriteIds.remove(docId);
    } else {
      _favoriteIds.add(docId);
    }
    notifyListeners();
  }

  bool isFavorite(String docId) => _favoriteIds.contains(docId);
}
