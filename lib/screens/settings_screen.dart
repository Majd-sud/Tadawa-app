import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tadawa_app/generated/l10n.dart';
import 'package:tadawa_app/screens/auth_screen.dart';
import 'package:tadawa_app/screens/profile_screen.dart';
import 'package:tadawa_app/theme.dart';
import '../theme_providor.dart';

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
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe to access Localizations.localeOf(context) here
    _currentLocale ??= Localizations.localeOf(context);
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

  void _changeLanguage(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
    // Notify the localization package of the locale change
    S.load(locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 254, 247, 255),
        title: Text(S.of(context).title),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Consumer<ThemeProvidor>(
                builder: (context, value, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: value.themeData == lightMode
                          ? const Color.fromRGBO(247, 242, 250, 1)
                          : Colors.blueGrey.shade800,
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
                              : const AssetImage(
                                      'assets/images/default_profile.jpg')
                                  as ImageProvider,
                        ),
                        title: Text(
                          _username.isNotEmpty
                              ? _username
                              : S.of(context).defaultUserName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: value.themeData == lightMode
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          _email.isNotEmpty
                              ? _email
                              : S.of(context).defaultEmailAddress,
                          style: TextStyle(
                            color: value.themeData == lightMode
                                ? Colors.black87
                                : Colors.white,
                          ),
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
                    Text(S.of(context).preferences,
                        style: const TextStyle(fontSize: 20)),
                    _buildSettingsListTile(
                      icon: Icons.nightlight_round,
                      title: S.of(context).appearance,
                      subtitle: themeSubtitle(context),
                      iconColor: const Color.fromARGB(255, 134, 134, 134),
                      onTap: () {
                        context.read<ThemeProvidor>().toggleTheme();
                      },
                    ),
                    _buildSettingsListTile(
                      icon: Icons.language,
                      title: S.of(context).language,
                      subtitle: _currentLocale?.languageCode == 'en'
                          ? 'English'
                          : 'العربية',
                      iconColor: const Color.fromARGB(255, 134, 134, 134),
                      onTap: () {
                        _showLanguageDialog(context);
                      },
                    ),
                    _buildSettingsListTile(
                      icon: Icons.notifications,
                      title: S.of(context).notification,
                      subtitle: S.of(context).manageNotifications,
                      iconColor: const Color.fromARGB(255, 134, 134, 134),
                      onTap: () {
                        _showNotificationDialog();
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(child: _buildLogoutButton(context)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  _changeLanguage(const Locale('en'));
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              ListTile(
                title: const Text('العربية'),
                onTap: () {
                  _changeLanguage(const Locale('ar'));
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Consumer<ThemeProvidor>(
      builder: (context, value, child) {
        return Card(
          color: value.themeData == lightMode
              ? const Color.fromRGBO(247, 242, 250, 1)
              : Colors.blueGrey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            leading: CircleAvatar(
              backgroundColor: value.themeData == lightMode
                  ? iconColor.withOpacity(0.15)
                  : Colors.white,
              radius: 24,
              child: Icon(icon, color: iconColor, size: 22),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: value.themeData == lightMode
                    ? Colors.black87
                    : Colors.white,
              ),
            ),
            subtitle: subtitle != null
                ? Text(subtitle,
                    style: TextStyle(
                      color: value.themeData == lightMode
                          ? Colors.black87
                          : Colors.white,
                      fontSize: 13,
                    ))
                : null,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: onTap,
          ),
        );
      },
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
      label: Text(
        S.of(context).logout,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
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
          backgroundColor: const Color.fromRGBO(247, 242, 250, 1),
          title: Text(
            S.of(context).notificationSettings,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  S.of(context).notificationInstructions,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                S.of(context).ok,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 46, 161, 132),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

String themeSubtitle(BuildContext context) {
  return context.watch<ThemeProvidor>().themeData.brightness == Brightness.light
      ? S.of(context).light
      : S.of(context).dark;
}
