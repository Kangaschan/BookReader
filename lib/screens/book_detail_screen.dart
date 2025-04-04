import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/book.dart';
import '../model/review.dart';
import '../providers/auth_provider.dart';
import '../providers/books_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/reviews_provider.dart';

class BookDetailScreen extends StatefulWidget {
  static const routeName = '/book-detail';

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _reviewController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as Book;
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final reviewsProvider = Provider.of<ReviewsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Создаем stream для отзывов вне builder, чтобы избежать пересоздания
    final reviewsStream = FirebaseFirestore.instance
        .collection('reviews')
        .where('bookId', isEqualTo: book.id)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Принудительное обновление для тестирования
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Секция с изображениями книги
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: book.images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        book.images[index],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.broken_image, size: 100),
                        ),
                      );
                    },
                  ),
                  if (book.images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(
                          book.images.length,
                              (index) => Container(
                            width: 8,
                            height: 8,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(
                                  _pageController.hasClients &&
                                      _pageController.page?.round() ==
                                          index
                                      ? 0.9
                                      : 0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Основная информация о книге
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(book.author, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  SizedBox(height: 12),

                  // Рейтинг книги
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${book.averageRating.toStringAsFixed(1)}/5',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Описание книги
                  Text(
                    book.description,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 24),

                  // Кнопка добавления в избранное
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: favoritesProvider.isFavorite(book.id)
                              ? Colors.red
                              : Colors.grey,
                          size: 28,
                        ),
                        onPressed: () {
                          if (user != null) {
                            favoritesProvider.toggleFavorite(book.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please login to add favorites')),
                            );
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add to favorites',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Divider(height: 32),

                  // Форма добавления отзыва (только для авторизованных)
                  if (user != null) ...[
                    Text(
                      'Write a review:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),

                    // Выбор рейтинга
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 16),

                    // Текстовое поле для отзыва
                    TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts about this book...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: 4,
                      minLines: 3,
                    ),
                    SizedBox(height: 16),

                    // Кнопка отправки
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (_rating == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please select a rating')),
                            );
                            return;
                          }

                          if (_reviewController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please write a review')),
                            );
                            return;
                          }

                          try {
                            await reviewsProvider.addReview(
                              bookId: book.id,
                              userId: user.uid,
                              userName: user.fullName,
                              text: _reviewController.text.trim(),
                              rating: _rating.toDouble(),
                            );

                            _reviewController.clear();
                            setState(() {
                              _rating = 0;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Review added successfully')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add review: $e')),
                            );
                          }
                        },
                        child: Text(
                          'Submit Review',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    Divider(height: 40),
                  ],

                  // Секция с отзывами
                  Text(
                    'Reviews:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  // StreamBuilder для отзывов
                  StreamBuilder<QuerySnapshot>(
                    stream: reviewsStream,
                    builder: (context, snapshot) {
                      // Обработка состояния загрузки
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      // Обработка ошибок
                      if (snapshot.hasError) {
                        return Text(
                          'Error loading reviews: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      // Проверка наличия данных
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No reviews yet. Be the first to review this book!',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }

                      // Преобразование данных
                      final reviews = snapshot.data!.docs.map((doc) {
                        try {
                          return Review.fromMap({
                            ...doc.data() as Map<String, dynamic>,
                            'id': doc.id, // Добавляем ID документа
                          });
                        } catch (e) {
                          print('Error parsing review ${doc.id}: $e');
                          return null;
                        }
                      }).whereType<Review>().toList();

                      // Отображение списка отзывов
                      return ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: reviews.length,
                        separatorBuilder: (context, index) => SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Заголовок отзыва (имя и дата)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review.userName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('MMM d, yyyy').format(review.createdAt),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),

                                  // Рейтинг
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < review.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 18,
                                      );
                                    }),
                                  ),
                                  SizedBox(height: 12),

                                  // Текст отзыва
                                  Text(
                                    review.text,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 12),

                                  // Кнопка удаления (только для своих отзывов)
                                  if (review.userId == user?.uid)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        icon: Icon(Icons.delete, size: 18),
                                        label: Text('Delete'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        onPressed: () async {
                                          try {
                                            await reviewsProvider.deleteReview(review.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Review deleted')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to delete review')),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}