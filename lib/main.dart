import 'package:flutter/material.dart';
import 'package:tadawa_app/screens/auth_screen.dart';
import 'package:tadawa_app/screens/switch_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();

  // Request notification permission
  await _requestNotificationPermission();

  runApp(const MyApp());
}

Future<void> _requestNotificationPermission() async {
  // Request notification permission
  final status = await Permission.notification.request();
  if (status.isGranted) {
    print('Notification permission granted');
  } else if (status.isDenied) {
    print('Notification permission denied');
  } else if (status.isPermanentlyDenied) {
    // Prompt user to open app settings
    print('Notification permission permanently denied. Please enable it in the app settings.');
    openAppSettings();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tadawa',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 46, 161, 132),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasData) {
            return SwitchScreen(
              medications: [],
              initialAppointments: [],
            );
          }
          return const AuthScreen();
        },
      ),
    );
  }
}