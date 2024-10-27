import 'package:flutter/material.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:intl/intl.dart';
import 'package:tadawa_app/screens/add_medication_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Medication> _medications = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  Future<void> _fetchMedications() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Fetch medications from the user's subcollection
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('medications')
            .get();

        setState(() {
          // Map the fetched documents to Medication objects
          _medications = snapshot.docs
              .map((doc) => Medication.fromFirestore(
                  doc.data(), doc.id)) // Pass doc.id here
              .toList();
        });

        // Log the number of documents fetched
        print('Number of documents fetched: ${snapshot.docs.length}');
        print(
            'Fetched medications: ${_medications.map((m) => m.name).toList()}');
      } catch (e) {
        print('Error fetching medications: $e');
      }
    } else {
      print('No user is currently logged in.');
    }
  }

  List<Medication> _getTodaysMedications(DateTime date) {
    final dateOnly =
        DateTime(date.year, date.month, date.day); // Normalize to midnight

    return _medications.where((medication) {
      final reminderDates = _generateReminderDates(
        medication.startDate,
        medication.endDate,
        medication.frequency,
      );

      // Debugging: Log the medication details
      print('Checking medication: ${medication.name}');
      print('  Start Date: ${medication.startDate}');
      print('  End Date: ${medication.endDate}');
      print('  Frequency: ${medication.frequency}');
      print('  Reminder Dates: $reminderDates');
      print('  Selected Date: $dateOnly');

      return reminderDates
          .any((reminderDate) => reminderDate.isAtSameMomentAs(dateOnly));
    }).toList();
  }

  List<DateTime> _generateReminderDates(
      DateTime start, DateTime end, String frequency) {
    List<DateTime> reminderDates = [];
    DateTime currentDate = start;

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      reminderDates.add(DateTime(currentDate.year, currentDate.month,
          currentDate.day)); // Normalize to midnight

      switch (frequency) {
        case 'Daily':
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case 'Weekly':
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case 'Monthly':
          int nextMonth = currentDate.month + 1;
          int nextYear = currentDate.year;

          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear += 1;
          }

          currentDate = DateTime(nextYear, nextMonth, currentDate.day);
          // Adjust for months with fewer days
          if (currentDate.day > DateTime(nextYear, nextMonth + 1, 0).day) {
            currentDate = DateTime(nextYear, nextMonth + 1, 0);
          }
          break;
        default:
          break;
      }
    }
    return reminderDates;
  }

  void _navigateToAddMedication() async {
    final medication = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMedicationScreen(),
      ),
    );

    if (medication != null) {
      setState(() {
        _medications.add(medication);
      });
      // Optionally, you could save the new medication to Firestore here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications Overview')
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _getTodaysMedications(_selectedDate).length,
              itemBuilder: (context, index) {
                final medication = _getTodaysMedications(_selectedDate)[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(medication.name),
                    subtitle: Text('Time: ${medication.time.format(context)}'),
                    trailing: Checkbox(
                      value: medication.takenStatus[_selectedDate] ?? false,
                      onChanged: (value) {
                        setState(() {
                          medication.takenStatus[_selectedDate] =
                              value ?? false;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
            });
          },
        ),
        Text(
          DateFormat.yMMMMd().format(_selectedDate),
          style: const TextStyle(fontSize: 20),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 1));
            });
          },
        ),
      ],
    );
  }
}
