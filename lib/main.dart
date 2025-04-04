import 'package:bookreader/screens/book_detail_screen.dart';
import 'package:bookreader/screens/favorites_screen.dart';
import 'package:bookreader/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bookreader/screens/auth_screen.dart';
import 'package:bookreader/screens/home_screen.dart';
import 'package:bookreader/providers/auth_provider.dart';
import 'package:bookreader/providers/books_provider.dart';
import 'package:bookreader/providers/favorites_provider.dart';
import 'package:bookreader/providers/reviews_provider.dart';

import 'model/book.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализация Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BooksProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider(context)),
        ChangeNotifierProvider(create: (_) => ReviewsProvider()),

      ],
      child: MaterialApp(
        title: 'Book Reader',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            // Если пользователь авторизован, показываем HomeScreen, иначе AuthScreen
            return auth.user != null ? HomeScreen() : AuthScreen();
          },
        ),
        routes: {
          HomeScreen.routeName: (ctx) => HomeScreen(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
          FavoritesScreen.routeName: (ctx) => FavoritesScreen(),
          ProfileScreen.routeName: (ctx) => ProfileScreen(),
          BookDetailScreen.routeName: (ctx) => BookDetailScreen(),
        },
      ),
    );
  }
}