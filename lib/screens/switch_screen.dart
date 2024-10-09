import 'package:flutter/material.dart';
import 'medication_screen.dart';
import 'package:tadawa_app/screens/main_screen.dart';
import 'package:tadawa_app/models/medication.dart';

class SwitchScreen extends StatefulWidget {
  final List<Medication> medications;
  const SwitchScreen({super.key , required this.medications});

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
      const Center(child: Text('Calendar')),
      MedicationScreen(medications: widget.medications),
      const Center(child: Text('Profile')),
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
            child: Image.asset(
          'assets/logos/logo2.PNG',
          height: 40,
          width: 40,
        )),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black26,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.medication_sharp), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
