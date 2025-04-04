import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получение текущего пользователя
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Регистрация нового пользователя
  Future<UserCredential> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('This email is already registered. Please log in.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password is too weak. Use a stronger password.');
      } else {
        throw Exception('Failed to sign up: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Вход пользователя
  // Future<UserCredential> signIn(String email, String password) async {
  //   try {
  //     final userCredential = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return userCredential;
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       throw Exception('No user found with this email. Please register.');
  //     } else if (e.code == 'wrong-password') {
  //       throw Exception('Incorrect password. Please try again.');
  //     } else {
  //       throw Exception('Failed to sign in: ${e.message}');
  //     }
  //   } catch (e) {
  //     throw Exception('An unexpected error occurred: $e');
  //   }
  // }
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found with this email. Please register.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password. Please try again.');
      } else {
        throw Exception('Failed to sign in: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  // Выход пользователя
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Проверка, авторизован ли пользователь
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}