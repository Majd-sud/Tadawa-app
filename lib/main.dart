import 'package:flutter/material.dart';
import 'package:tadawa_app/screens/switch_screen.dart';
import 'package:tadawa_app/models/medication.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Medication> medications = [];
    return MaterialApp(
      title: 'Tadawa',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 46, 161, 132)),
            
      ),
      
      home: SwitchScreen(medications: medications),
    );
  }
}
