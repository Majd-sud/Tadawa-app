import 'package:flutter/material.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:tadawa_app/screens/add_medication_screen.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final List<Medication> _medications = [];

  void _addMedication(Medication medication) {
    setState(() {
      _medications.add(medication);
    });
  }

  void _editMedication(int index, Medication medication) {
    setState(() {
      _medications[index] = medication;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        actions: [
          IconButton(
            onPressed: () async {
              final medication = await Navigator.push<Medication>(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMedicationScreen(),
                ),
              );
              if (medication != null) {
                _addMedication(medication);
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _medications.length,
        itemBuilder: (context, index) {
          final medication = _medications[index];
          return Dismissible(
            key: ValueKey(medication), // Unique key for the Dismissible
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              // Remove the item from the list
              setState(() {
                _medications.removeAt(index);
              });
              // Show a snackbar to inform the user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${medication.name} deleted'),
                ),
              );
            },
            child: ListTile(
              title: Text(medication.name),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final updatedMedication = await Navigator.push<Medication>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddMedicationScreen(medication: medication),
                    ),
                  );
                  if (updatedMedication != null) {
                    _editMedication(index, updatedMedication);
                  }
                },
              ),
              onTap: () {}, // Implement additional functionality if needed
            ),
          );
        },
      ),
    );
  }
}