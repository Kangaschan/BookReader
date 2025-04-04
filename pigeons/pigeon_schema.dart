import 'package:pigeon/pigeon.dart';

class UserDetails {
  String? userId;
  String? email;
}

@HostApi()
abstract class AuthApi {
  UserDetails? getCurrentUser();
  void signIn(String email, String password);
  void signOut();
}