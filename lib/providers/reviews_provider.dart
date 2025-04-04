import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../model/review.dart';

class ReviewsProvider with ChangeNotifier{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview({
    required String bookId,
    required String userId,
    required String userName,
    required String text,
    required double rating,
  }) async {
    final reviewRef = _firestore.collection('reviews').doc();

    final review = Review(
      id: reviewRef.id,
      userId: userId,
      bookId: bookId,
      userName: userName,
      text: text,
      rating: rating,
      createdAt: DateTime.now(),
    );

    await reviewRef.set(review.toMap());

    // Обновляем средний рейтинг книги
    await _updateBookRating(bookId);
  }

  Future<void> deleteReview(String reviewId) async {
    final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
    final bookId = reviewDoc.data()?['bookId'] as String;

    await _firestore.collection('reviews').doc(reviewId).delete();

    // Обновляем средний рейтинг книги
    await _updateBookRating(bookId);
  }

  Future<void> _updateBookRating(String bookId) async {
    final reviewsSnapshot = await _firestore
        .collection('reviews')
        .where('bookId', isEqualTo: bookId)
        .get();

    if (reviewsSnapshot.docs.isEmpty) {
      await _firestore.collection('books').doc(bookId).update({
        'averageRating': 0,
        'reviews': FieldValue.arrayRemove(reviewsSnapshot.docs.map((e) => e.id).toList()),
      });
      return;
    }

    double totalRating = 0;
    for (var doc in reviewsSnapshot.docs) {
      totalRating += (doc.data()['rating'] as num).toDouble();
    }

    final averageRating = totalRating / reviewsSnapshot.docs.length;

    await _firestore.collection('books').doc(bookId).update({
      'averageRating': averageRating,
      'reviews': reviewsSnapshot.docs.map((e) => e.id).toList(),
    });
  }
}