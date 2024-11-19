import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tadawa_app/widgets/profile_image.dart';
import 'package:tadawa_app/generated/l10n.dart';

final _firebase = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  var _username = '';
  var _firstName = '';
  var _lastName = '';
  var _phone = '';
  var _email = '';
  var _imageUrl = '';
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    User? user = _firebase.currentUser;
    if (user == null) {
      print("No user is logged in.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      print("Fetched user document: ${userDoc.data()}");
      if (userDoc.exists) {
        setState(() {
          _username = userDoc['username'] ?? '';
          _firstName = userDoc['firstName'] ?? '';
          _lastName = userDoc['lastName'] ?? '';
          _phone = userDoc['phone'] ?? '';
          _email = userDoc['email'] ?? '';
          _imageUrl = userDoc['image_url'] ?? '';
        });
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).errorFetchingUserData)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    User? user = _firebase.currentUser;
    if (user != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? imageUrl;
        if (_selectedImage != null) {
          final imageRef =
              _storage.ref().child('user_images').child('${user.uid}.jpg');
          await imageRef.putFile(_selectedImage!);
          imageUrl = await imageRef.getDownloadURL();
        }

        await _firestore.collection('users').doc(user.uid).update({
          'username': _username,
          'firstName': _firstName,
          'lastName': _lastName,
          'phone': _phone,
          'email': _email,
          'image_url':
              imageUrl ?? _imageUrl, // Use existing image URL if no new image
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).profileUpdated)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).errorUpdatingProfile)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _pickImage(File pickedImage) {
    setState(() {
      _selectedImage = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 255, 254, 247),
      child: Column(children: [
        const SizedBox(height: 20),
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromRGBO(255, 254, 247, 255),
              title: Text(S.of(context).profile),
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          ProfileImage(
                            onPickImage: _pickImage,
                            initialImageUrl: _imageUrl,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            initialValue: _username,
                            decoration: InputDecoration(
                              labelText: S.of(context).username,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _username = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).pleaseEnterUsername;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            initialValue: _firstName,
                            decoration: InputDecoration(
                              labelText: S.of(context).firstName,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _firstName = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).pleaseEnterFirstName;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            initialValue: _lastName,
                            decoration: InputDecoration(
                              labelText: S.of(context).lastName,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _lastName = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).pleaseEnterLastName;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            initialValue: _phone,
                            decoration: InputDecoration(
                              labelText: S.of(context).phone,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (value) {
                              _phone = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).pleaseEnterPhoneNumber;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            initialValue: _email,
                            decoration: InputDecoration(
                              labelText: S.of(context).email,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              _email = value;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@')) {
                                return S.of(context).pleaseEnterValidEmail;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_form.currentState!.validate()) {
                                _updateUserData();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: const Color.fromARGB(
                                  255, 46, 161, 132), // Background color
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            child: Text(
                              S.of(context).updateProfile,
                              style: const TextStyle(
                                  color: Colors.white), // Text color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ]),
    );
  }
}
