import 'package:flutter/material.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tadawa_app/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart'; // Import this package

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
    tz.initializeTimeZones();

    // Set the local time zone
    _setLocalTimeZone();

    NotificationService
        .initialize(); // Ensure notification service is initialized
    _fetchMedications();
  }

  Future<void> _setLocalTimeZone() async {
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> _fetchMedications() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('medications')
            .get();

        setState(() {
          _medications = snapshot.docs
              .map((doc) => Medication.fromFirestore(doc.data(), doc.id))
              .toList();
        });

        print(
            'Fetched medications: ${_medications.map((m) => m.name).toList()}');

        // Schedule notifications for each medication
        await _scheduleNotifications();
      } catch (e) {
        print('Error fetching medications: $e');
      }
    } else {
      print('No user is currently logged in.');
    }
  }
   // Method to check if any medication has less than 5 pills
  bool _hasLowPills() {
    return _medications.any((medication) => medication.pillsCount < 5);
  }

  Future<void> _scheduleNotifications() async {
    for (var medication in _medications) {
      print('Scheduling notifications for: ${medication.name}');

      final List<DateTime> reminderDates = _generateReminderDates(
        medication.startDate,
        medication.endDate,
        medication.frequency,
        medication.time,
      );

      for (var reminderDate in reminderDates) {
        final tz.TZDateTime localDateTime = tz.TZDateTime(
          tz.local,
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          medication.time.hour % 24, // Ensure correct hour format
          medication.time.minute,
        );

        print('Attempting to schedule for: $localDateTime');

        // Ensure the scheduled date is in the future
        if (localDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
          print(
              'Scheduled time is in the past. Skipping scheduling for: $localDateTime');
          continue;
        }

        // Schedule the notification
        await _scheduleNotification(medication, localDateTime);
      }
    }
  }

  Future<void> _scheduleNotification(
      Medication medication, tz.TZDateTime localDateTime) async {
    int notificationId =
        medication.id.hashCode ^ localDateTime.millisecondsSinceEpoch;
    notificationId =
        notificationId.abs() % (1 << 31); // Ensure it fits in the 32-bit range

    try {
      await NotificationService.flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Medication Reminder',
        'Time to take your medication: ${medication.name}',
        localDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Medication Reminders',
            channelDescription: 'Channel for medication reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Scheduled notification for: ${medication.name} at $localDateTime');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  List<DateTime> _generateReminderDates(DateTime start, DateTime end,
      String frequency, TimeOfDay medicationTime) {
    List<DateTime> reminderDates = [];
    DateTime currentDate = start;

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      final dateTimeWithMedTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        medicationTime.hour % 24, // Correctly handle 12 AM / 12 PM
        medicationTime.minute,
      );

      reminderDates.add(dateTimeWithMedTime);

      switch (frequency) {
        case 'Daily':
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case 'Weekly':
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case 'Monthly':
          currentDate = DateTime(
              currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        default:
          break;
      }
    }

    return reminderDates;
  }
  
 Future<void> _updatePillsCount(Medication medication, int newPillsCount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('medications')
            .doc(medication.id);

        // Update the pill count in Firestore
        await docRef.update({
          'pillsCount': newPillsCount,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pills count updated to $newPillsCount for ${medication.name}')),
        );
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating pills count: $e')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 254, 247, 255),
        title: const Text('Medications Overview'),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildMedicationList(),
          ),
          // Display warning if any medication has less than 5 pills left
           if (_hasLowPills())
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                color: Colors.yellow[200],
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  'Warning: You have medications with less than 5 pills left!',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    final todaysMedications = _getTodaysMedications(_selectedDate);

    if (todaysMedications.isEmpty) {
      return const Center(child: Text('No medications for this date.'));
    }

    return ListView.builder(
      itemCount: todaysMedications.length,
      itemBuilder: (context, index) {
        final medication = todaysMedications[index];
        return Card(
          color: const Color.fromRGBO(247, 242, 250, 1),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(medication.name),
            subtitle: Text('Time: ${_formatTime(medication.time)}'),
            trailing: Checkbox(
              value: medication.takenStatus[_selectedDate] ?? false,
              onChanged: (value) {
                setState(() {
                  medication.takenStatus[_selectedDate] = value ?? false;
                   // If checkbox is checked, decrease the pill count by 1 and update Firestore
                  if (value == true && medication.pillsCount > 0) {
                    medication.pillsCount -= 1;
                    _updatePillsCount(medication, medication.pillsCount);
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
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

  List<Medication> _getTodaysMedications(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _medications.where((medication) {
      final reminderDates = _generateReminderDates(
        medication.startDate,
        medication.endDate,
        medication.frequency,
        medication.time,
      );

      return reminderDates.any((reminderDate) {
        return reminderDate.year == dateOnly.year &&
            reminderDate.month == dateOnly.month &&
            reminderDate.day == dateOnly.day;
      });
    }).toList();
  }
}  