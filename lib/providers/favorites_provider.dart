import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _favoritesCollection = 'favorites';
  Map<String, bool> _favorites = {};

  Map<String, bool> get favorites => _favorites;

  Future<void> loadFavorites(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection(_favoritesCollection)
          .get();
      _favorites = {for (var doc in snapshot.docs) doc.id: true};
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to load favorites: $error');
    }
  }

  bool isFavorite(String bookId) => _favorites.containsKey(bookId);

  Future<void> toggleFavorite(String userId, String bookId) async {
    try {
      if (_favorites.containsKey(bookId)) {
        await _db
            .collection('users')
            .doc(userId)
            .collection(_favoritesCollection)
            .doc(bookId)
            .delete();
        _favorites.remove(bookId);
      } else {
        await _db
            .collection('users')
            .doc(userId)
            .collection(_favoritesCollection)
            .doc(bookId)
            .set({});
        _favorites[bookId] = true;
      }
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to toggle favorite: $error');
    }
  }
}