import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel _editedUser;
  late bool _isEditing;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _selectedBirthDate;
  Map<String, String> _bookTitles = {};
  @override
  void initState() {
    super.initState();
    _isEditing = false;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
// Метод для загрузки названий книг
  Future<void> _loadBookTitles(List<String>? bookIds) async {
    if (bookIds == null || bookIds.isEmpty) return;

    final books = await FirebaseFirestore.instance
        .collection('books')
        .where(FieldPath.documentId, whereIn: bookIds)
        .get();

    setState(() {
      _bookTitles = {
        for (var doc in books.docs) doc.id: doc.data()['title'] as String
      };
    });
  }
  void _startEditing(UserModel user) {
    setState(() {
      _isEditing = true;
      _editedUser = user.copyWith();
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address?.join('\n') ?? '';
      _selectedBirthDate = user.birthDateAsDateTime;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _saveChanges(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedUser = _editedUser.copyWith(
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: _addressController.text.isNotEmpty
            ? _addressController.text.split('\n')
            : null,
        birthDate: _selectedBirthDate != null
            ? Timestamp.fromDate(_selectedBirthDate!)
            : null,
      );

      try {
        await authProvider.updateUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() {
          _isEditing = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $error')),
        );
      }
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          if (user != null && !_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _startEditing(user),
            ),
          if (user != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await authProvider.signOut();
                Navigator.of(context).pushReplacementNamed('/Authentication');
              },
            ),
        ],
      ),
      body: user != null
          ? _isEditing ? _buildEditForm(user, authProvider) : _buildProfile(user)
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You are not logged in'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/Authentication');
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(UserModel user) {
    if (user.favorites != null && user.favorites!.isNotEmpty) {
      _loadBookTitles(user.favorites);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
              user.profileImage != null ? NetworkImage(user.profileImage!) : null,
              child: user.profileImage == null ? Icon(Icons.person, size: 50) : null,
            ),
          ),
          SizedBox(height: 20),
          _buildProfileItem('Name', user.fullName),
          _buildProfileItem('Email', user.email),
          if (user.phone != null && user.phone!.isNotEmpty)
            _buildProfileItem('Phone', user.phone!),
          if (user.birthDate != null)
            _buildProfileItem(
                'Birth Date',
                DateFormat('dd.MM.yyyy').format(user.birthDateAsDateTime!)),
          if (user.gender != null)
            _buildProfileItem('Gender', user.gender! ? 'Male' : 'Female'),
          if (user.address != null && user.address!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Address'),
                ...user.address!.map((addressLine) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(addressLine),
                )).toList(),
              ],
            ),
          SizedBox(height: 16),
          _buildSectionTitle('Favorite Books (${user.favorites?.length ?? 0})'),
          if (user.favorites?.isEmpty ?? true)
            Text('No favorite books yet',
                style: TextStyle(color: Colors.grey)),
          if (user.favorites != null && user.favorites!.isNotEmpty)
            Column(
              children: user.favorites!
                  .map((bookId) => ListTile(
                leading: Icon(Icons.book),
                title: Text(_bookTitles[bookId] ?? 'Loading...'),
                subtitle: Text('ID: $bookId'),
              ))
                  .toList(),
            ),
          SizedBox(height: 20),
          _buildProfileItem(
              'Registration Date',
              DateFormat('dd.MM.yyyy HH:mm').format(user.registrationDate)),
          if (user.lastLogin != null)
            _buildProfileItem(
                'Last Login',
                DateFormat('dd.MM.yyyy HH:mm')
                    .format(user.lastLoginAsDateTime)),
        ],
      ),
    );
  }

  Widget _buildEditForm(UserModel user, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            _buildProfileItem('Name', user.fullName),
            _buildProfileItem('Email', user.email),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value!.isNotEmpty && !RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
                    .hasMatch(value)) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
              onSaved: (value) {
                _editedUser = _editedUser.copyWith(firstName: value);
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
              onSaved: (value) {
                _editedUser = _editedUser.copyWith(lastName: value);
              },
            ),
            SizedBox(height: 16),

            SizedBox(height: 16),
            InkWell(
              onTap: () => _selectBirthDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Birth Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedBirthDate != null
                      ? DateFormat('dd.MM.yyyy').format(_selectedBirthDate!)
                      : 'Select birth date',
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<bool>(
              value: _editedUser.gender,
              decoration: InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: [
                DropdownMenuItem(
                  value: true,
                  child: Text('Male'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('Female'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _editedUser = _editedUser.copyWith(gender: value);
                });
              },
              validator: (value) {
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address (one line per address)',
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 3,
              validator: (value) {
                return null;
              },
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _cancelEditing,
                  child: Text('Cancel'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _saveChanges(authProvider),
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}