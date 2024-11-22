import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tadawa_app/notification_service.dart';
import 'package:tadawa_app/theme.dart';
import 'package:tadawa_app/theme_providor.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Medication> _medications = [];
  DateTime _selectedDate = DateTime.now();
  final List<SnackBar> _snackBarsQueue = []; // Queue for SnackBars

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _setLocalTimeZone();
    NotificationService.initialize();
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

        // Check for warnings after fetching medications
        _checkForWarnings();

        // Schedule notifications for each medication
        await _scheduleNotifications();
      } catch (e) {
        print('Error fetching medications: $e');
      }
    } else {
      print('No user is currently logged in.');
    }
  }

  void _checkForWarnings() {
    bool hasExpiringMedications = _medications.any((medication) =>
        medication.expirationDate
            .isBefore(DateTime.now().add(Duration(days: 7))) &&
        !medication.isExpired());

    bool hasLowPills = _hasLowPills();

    if (hasExpiringMedications) {
      _addSnackBar('You have medications expiring within the next week!',
          Colors.orange, Icons.warning);
    }

    if (hasLowPills) {
      _addSnackBar('You have medications with less than 5 pills left!',
          Colors.red, Icons.warning);
    }
  }

  void _addSnackBar(String message, Color backgroundColor, IconData icon) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
              child:
                  Text(message, style: const TextStyle(color: Colors.white))),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    );

    // Add to the queue and show
    _snackBarsQueue.add(snackBar);
    _showNextSnackBar();
  }

  void _showNextSnackBar() {
    if (_snackBarsQueue.isNotEmpty) {
      final snackBar = _snackBarsQueue.removeAt(0);
      ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((_) {
        // Show the next SnackBar when the current one is closed
        _showNextSnackBar();
      });
    }
  }

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

      if (!medication.isExpired()) {
        await _scheduleExpiryNotification(medication);
      }
    }
  }

  Future<void> _scheduleExpiryNotification(Medication medication) async {
    final tz.TZDateTime localDateTime =
        tz.TZDateTime.from(medication.expirationDate, tz.local);

    // Ensure the scheduled date is in the future
    if (localDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return; // Skip if the medication is already expired
    }

    await NotificationService.flutterLocalNotificationsPlugin.zonedSchedule(
      medication.id.hashCode ^ medication.expirationDate.millisecondsSinceEpoch,
      'Medication Expiry Alert',
      'Your medication "${medication.name}" is about to expire!',
      localDateTime.subtract(Duration(days: 1)), //
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Medication Expiry Alerts',
          channelDescription: 'Channel for medication expiry alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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

  Future<void> _updatePillsCount(
      Medication medication, int newPillsCount) async {
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
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating pills count: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(255, 254, 247, 255),
            title: const Text('Medications Overview'),
          ),
          body: Column(
            children: [
              _buildDateSelector(),
              const SizedBox(height: 20),
              Expanded(child: _buildMedicationList()),
            ],
          ),
        ));
  }

  Widget _buildMedicationList() {
    final todaysMedications = _getTodaysMedications(_selectedDate);

    if (todaysMedications.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/main_screen.png',
            height: 300,
          ),
          const SizedBox(height: 20),
          const Text(
            'No medications for this day',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: todaysMedications.length,
      itemBuilder: (context, index) {
        final medication = todaysMedications[index];
        return Consumer<ThemeProvidor>(
          builder: (context, value, child) {
            return Card(
                color: value.themeData == lightMode
                    ? Color.fromRGBO(247, 242, 250, 1)
                    : Colors.blueGrey.shade800,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Image.asset(
                    'assets/images/pill.png',
                    height: 30,
                  ),
                  title: Text(
                    medication.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: value.themeData == lightMode
                            ? Colors.black
                            : Colors.white),
                  ),
                  subtitle: Text(
                    'Time: ${medication.time.format(context)}',
                    style: TextStyle(
                        color: value.themeData == lightMode
                            ? Colors.black
                            : Colors.white),
                  ),
                  trailing: Checkbox(
                    activeColor: value.themeData == lightMode
                        ? Colors.black
                        : Colors.white,
                    side: BorderSide(
                        color: value.themeData == lightMode
                            ? Colors.black
                            : Colors.white),
                    value: medication.takenStatus[_selectedDate] ?? false,
                    onChanged: (value) {
                      setState(() {
                        medication.takenStatus[_selectedDate] = value ?? false;
                        if (value == true && medication.pillsCount > 0) {
                          medication.pillsCount -= 1;
                          _updatePillsCount(medication, medication.pillsCount);
                        }
                      });
                    },
                  ),
                ));
          },
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
