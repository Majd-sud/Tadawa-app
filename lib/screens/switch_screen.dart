import 'package:flutter/material.dart';
import 'package:tadawa_app/screens/appointment_screen.dart';
import 'package:tadawa_app/screens/settings_screen.dart';
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
      const MainScreen(),
      const AppointmentScreen(),
      const MedicationScreen(),
      const SettingsScreen(),
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
        elevation: 8,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          _buildNavBarItem(Icons.check_rounded, 'Home', 0),
          _buildNavBarItem(Icons.calendar_month, 'Appointments', 1),
          _buildNavBarItem(Icons.medication_sharp, 'Medications', 2),
          _buildNavBarItem(Icons.person, 'Profile', 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 46, 161, 132) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: isSelected ? 27: 24,
          color: isSelected ? Colors.white : Colors.black54,
        ),
      ),
      label: label,
    );
  }
}