import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/books_provider.dart';
import '../providers/auth_provider.dart';
import 'book_detail_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void>? _booksFuture;

  @override
  void initState() {
    super.initState();
    // Отложим инициализацию до первого построения
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _loadBooks();
    });
  }

  void _loadBooks() {
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    setState(() {
      _booksFuture = booksProvider.loadBooks();
    });
  }

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
      body: _buildBody(booksProvider),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody(BooksProvider booksProvider) {
    if (_booksFuture == null) {
      return Center(child: CircularProgressIndicator());
    }

    return FutureBuilder(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading books'));
        }

        return ListView.builder(
          itemCount: booksProvider.books.length,
          itemBuilder: (ctx, index) => _buildBookItem(booksProvider, index),
        );
      },
    );
  }

  Widget _buildBookItem(BooksProvider booksProvider, int index) {
    final book = booksProvider.books[index];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        leading: book.images.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            book.images.first,
            width: 60,
            height: 90,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(
                  width: 60,
                  height: 90,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: 30),
                ),
          ),
        )
            : Container(
          width: 60,
          height: 90,
          color: Colors.grey[200],
          child: Icon(Icons.book, size: 30),
        ),
        title: Text(
          book.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.author),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  book.averageRating.toStringAsFixed(1),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        onTap: () => Navigator.of(context).pushNamed(
          BookDetailScreen.routeName,
          arguments: book,
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
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
              value: booksProvider.selectedGenre,
              onChanged: (value) => booksProvider.filterBooks(genre: value),
              items: ['All', 'Fiction', 'Non-Fiction', 'Science Fiction', 'Mystery']
                  .map((genre) => DropdownMenuItem(value: genre, child: Text(genre)))
                  .toList(),
            ),
                  ],
        ),
      ),
    );
  }
}