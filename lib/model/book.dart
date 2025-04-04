import 'package:bookreader/model/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String genre;
  final List<String> images;
  final double averageRating;
  final List<String> reviews;


  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.genre,
    required this.images,
    this.averageRating = 0.0,
    this.reviews = const [],
  });

  // Преобразование из Firestore DocumentSnapshot в объект Book
  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? 'Unknown Title',
      author: data['author'] ?? 'Unknown Author',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviews: List<String>.from(data['reviews'] ?? []), // Просто int
      genre: data['genre'] ?? 'Unknown', // Извлекаем жанр из Firestore
    );
  }
  factory Book.fromFirestoreMap(Map<String, dynamic> data, {String? id}) {

    return Book(
      id: id ?? data['id'] ?? '',
      title: data['title'] ?? 'Unknown Title',
      author: data['author'] ?? 'Unknown Author',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviews: List<String>.from(data['reviews'] ?? []), // Просто int
      genre: data['genre'] ?? 'Unknown',
    );
  }
  // Преобразование объекта Book в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'images': images,
      'averageRating': averageRating,
      'reviews': reviews,
      'genre': genre, // Добавляем жанр в Firestore
    };
  }
}