import 'package:flutter/material.dart';
import 'package:tadawa_app/screens/appointment_screen.dart';
import 'package:tadawa_app/screens/profile_screen.dart';
import 'package:tadawa_app/screens/main_screen.dart';
import 'package:tadawa_app/screens/medication_screen.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:tadawa_app/models/appointment.dart';

class SwitchScreen extends StatefulWidget {
  final List<Medication> medications;
  final List<Appointment> initialAppointments;

  const SwitchScreen({
    super.key,
    required this.medications,
    required this.initialAppointments,
  });

  @override
  State<SwitchScreen> createState() {
    return _SwitchScreenState();
  }
}

class _SwitchScreenState extends State<SwitchScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      MainScreen(medications: widget.medications),
      AppointmentScreen(initialAppointments: widget.initialAppointments),
      MedicationScreen(medications: widget.medications),
      const ProfileScreen(), // Assuming ProfileScreen has no parameters
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logos/logo2.PNG',
              height: 40,
              width: 40,
            ),
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black26,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.medication_sharp), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
