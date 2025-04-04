import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/user.dart';
import 'auth_provider.dart';

class FavoritesProvider with ChangeNotifier {
  List<String> get favorites =>
      Provider.of<AuthProvider>(context, listen: false).user?.favorites ?? [];

  BuildContext context;

  FavoritesProvider(this.context);

  Future<void> toggleFavorite(String bookId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final newFavorites = List<String>.from(user.favorites ?? []);
    if (newFavorites.contains(bookId)) {
      newFavorites.remove(bookId);
    } else {
      newFavorites.add(bookId);
    }

    final updatedUser = user.copyWith(favorites: newFavorites);
    await authProvider.updateProfile(updatedUser);
  }

  bool isFavorite(String bookId) {
    return favorites.contains(bookId);
  }
}