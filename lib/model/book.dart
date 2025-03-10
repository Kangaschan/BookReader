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
  final List<Review> reviews;


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
      genre: data['genre'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviews: (data['reviews'] as List<dynamic>?)
          ?.map((review) => Review.fromMap(review))
          .toList() ??
          [],
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
      'reviews': reviews.map((review) => review.toMap()).toList(),
    };
  }
}