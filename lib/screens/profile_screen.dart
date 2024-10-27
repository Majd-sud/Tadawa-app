import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {
              // Add action for info button
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Account',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, color: Colors.blue, size: 30),
                ),
                title: const Text(
                  'Derek Powell',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: const Text(
                  'derek@gmail.com',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  // Add action for account section
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'General',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              shrinkWrap: true, // To fit within the SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Disable ListView scrolling
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    child: const Icon(Icons.nightlight_round, color: Colors.purple),
                  ),
                  title: const Text('Appearance'),
                  trailing: const Text('Light', style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    // Add functionality for appearance setting
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    child: const Icon(Icons.language, color: Colors.orange),
                  ),
                  title: const Text('Language'),
                  trailing: const Text('English', style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    // Add functionality for language setting
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.group, color: Colors.blue),
                  ),
                  title: const Text('Available users'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    // Add functionality for available users
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    child: const Icon(Icons.tune, color: Colors.green),
                  ),
                  title: const Text('Adjustment'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    // Add functionality for adjustment setting
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child: const Icon(Icons.logout, color: Colors.red),
                  ),
                  title: const Text('Logout'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
