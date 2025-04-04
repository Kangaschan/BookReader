import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/book.dart';
import '../model/review.dart';

class BooksProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _booksCollection = 'books';
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = false;
  double? _minRating;
  String? _selectedGenre; // Новое поле для выбранного жанра

  List<Book> get books => _filteredBooks.isEmpty ? _books : _filteredBooks;
  bool get isLoading => _isLoading;
  double? get minRating => _minRating;
  String? get selectedGenre => _selectedGenre; // Геттер для выбранного жанра

  Future<void> loadBooks() async {
    try {
      print('Loading books...');
      _isLoading = true;
      notifyListeners();

      QuerySnapshot querySnapshot;

      try {
        querySnapshot = await _firestore
            .collection(_booksCollection)
            .orderBy('title')
            .get(const GetOptions(source: Source.server));
      } catch (e) {
        querySnapshot = await _firestore
            .collection(_booksCollection)
            .orderBy('title')
            .get(const GetOptions(source: Source.cache));
      }

      _books.clear(); // Очищаем список перед загрузкой новых данных

      for (var doc in querySnapshot.docs) {

        final data = doc.data() as Map<String, dynamic>; // Явное привение типа

        try {

          _books.add(Book.fromFirestore(doc as DocumentSnapshot<Object?>)); // Передаем data, а не doc
        } catch (e) {
          print('Error parsing book ${doc.id}: $e');
        }
      }

      _filteredBooks = [];
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      print('Error loading books: $error');
      throw Exception('Failed to load books: $error');
    }
  }
  // Future<void> loadBooks() async {
  //   try {
  //     print('Loading books...');
  //     _isLoading = true;
  //     print('Books loaded: ${_books.length}');
  //     for (var book in _books) {
  //       print('Book title: ${book.title}, Author: ${book.author}');
  //     }
  //     notifyListeners();
  //
  //     QuerySnapshot querySnapshot;
  //
  //     try {
  //       querySnapshot = await _firestore
  //           .collection(_booksCollection)
  //           .orderBy('title')
  //           .get(const GetOptions(source: Source.server));
  //     } catch (e) {
  //       querySnapshot = await _firestore
  //           .collection(_booksCollection)
  //           .orderBy('title')
  //           .get(const GetOptions(source: Source.cache));
  //     }
  //
  //     for (var doc in querySnapshot.docs) {
  //       final rawData = doc.data();
  //       print('Raw data from Firestore: $rawData');
  //
  //       if (rawData is Map<String, dynamic>) {
  //         _books.add(Book.fromFirestore(doc));
  //       } else {
  //         print('Invalid data format for document ID: ${doc.id}');
  //       }
  //     }
  //
  //     _filteredBooks = [];
  //     _isLoading = false;
  //     notifyListeners();
  //   } catch (error) {
  //     _isLoading = false;
  //     notifyListeners();
  //     print('Error loading books: $error');
  //     throw Exception('Failed to load books: $error');
  //   }
  // }

  void searchBooks(String query) {
    if (query.isEmpty) {
      _filteredBooks = [];
    } else {
      _filteredBooks = _books.where((book) {
        final lowerQuery = query.toLowerCase();
        return book.title.toLowerCase().contains(lowerQuery) ||
            book.author.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  void filterBooks({String? genre, double? minRating}) {
    _minRating = minRating;
    _filteredBooks = _books.where((book) {
      bool matches = true;

      if (genre != null && genre.isNotEmpty) {
        matches &= book.genre == genre;
      }

      if (minRating != null) {
        matches &= book.averageRating >= minRating;
      }

      return matches;
    }).toList();
    notifyListeners();
  }

  // Очистка фильтров
  void clearFilters() {
    _minRating = null; // Сбрасываем минимальный рейтинг
    _filteredBooks = [];
    notifyListeners();
  }

  Future<void> addReview(String bookId, String text, double rating) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      }

      final reviewId = FirebaseFirestore.instance.collection('reviews').doc().id;

      final review = Review(
        id: reviewId, // Теперь это String
        userId: user.uid,
        bookId: bookId,
        userName: user.displayName ?? 'Anonymous', // Используем имя пользователя
        text: text,
        rating: rating,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_booksCollection)
          .doc(bookId)
          .collection('reviews')
          .doc(reviewId)
          .set(review.toMap());

      await _updateBookRating(bookId);
    } catch (error) {
      throw Exception('Failed to add review: $error');
    }
  }

  Future<void> _updateBookRating(String bookId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection(_booksCollection)
          .doc(bookId)
          .collection('reviews')
          .get();

      final ratings = reviewsSnapshot.docs.map((doc) {
        final data = doc.data();
        return (data['rating'] as num?)?.toDouble() ?? 0.0;
      }).toList();

      final averageRating =
      ratings.isNotEmpty ? ratings.reduce((a, b) => a + b) / ratings.length : 0.0;

      await _firestore
          .collection(_booksCollection)
          .doc(bookId)
          .update({'averageRating': averageRating});
    } catch (error) {
      throw Exception('Failed to update book rating: $error');
    }
  }
}