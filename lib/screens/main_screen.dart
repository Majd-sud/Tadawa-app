import 'package:flutter/material.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:intl/intl.dart';
import 'package:tadawa_app/screens/add_medication_screen.dart';

class MainScreen extends StatefulWidget {
  final List<Medication> medications;

  const MainScreen({super.key, required this.medications});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();

  List<Medication> _getTodaysMedications(DateTime date) {
    List<Medication> todaysMedications = widget.medications.where((medication) {
      final reminderDates = _generateReminderDates(
        medication.startDate,
        medication.endDate,
        medication.frequency,
      );

      final dateOnly = DateTime(date.year, date.month, date.day);

      return reminderDates.any((reminderDate) =>
          reminderDate.year == dateOnly.year &&
          reminderDate.month == dateOnly.month &&
          reminderDate.day == dateOnly.day);
    }).toList();

    return todaysMedications;
  }

  List<DateTime> _generateReminderDates(
      DateTime start, DateTime end, String frequency) {
    List<DateTime> reminderDates = [];
    DateTime currentDate = start;

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      reminderDates.add(currentDate);
      if (frequency == 'Daily') {
        currentDate = currentDate.add(const Duration(days: 1));
      } else if (frequency == 'Weekly') {
        currentDate = currentDate.add(const Duration(days: 7));
      } else if (frequency == 'Monthly') {
        int nextMonth = currentDate.month + 1;
        int nextYear = currentDate.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear += 1;
        }
        currentDate = DateTime(nextYear, nextMonth, currentDate.day);
        if (currentDate.day != currentDate.day) {
          currentDate = DateTime(nextYear, nextMonth + 1, 0);
        }
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
        widget.medications.add(medication);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications Overview'),
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
