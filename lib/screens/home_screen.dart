import 'package:bookreader/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/books_provider.dart';
import 'book_detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Reader'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, booksProvider),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, booksProvider),
          ),
        ],
      ),
      body: booksProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: booksProvider.books.length,
        itemBuilder: (ctx, index) => ListTile(
          onTap: () => Navigator.of(context).pushNamed(
            BookDetailScreen.routeName,
            arguments: booksProvider.books[index],
          ),
          title: Text(booksProvider.books[index].title),
          subtitle: Text(booksProvider.books[index].author),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushNamed(FavoritesScreen.routeName);
          } else if (index == 2) {
            Navigator.of(context).pushNamed(ProfileScreen.routeName);
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, BooksProvider booksProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Search Books'),
        content: TextField(
          onChanged: (query) => booksProvider.searchBooks(query),
          decoration: InputDecoration(hintText: 'Enter book title or author'),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, BooksProvider booksProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Filter Books'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              hint: Text('Select genre'),
              onChanged: (value) => booksProvider.filterBooks(genre: value),
              items: ['Fiction', 'Non-Fiction', 'Science'].map((genre) {
                return DropdownMenuItem(value: genre, child: Text(genre));
              }).toList(),
            ),
            Slider(
              value: booksProvider.minRating ?? 0.0,
              min: 0.0,
              max: 5.0,
              divisions: 5,
              label: 'Min Rating: ${booksProvider.minRating}',
              onChanged: (value) => booksProvider.filterBooks(minRating: value),
            ),
          ],
        ),
      ),
    );
  }
}