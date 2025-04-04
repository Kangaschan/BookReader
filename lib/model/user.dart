import 'package:cloud_firestore/cloud_firestore.dart';

  class UserModel {
  final String uid;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final Timestamp? birthDate;
  final bool? gender; // Исправлено с Bool на bool
  final DateTime registrationDate;
  final DateTime? lastLogin;
  final String? profileImage;
  final List<String>? address;
  final List<String>? favorites;

  UserModel({
    required this.uid,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.birthDate,
    this.gender,
    required this.registrationDate,
    this.lastLogin,
    this.profileImage,
    this.address,
    this.favorites,
  });

  // Конвертация в Map для Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'birthDate': birthDate,
      'gender': gender,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'profileImage': profileImage,
      'address': address,
      'favorites': favorites,
    };
  }

  // Создание User из Firebase-документа
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      phone: map['phone'] as String?,
      birthDate: map['birthDate'] as Timestamp?,
      gender: map['gender'] as bool?,
      registrationDate: (map['registrationDate'] as Timestamp).toDate(),
      lastLogin: map['lastLogin'] != null ? (map['lastLogin'] as Timestamp).toDate() : null,
      profileImage: map['profileImage'] as String?,
      address: map['address'] != null ? List<String>.from(map['address']) : null,
      favorites: map['favorites'] != null ? List<String>.from(map['favorites']) : null,
    );
  }

  // Копирование с изменениями
  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    Timestamp? birthDate,
    bool? gender,
    DateTime? registrationDate,
    DateTime? lastLogin,
    String? profileImage,
    List<String>? address,
    List<String>? favorites,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      registrationDate: registrationDate ?? this.registrationDate,
      lastLogin: lastLogin ?? this.lastLogin,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      favorites: favorites ?? this.favorites,
    );
  }

  // Дополнительные геттеры для удобства
  DateTime? get birthDateAsDateTime => birthDate?.toDate();
  DateTime get lastLoginAsDateTime => lastLogin ?? registrationDate;
  String get fullName => [firstName, lastName].where((n) => n != null).join(' ');
}