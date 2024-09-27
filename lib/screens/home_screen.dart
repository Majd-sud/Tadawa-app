import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
      body: Center(
        child: Text('Selected Index: $_selectedIndex'),
      ),
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
