import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/books_provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  static const routeName = '/favorites';

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final booksProvider = Provider.of<BooksProvider>(context);

    final favoriteBooks = booksProvider.books
        .where((book) => favoritesProvider.isFavorite(book.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: ListView.builder(
        itemCount: favoriteBooks.length,
        itemBuilder: (ctx, index) => ListTile(
          title: Text(favoriteBooks[index].title),
          subtitle: Text(favoriteBooks[index].author),
        ),
      ),
    );
  }
}