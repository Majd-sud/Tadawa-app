import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tadawa_app/screens/auth_screen.dart';
import 'package:tadawa_app/screens/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _currentUser;
  String _username = '';
  String _email = '';
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _email = user.email ?? '';
      });

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _username = userDoc['username'] ?? '';
          _imageUrl = userDoc['image_url'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionHeader('Account'),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage: _imageUrl.isNotEmpty
                            ? NetworkImage(_imageUrl)
                            : const AssetImage('assets/images/default_profile.jpg')
                                as ImageProvider,
                      ),
                      title: Text(
                        _username.isNotEmpty ? _username : 'User Name',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        _email.isNotEmpty ? _email : 'Email Address',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing:
                          const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildSectionHeader('General'),
                  _buildSettingsListTile(
                    icon: Icons.nightlight_round,
                    title: 'Appearance',
                    subtitle: 'Light',
                    iconColor: Colors.purple,
                    onTap: () {},
                  ),
                  _buildSettingsListTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    iconColor: Colors.orange,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildLogoutButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          radius: 24,
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 13))
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      },
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text(
        'Logout',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 67, 150, 86),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }
}