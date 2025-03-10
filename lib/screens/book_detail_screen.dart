import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/book.dart';
import '../providers/auth_provider.dart';
import '../providers/books_provider.dart';
import '../providers/favorites_provider.dart';

class BookDetailScreen extends StatelessWidget {
  static const routeName = '/book-detail';

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as Book;
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final booksProvider = Provider.of<BooksProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(book.images.isNotEmpty ? book.images.first : ''),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: TextStyle(fontSize: 24)),
                  Text(book.author, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  Text(book.description),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: favoritesProvider.isFavorite(book.id)
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () {
                          final user = Provider.of<AuthProvider>(context, listen: false).user;
                          if (user != null) {
                            favoritesProvider.toggleFavorite(user.uid, book.id);
                          }
                        },
                      ),
                      Text('Add to favorites'),
                    ],
                  ),
                  Divider(),
                  Text('Reviews:'),
                  // Отзывы можно отобразить здесь
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}