import 'package:flutter/material.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:tadawa_app/screens/add_medication_screen.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  late final Stream<List<Medication>> _medicationsStream;

  @override
  void initState() {
    super.initState();
    _medicationsStream = _fetchMedications();
  }

  Stream<List<Medication>> _fetchMedications() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      yield* FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Medication(
            id: doc.id, // Get the document ID
            name: data['name'] ?? '',
            startDate: _parseDate(data['startDate']),
            endDate: _parseDate(data['endDate']),
            expirationDate: _parseDate(data['expirationDate']),
            notes: data['notes'] ?? '',
            pillsCount: data['pillsCount'] ?? 0,
            time: data['time'] != null
                ? _parseTime(data['time'])
                : const TimeOfDay(hour: 12, minute: 0),
            frequency: data['frequency'] ?? '',
            schedule: data['schedule'] ?? '',
          );
        }).toList();
      });
    } else {
      yield []; // Return an empty list if no user is logged in
    }
  }

  DateTime _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    }
    throw Exception('Invalid date format');
  }

  static TimeOfDay _parseTime(dynamic timeData) {
    if (timeData is String) {
      String sanitizedTime = timeData
          .replaceAll(RegExp(r'[\s]+'), ' ')
          .replaceAll(RegExp(r'\u00A0'), ' ')
          .trim();

      List<String> parts = sanitizedTime.split(' ');
      if (parts.length != 2) {
        throw Exception('Invalid time format: $sanitizedTime');
      }

      List<String> timeParts = parts[0].split(':');
      if (timeParts.length != 2) {
        throw Exception('Invalid time format: $sanitizedTime');
      }

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      if (parts[1] == 'PM' && hour < 12) {
        hour += 12;
      } else if (parts[1] == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    }
    throw Exception('Time data is not a string: $timeData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromRGBO(255, 254, 247, 255),
        title: const Text('Medications'),
        actions: [
          IconButton(
            onPressed: () async {
              final medication = await Navigator.push<Medication>(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMedicationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<Medication>>(
        stream: _medicationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final medications = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return Dismissible(
                key: ValueKey(medication.id),
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
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('medications')
                      .doc(medication.id) // Use the document ID here
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${medication.name} deleted'),
                    ),
                  );
                },
                child: Card(
                   color: const Color.fromRGBO(247, 242, 250, 1),
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
                         // Warning message for pill count less than 5
                          if (medication.pillsCount < 5)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                            'Warning: Pills are running low!',
                             style: TextStyle(
                             color: Colors.red,
                             fontSize: 14,
                             fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                       ],
                    ),

                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final updatedMedication =
                            await Navigator.push<Medication>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddMedicationScreen(medication: medication),
                          ),
                        );
                      },
                    ),
                    onTap: () {},
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}