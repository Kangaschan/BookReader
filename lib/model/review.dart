import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String bookId;
  final String userName;
  final String text;
  final double rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.userName,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  // Преобразование из Firestore Map в объект Review
  factory Review.fromMap(Map<String, dynamic> data) {
    return Review(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      text: data['text'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Преобразование объекта Review в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'userName': userName,
      'text': text,
      'rating': rating,
      'createdAt': createdAt,
    };
  }
}