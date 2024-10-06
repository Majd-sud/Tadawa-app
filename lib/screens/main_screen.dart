import 'package:flutter/material.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  final List<Medication> medications;

  const MainScreen({super.key, required this.medications});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
  }

  List<Medication> _getTodaysMedications() {
    return widget.medications.where((medication) {
      return medication.startDate.isBefore(_today) &&
          medication.endDate.isAfter(_today);
    }).toList();
  }

  void _toggleMedication(Medication medication) {
    setState(() {
      medication.isTaken = !medication.isTaken;
    });
  }

  @override
  Widget build(BuildContext context) {
    final todaysMedications = _getTodaysMedications();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Medications'),
        // Remove the actions for adding a medication
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              DateFormat.yMMMMd().format(_today),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: todaysMedications.length,
                itemBuilder: (context, index) {
                  final medication = todaysMedications[index];
                  return ListTile(
                    title: Text(medication.name),
                    trailing: Checkbox(
                      value: medication.isTaken,
                      onChanged: (value) {
                        _toggleMedication(medication);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}