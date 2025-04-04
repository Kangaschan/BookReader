import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/user.dart'; // Импортируем модель пользователя
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/Authentication';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                value!.length < 6 ? 'Minimum 6 characters' : null,
              ),
              if (!_isLogin) ...[
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) =>
                  !_isLogin && value!.isEmpty ? 'Enter first name' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) =>
                  !_isLogin && value!.isEmpty ? 'Enter last name' : null,
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isLogin ? 'Login' : 'Sign Up'),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                    _isLogin ? 'Create account' : 'Already have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (_isLogin) {
          await auth.signIn(_emailController.text, _passwordController.text);
        } else {
          // Создаем объект UserModel для регистрации
          final newUser = UserModel(
            uid: '', // Будет установлен после регистрации
            email: _emailController.text,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            registrationDate: DateTime.now(),
            favorites: [],
          );
          await auth.signUp(
            _emailController.text,
            _passwordController.text,
            newUser,
          );
        }
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}