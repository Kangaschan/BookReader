import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../model/user.dart'; // Ваш класс User (UserModel)
import '../services/firebase_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _userModel;
  User? get firebaseUser => _authService.getCurrentUser();
  UserModel? get user => _userModel;

  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signIn(email, password);
      await _loadUserData();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password, UserModel newUser) async {
    try {
      await _authService.signUp(email, password);
      newUser = newUser.copyWith(
        uid: firebaseUser!.uid,
        email: email,
        registrationDate: DateTime.now(),
      );
      await _firestore.collection('users').doc(firebaseUser!.uid).set(newUser.toMap());
      _userModel = newUser;
      notifyListeners();
    } catch (e) {
      throw e;
    }

  }

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.uid)
          .update(updatedUser.toMap());
      _userModel = updatedUser;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> _loadUserData() async {
    if (firebaseUser == null) return;

    final doc = await _firestore.collection('users').doc(firebaseUser!.uid).get();
    if (doc.exists) {
      _userModel = UserModel.fromMap(doc.data()!);
    } else {
      // Создаем запись, если пользователь есть в Auth, но нет в Firestore
      _userModel = UserModel(
        uid: firebaseUser!.uid,
        email: firebaseUser!.email ?? '',
        registrationDate: DateTime.now(),
      );
      await _firestore.collection('users').doc(firebaseUser!.uid).set(_userModel!.toMap());
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _userModel = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    await _firestore.collection('users').doc(firebaseUser!.uid).update(updatedUser.toMap());
    _userModel = updatedUser;
    notifyListeners();
  }
}