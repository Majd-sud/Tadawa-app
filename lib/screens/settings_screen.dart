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
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 254, 247, 255),
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: const Color.fromRGBO(247, 242, 250, 1),
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
                            : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
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
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const Text('Preferences', style: TextStyle(fontSize: 20)),
                  _buildSettingsListTile(
                    icon: Icons.nightlight_round,
                    title: 'Appearance',
                    subtitle: 'Light',
                    iconColor: const Color.fromARGB(255, 134, 134, 134),
                    onTap: () {},
                  ),
                  _buildSettingsListTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                    iconColor: const Color.fromARGB(255, 134, 134, 134),
                    onTap: () {},
                  ),
                  _buildSettingsListTile(
                    icon: Icons.notifications,
                    title: 'Notification',
                    subtitle: 'Manage notifications',
                    iconColor: const Color.fromARGB(255, 134, 134, 134),
                    onTap: () {
                      _showNotificationDialog();
                    },
                  ),
                  const SizedBox(height: 16), // Add space between Preferences and Logout
                  Center(child: _buildLogoutButton(context)), // Center the button
                ],
              ),
            ),
          ),
        ],
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
      color: const Color.fromRGBO(247, 242, 250, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
            ? Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13))
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
        backgroundColor: Colors.redAccent, // Softer red color
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(247, 242, 250, 1), // Light background color
          title: const Text(
            'Notification Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  'Please make sure to open:\n',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Settings > Apps > Tadawa App > Notifications > Allow',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8), // Add space between lines
                Text(
                  'Settings > Apps > Tadawa App > Alarms & reminders > Allow',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 46, 161, 132), // Custom color for the button
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}