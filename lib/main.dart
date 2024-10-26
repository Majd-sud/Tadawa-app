import 'package:flutter/material.dart';
import 'package:tadawa_app/screens/auth_screen.dart';
import 'package:tadawa_app/screens/switch_screen.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:tadawa_app/models/appointment.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Medication> medications = [];
    final List<Appointment> initialAppointments = [];

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
              medications: medications,
              initialAppointments: initialAppointments,
            ); // Replace with your home screen
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
