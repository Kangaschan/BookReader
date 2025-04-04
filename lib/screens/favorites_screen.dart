import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/books_provider.dart';
import '../providers/favorites_provider.dart';
import 'book_detail_screen.dart';

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
        itemBuilder: (ctx, index) => Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: ListTile(
              leading: favoriteBooks[index].images.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  favoriteBooks[index].images.first,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image),
                ),
              )
                  : SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.book, size: 30)),
              title: Text(favoriteBooks[index].title),
              subtitle: Text(favoriteBooks[index].author),
              trailing: IconButton(
                icon: Icon(Icons.favorite, color: Colors.red),
                onPressed: () => favoritesProvider.toggleFavorite(favoriteBooks[index].id),
              ),
              onTap: () => Navigator.of(context).pushNamed(
                BookDetailScreen.routeName,
                arguments: favoriteBooks[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}