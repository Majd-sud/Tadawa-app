import 'package:flutter/material.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:tadawa_app/screens/add_medication_screen.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class MedicationScreen extends StatefulWidget {
  final List<Medication> medications;

  const MedicationScreen({super.key, required this.medications});

  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  void _addMedication(Medication medication) {
    setState(() {
      widget.medications.add(medication);
    });
  }

  void _editMedication(int index, Medication medication) {
    setState(() {
      widget.medications[index] = medication;
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
        itemCount: widget.medications.length,
        itemBuilder: (context, index) {
          final medication = widget.medications[index];
          return Dismissible(
            key: ValueKey(medication),
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
              setState(() {
                widget.medications.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${medication.name} deleted'),
                ),
              );
            },
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date: ${DateFormat.yMMMd().format(medication.startDate)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'End Date: ${DateFormat.yMMMd().format(medication.endDate)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Time: ${medication.time.format(context)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updatedMedication = await Navigator.push<Medication>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMedicationScreen(medication: medication),
                      ),
                    );
                    if (updatedMedication != null) {
                      _editMedication(index, updatedMedication);
                    }
                  },
                ),
                onTap: () {}, 
              ),
            ),
          );
        },
      ),
    );
  }
}